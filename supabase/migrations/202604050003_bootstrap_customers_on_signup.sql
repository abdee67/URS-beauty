create or replace function public.handle_new_customer_signup()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_address jsonb;
begin
  insert into public.customers (
    id,
    email,
    first_name,
    last_name,
    phone_number,
    created_at,
    updated_at
  )
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'first_name', ''),
    coalesce(new.raw_user_meta_data ->> 'last_name', ''),
    coalesce(new.raw_user_meta_data ->> 'phone_number', ''),
    timezone('utc', now()),
    timezone('utc', now())
  )
  on conflict (id) do update
  set
    email = excluded.email,
    first_name = excluded.first_name,
    last_name = excluded.last_name,
    phone_number = excluded.phone_number,
    updated_at = timezone('utc', now());

  v_address := coalesce(new.raw_user_meta_data -> 'signup_address', '{}'::jsonb);

  if coalesce(nullif(btrim(v_address ->> 'address_line1'), ''), '') <> '' then
    insert into public.customer_addresses (
      customer_id,
      address_line1,
      address_line2,
      city,
      state,
      postal_code,
      country,
      latitude,
      longitude,
      is_default,
      created_at,
      updated_at
    )
    select
      new.id,
      coalesce(v_address ->> 'address_line1', ''),
      coalesce(v_address ->> 'address_line2', ''),
      coalesce(v_address ->> 'city', ''),
      coalesce(v_address ->> 'state', ''),
      coalesce(v_address ->> 'postal_code', ''),
      coalesce(v_address ->> 'country', ''),
      coalesce((v_address ->> 'latitude')::double precision, 0),
      coalesce((v_address ->> 'longitude')::double precision, 0),
      true,
      timezone('utc', now()),
      timezone('utc', now())
    where not exists (
      select 1
      from public.customer_addresses ca
      where ca.customer_id = new.id
    );
  end if;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created_bootstrap_customer on auth.users;

create trigger on_auth_user_created_bootstrap_customer
  after insert on auth.users
  for each row execute function public.handle_new_customer_signup();

insert into public.customers (
  id,
  email,
  first_name,
  last_name,
  phone_number,
  created_at,
  updated_at
)
select
  u.id,
  coalesce(u.email, ''),
  coalesce(u.raw_user_meta_data ->> 'first_name', ''),
  coalesce(u.raw_user_meta_data ->> 'last_name', ''),
  coalesce(u.raw_user_meta_data ->> 'phone_number', ''),
  timezone('utc', now()),
  timezone('utc', now())
from auth.users u
where not exists (
  select 1
  from public.customers c
  where c.id = u.id
);

insert into public.customer_addresses (
  customer_id,
  address_line1,
  address_line2,
  city,
  state,
  postal_code,
  country,
  latitude,
  longitude,
  is_default,
  created_at,
  updated_at
)
select
  u.id,
  coalesce(u.raw_user_meta_data -> 'signup_address' ->> 'address_line1', ''),
  coalesce(u.raw_user_meta_data -> 'signup_address' ->> 'address_line2', ''),
  coalesce(u.raw_user_meta_data -> 'signup_address' ->> 'city', ''),
  coalesce(u.raw_user_meta_data -> 'signup_address' ->> 'state', ''),
  coalesce(u.raw_user_meta_data -> 'signup_address' ->> 'postal_code', ''),
  coalesce(u.raw_user_meta_data -> 'signup_address' ->> 'country', ''),
  coalesce((u.raw_user_meta_data -> 'signup_address' ->> 'latitude')::double precision, 0),
  coalesce((u.raw_user_meta_data -> 'signup_address' ->> 'longitude')::double precision, 0),
  true,
  timezone('utc', now()),
  timezone('utc', now())
from auth.users u
where coalesce(
    nullif(
      btrim(u.raw_user_meta_data -> 'signup_address' ->> 'address_line1'),
      ''
    ),
    ''
  ) <> ''
  and not exists (
    select 1
    from public.customer_addresses ca
    where ca.customer_id = u.id
  );

notify pgrst, 'reload schema';
