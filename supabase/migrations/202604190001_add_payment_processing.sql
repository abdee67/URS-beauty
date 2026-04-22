create extension if not exists pgcrypto;

create table if not exists public.booking_cancellation_policies (
  id bigint generated always as identity primary key,
  min_hours_before integer not null,
  refund_percentage numeric(5, 2) not null,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  constraint booking_cancellation_policies_min_hours_before_key unique (min_hours_before),
  constraint booking_cancellation_policies_refund_percentage_check
    check (refund_percentage >= 0 and refund_percentage <= 100)
);

insert into public.booking_cancellation_policies (
  min_hours_before,
  refund_percentage
)
values
  (24, 100),
  (6, 50),
  (0, 0)
on conflict (min_hours_before) do update
set
  refund_percentage = excluded.refund_percentage,
  is_active = true;

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings (id) on delete cascade,
  customer_id uuid not null references auth.users (id) on delete cascade,
  payment_method text not null,
  payment_type text not null default 'payment',
  status text not null default 'pending',
  amount numeric(10, 2) not null,
  currency text not null default 'etb',
  transaction_reference text,
  payment_proof_url text,
  metadata jsonb not null default '{}'::jsonb,
  idempotency_key text not null,
  stripe_payment_intent_id text,
  stripe_checkout_session_id text,
  failure_reason text,
  refundable_amount numeric(10, 2) not null default 0,
  refunded_amount numeric(10, 2) not null default 0,
  adjustment_amount numeric(10, 2) not null default 0,
  paid_at timestamptz,
  verified_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint payments_payment_method_check
    check (payment_method in ('card', 'bank_transfer')),
  constraint payments_payment_type_check
    check (payment_type in ('payment', 'adjustment', 'refund')),
  constraint payments_status_check
    check (
      status in (
        'pending',
        'processing',
        'requires_action',
        'succeeded',
        'failed',
        'cancelled',
        'refunded',
        'partially_refunded',
        'pending_verification'
      )
    ),
  constraint payments_amount_check
    check (amount >= 0),
  constraint payments_refunded_amount_check
    check (refunded_amount >= 0 and refunded_amount <= amount)
);

create unique index if not exists idx_payments_idempotency_key
  on public.payments (idempotency_key);

create unique index if not exists idx_payments_stripe_payment_intent_id
  on public.payments (stripe_payment_intent_id)
  where stripe_payment_intent_id is not null;

create index if not exists idx_payments_booking_id
  on public.payments (booking_id);

create index if not exists idx_payments_customer_id
  on public.payments (customer_id);

create index if not exists idx_payments_status
  on public.payments (status);

create table if not exists public.payment_audit_logs (
  id bigint generated always as identity primary key,
  payment_id uuid not null references public.payments (id) on delete cascade,
  booking_id uuid not null references public.bookings (id) on delete cascade,
  event_type text not null,
  actor_id uuid,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_payment_audit_logs_payment_id
  on public.payment_audit_logs (payment_id);

create or replace function public.set_current_timestamp_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists trg_payments_set_updated_at on public.payments;

create trigger trg_payments_set_updated_at
before update on public.payments
for each row
execute function public.set_current_timestamp_updated_at();

alter table public.payments enable row level security;
alter table public.payment_audit_logs enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'payments'
      and policyname = 'payments_select_own'
  ) then
    create policy payments_select_own
      on public.payments
      for select
      to authenticated
      using (customer_id = auth.uid());
  end if;
end;
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'payment_audit_logs'
      and policyname = 'payment_audit_logs_select_own'
  ) then
    create policy payment_audit_logs_select_own
      on public.payment_audit_logs
      for select
      to authenticated
      using (
        exists (
          select 1
          from public.payments p
          where p.id = payment_id
            and p.customer_id = auth.uid()
        )
      );
  end if;
end;
$$;

grant select on public.payments to authenticated;
grant select on public.payment_audit_logs to authenticated;

drop function if exists public.calculate_refund_quote(uuid);

create or replace function public.calculate_refund_quote(
  p_payment_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_payment public.payments%rowtype;
  v_booking public.bookings%rowtype;
  v_policy record;
  v_hours_until_appointment numeric(10, 2) := 0;
  v_refund_percentage numeric(5, 2) := 0;
  v_target_refund numeric(10, 2) := 0;
  v_refundable_amount numeric(10, 2) := 0;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  select *
  into v_payment
  from public.payments
  where id = p_payment_id
    and customer_id = auth.uid();

  if not found then
    raise exception 'Payment not found';
  end if;

  if v_payment.status not in ('succeeded', 'partially_refunded', 'refunded') then
    raise exception 'Only successful payments can be refunded';
  end if;

  select *
  into v_booking
  from public.bookings
  where id = v_payment.booking_id
    and customer = auth.uid();

  if not found then
    raise exception 'Booking not found';
  end if;

  v_hours_until_appointment := greatest(
    extract(epoch from (v_booking.scheduled_at - timezone('utc', now()))) / 3600.0,
    0
  );

  select
    min_hours_before,
    refund_percentage
  into v_policy
  from public.booking_cancellation_policies
  where is_active = true
    and min_hours_before <= floor(v_hours_until_appointment)
  order by min_hours_before desc
  limit 1;

  v_refund_percentage := coalesce(v_policy.refund_percentage, 0);
  v_target_refund := round(
    (v_payment.amount * (v_refund_percentage / 100.0))::numeric,
    2
  );
  v_refundable_amount := greatest(
    v_target_refund - coalesce(v_payment.refunded_amount, 0),
    0
  );

  return jsonb_build_object(
    'payment_id', v_payment.id,
    'booking_id', v_payment.booking_id,
    'currency', lower(coalesce(v_payment.currency, 'etb')),
    'hours_until_appointment', v_hours_until_appointment,
    'refund_percentage', v_refund_percentage,
    'refundable_amount', v_refundable_amount
  );
end;
$$;

grant execute on function public.calculate_refund_quote(uuid) to authenticated;

notify pgrst, 'reload schema';
