create extension if not exists pgcrypto;

alter table if exists public.bookings
  add column if not exists commission_amount numeric(10, 2) not null default 0;

alter table if exists public.bookings
  add column if not exists stylist_earning numeric(10, 2) not null default 0;

create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(),
  stylist_id uuid not null unique references public.stylists (id) on delete cascade,
  balance numeric(10, 2) not null default 0,
  currency text not null default 'etb',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint wallets_currency_check check (char_length(trim(currency)) > 0)
);

create table if not exists public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets (id) on delete cascade,
  booking_id uuid references public.bookings (id) on delete set null,
  payment_id uuid references public.payments (id) on delete set null,
  transaction_type text not null,
  amount numeric(10, 2) not null,
  source text not null,
  reference text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  constraint wallet_transactions_type_check
    check (transaction_type in ('credit', 'debit')),
  constraint wallet_transactions_amount_check
    check (amount > 0),
  constraint wallet_transactions_source_check
    check (
      source in (
        'booking_earning',
        'penalty',
        'withdrawal',
        'topup'
      )
    )
);

create index if not exists idx_wallets_stylist_id
  on public.wallets (stylist_id);

create index if not exists idx_wallet_transactions_wallet_id
  on public.wallet_transactions (wallet_id);

create index if not exists idx_wallet_transactions_booking_id
  on public.wallet_transactions (booking_id);

create index if not exists idx_wallet_transactions_payment_id
  on public.wallet_transactions (payment_id);

create index if not exists idx_wallet_transactions_source
  on public.wallet_transactions (source);

create unique index if not exists idx_wallet_transactions_booking_earning_unique
  on public.wallet_transactions (wallet_id, booking_id, source, transaction_type)
  where booking_id is not null
    and source = 'booking_earning'
    and transaction_type = 'credit';

create table if not exists public.payouts (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets (id) on delete cascade,
  status text not null default 'pending',
  amount numeric(10, 2) not null,
  payout_method text not null,
  reference text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint payouts_status_check
    check (status in ('pending', 'processing', 'paid', 'cancelled')),
  constraint payouts_amount_check
    check (amount > 0),
  constraint payouts_method_check
    check (payout_method in ('bank_transfer', 'paypal', 'stripe'))
);

create index if not exists idx_payouts_wallet_id
  on public.payouts (wallet_id);

drop trigger if exists trg_wallets_set_updated_at on public.wallets;

create trigger trg_wallets_set_updated_at
before update on public.wallets
for each row
execute function public.set_current_timestamp_updated_at();

drop trigger if exists trg_payouts_set_updated_at on public.payouts;

create trigger trg_payouts_set_updated_at
before update on public.payouts
for each row
execute function public.set_current_timestamp_updated_at();

create or replace function public.credit_stylist_wallet(
  p_stylist_id uuid,
  p_booking_id uuid,
  p_payment_id uuid,
  p_amount numeric,
  p_currency text default 'etb',
  p_source text default 'booking_earning',
  p_reference text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_wallet public.wallets%rowtype;
  v_transaction_id uuid;
begin
  if p_stylist_id is null then
    raise exception 'stylist_id is required';
  end if;

  if p_amount is null or p_amount <= 0 then
    raise exception 'amount must be greater than zero';
  end if;

  if p_source not in ('booking_earning', 'topup') then
    raise exception 'Unsupported credit source';
  end if;

  insert into public.wallets (
    stylist_id,
    balance,
    currency
  )
  values (
    p_stylist_id,
    0,
    lower(coalesce(nullif(trim(p_currency), ''), 'etb'))
  )
  on conflict (stylist_id)
  do update
    set
      currency = lower(coalesce(nullif(trim(excluded.currency), ''), public.wallets.currency)),
      updated_at = timezone('utc', now())
  returning *
  into v_wallet;

  if p_source = 'booking_earning' then
    if p_booking_id is null or p_payment_id is null then
      raise exception 'booking_id and payment_id are required for booking earnings';
    end if;

    with inserted as (
      insert into public.wallet_transactions (
        wallet_id,
        booking_id,
        payment_id,
        transaction_type,
        amount,
        source,
        reference,
        metadata
      )
      values (
        v_wallet.id,
        p_booking_id,
        p_payment_id,
        'credit',
        p_amount,
        p_source,
        p_reference,
        coalesce(p_metadata, '{}'::jsonb)
      )
      on conflict (wallet_id, booking_id, source, transaction_type)
      where booking_id is not null
        and source = 'booking_earning'
        and transaction_type = 'credit'
      do nothing
      returning id
    )
    select id
    into v_transaction_id
    from inserted;
  else
    insert into public.wallet_transactions (
      wallet_id,
      booking_id,
      payment_id,
      transaction_type,
      amount,
      source,
      reference,
      metadata
    )
    values (
      v_wallet.id,
      p_booking_id,
      p_payment_id,
      'credit',
      p_amount,
      p_source,
      p_reference,
      coalesce(p_metadata, '{}'::jsonb)
    )
    returning id
    into v_transaction_id;
  end if;

  if v_transaction_id is not null then
    update public.wallets
    set
      balance = balance + p_amount,
      currency = lower(coalesce(nullif(trim(p_currency), ''), currency)),
      updated_at = timezone('utc', now())
    where id = v_wallet.id
    returning *
    into v_wallet;

    return jsonb_build_object(
      'wallet_id', v_wallet.id,
      'transaction_id', v_transaction_id,
      'balance', v_wallet.balance,
      'applied', true
    );
  end if;

  select *
  into v_wallet
  from public.wallets
  where id = v_wallet.id;

  select id
  into v_transaction_id
  from public.wallet_transactions
  where wallet_id = v_wallet.id
    and booking_id = p_booking_id
    and source = p_source
    and transaction_type = 'credit'
  order by created_at desc
  limit 1;

  return jsonb_build_object(
    'wallet_id', v_wallet.id,
    'transaction_id', v_transaction_id,
    'balance', v_wallet.balance,
    'applied', false
  );
end;
$$;

create or replace function public.debit_stylist_wallet(
  p_stylist_id uuid,
  p_booking_id uuid default null,
  p_payment_id uuid default null,
  p_amount numeric default 0,
  p_currency text default 'etb',
  p_source text default 'penalty',
  p_reference text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_wallet public.wallets%rowtype;
  v_transaction_id uuid;
begin
  if p_stylist_id is null then
    raise exception 'stylist_id is required';
  end if;

  if p_amount is null or p_amount <= 0 then
    raise exception 'amount must be greater than zero';
  end if;

  if p_source not in ('penalty', 'withdrawal') then
    raise exception 'Unsupported debit source';
  end if;

  insert into public.wallets (
    stylist_id,
    balance,
    currency
  )
  values (
    p_stylist_id,
    0,
    lower(coalesce(nullif(trim(p_currency), ''), 'etb'))
  )
  on conflict (stylist_id)
  do update
    set
      currency = lower(coalesce(nullif(trim(excluded.currency), ''), public.wallets.currency)),
      updated_at = timezone('utc', now())
  returning *
  into v_wallet;

  insert into public.wallet_transactions (
    wallet_id,
    booking_id,
    payment_id,
    transaction_type,
    amount,
    source,
    reference,
    metadata
  )
  values (
    v_wallet.id,
    p_booking_id,
    p_payment_id,
    'debit',
    p_amount,
    p_source,
    p_reference,
    coalesce(p_metadata, '{}'::jsonb)
  )
  returning id
  into v_transaction_id;

  update public.wallets
  set
    balance = balance - p_amount,
    currency = lower(coalesce(nullif(trim(p_currency), ''), currency)),
    updated_at = timezone('utc', now())
  where id = v_wallet.id
  returning *
  into v_wallet;

  return jsonb_build_object(
    'wallet_id', v_wallet.id,
    'transaction_id', v_transaction_id,
    'balance', v_wallet.balance,
    'applied', true
  );
end;
$$;

alter table public.wallets enable row level security;
alter table public.wallet_transactions enable row level security;
alter table public.payouts enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'wallets'
      and policyname = 'wallets_select_own'
  ) then
    create policy wallets_select_own
      on public.wallets
      for select
      to authenticated
      using (stylist_id = auth.uid());
  end if;
end;
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'wallet_transactions'
      and policyname = 'wallet_transactions_select_own'
  ) then
    create policy wallet_transactions_select_own
      on public.wallet_transactions
      for select
      to authenticated
      using (
        exists (
          select 1
          from public.wallets w
          where w.id = wallet_transactions.wallet_id
            and w.stylist_id = auth.uid()
        )
      );
  end if;
end;
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'payouts'
      and policyname = 'payouts_select_own'
  ) then
    create policy payouts_select_own
      on public.payouts
      for select
      to authenticated
      using (
        exists (
          select 1
          from public.wallets w
          where w.id = payouts.wallet_id
            and w.stylist_id = auth.uid()
        )
      );
  end if;
end;
$$;

grant select on public.wallets to authenticated;
grant select on public.wallet_transactions to authenticated;
grant select on public.payouts to authenticated;

revoke all on function public.credit_stylist_wallet(
  uuid,
  uuid,
  uuid,
  numeric,
  text,
  text,
  text,
  jsonb
) from public;

revoke all on function public.debit_stylist_wallet(
  uuid,
  uuid,
  uuid,
  numeric,
  text,
  text,
  text,
  jsonb
) from public;

grant execute on function public.credit_stylist_wallet(
  uuid,
  uuid,
  uuid,
  numeric,
  text,
  text,
  text,
  jsonb
) to service_role;

grant execute on function public.debit_stylist_wallet(
  uuid,
  uuid,
  uuid,
  numeric,
  text,
  text,
  text,
  jsonb
) to service_role;

notify pgrst, 'reload schema';
