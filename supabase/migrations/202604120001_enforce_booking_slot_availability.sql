create or replace function public.create_booking_with_services(
  p_customer_id uuid,
  p_stylist_id uuid,
  p_scheduled_at timestamptz,
  p_address_id uuid,
  p_notes text default null,
  p_items jsonb default '[]'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_item jsonb;
  v_quantity integer;
  v_total_amount numeric(10, 2) := 0;
  v_total_duration integer := 0;
  v_booking public.bookings%rowtype;
  v_service_snapshot record;
  v_booking_end_at timestamptz;
  v_local_scheduled_at timestamp;
  v_local_booking_end_at timestamp;
  v_selected_day text;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if auth.uid() <> p_customer_id then
    raise exception 'Authenticated user does not match booking customer';
  end if;

  if p_scheduled_at <= timezone('utc', now()) then
    raise exception 'Scheduled time must be in the future';
  end if;

  if p_address_id is null then
    raise exception 'Booking address is required';
  end if;

  if not exists (
    select 1
    from public.customer_addresses ca
    where ca.id = p_address_id
      and ca.customer_id = p_customer_id
  ) then
    raise exception 'Selected address does not belong to the customer';
  end if;

  if p_items is null
     or jsonb_typeof(p_items) <> 'array'
     or jsonb_array_length(p_items) = 0 then
    raise exception 'At least one service item is required';
  end if;

  for v_item in
    select value
    from jsonb_array_elements(p_items)
  loop
    v_quantity := coalesce((v_item ->> 'quantity')::integer, 0);

    if v_quantity <= 0 then
      raise exception 'Each booking item must have a quantity greater than zero';
    end if;

    select
      ss.id,
      ss.stylists_id,
      ss.service_id,
      ss.price,
      s.name as service_name,
      coalesce(s.duration_minutes, 0) as duration_minutes
    into v_service_snapshot
    from public.stylists_services ss
    join public.services s
      on s.id = ss.service_id
    where ss.id = (v_item ->> 'stylist_service_id')::uuid
      and ss.service_id = (v_item ->> 'service_id')::uuid
      and ss.stylists_id = p_stylist_id
      and coalesce(ss.is_available, true) = true;

    if not found then
      raise exception 'Invalid service selection for the selected stylist';
    end if;

    v_total_amount := v_total_amount + (v_service_snapshot.price * v_quantity);
    v_total_duration := v_total_duration
      + (v_service_snapshot.duration_minutes * v_quantity);
  end loop;

  if v_total_duration <= 0 then
    raise exception 'Selected service duration is invalid';
  end if;

  v_booking_end_at := p_scheduled_at + make_interval(mins => v_total_duration);
  v_local_scheduled_at := timezone('Africa/Addis_Ababa', p_scheduled_at);
  v_local_booking_end_at := timezone('Africa/Addis_Ababa', v_booking_end_at);
  v_selected_day := trim(to_char(v_local_scheduled_at, 'Dy'));

  if not exists (
    select 1
    from public.stylists_availability sa
    where sa.stylists_id = p_stylist_id
      and sa.day_of_week = v_selected_day
      and coalesce(sa.is_available, false) = true
      and sa.start_time <= v_local_scheduled_at::time
      and sa.end_time >= v_local_booking_end_at::time
  ) then
    raise exception 'Stylist is not available at the selected time';
  end if;

  if exists (
    select 1
    from public.bookings b
    where b.stylist = p_stylist_id
      and b.status in ('pending', 'completed')
      and b.is_reviewed = false
      and p_scheduled_at < b.end_at
      and v_booking_end_at > b.scheduled_at
  ) then
    raise exception 'Slot already booked';
  end if;

  insert into public.bookings (
    customer,
    stylist,
    status,
    notes,
    address,
    total_amount,
    scheduled_at,
    end_at,
    created_at,
    updated_at,
    payment_method,
    payment_status,
    paid_amount,
    refund_amount,
    currency
  )
  values (
    p_customer_id,
    p_stylist_id,
    'pending',
    nullif(btrim(coalesce(p_notes, '')), ''),
    p_address_id,
    v_total_amount,
    p_scheduled_at,
    v_booking_end_at,
    timezone('utc', now()),
    timezone('utc', now())
  )
  returning *
  into v_booking;

  for v_item in
    select value
    from jsonb_array_elements(p_items)
  loop
    v_quantity := (v_item ->> 'quantity')::integer;

    select
      ss.id,
      ss.service_id,
      ss.price,
      s.name as service_name,
      coalesce(s.duration_minutes, 0) as duration_minutes
    into v_service_snapshot
    from public.stylists_services ss
    join public.services s
      on s.id = ss.service_id
    where ss.id = (v_item ->> 'stylist_service_id')::uuid
      and ss.service_id = (v_item ->> 'service_id')::uuid
      and ss.stylists_id = p_stylist_id
      and coalesce(ss.is_available, true) = true;

    insert into public.booking_services (
      booking_id,
      service_name,
      service_id,
      stylist_service_id,
      quantity,
      price_at_booking,
      duration_at_booking
    )
    values (
      v_booking.id,
      v_service_snapshot.service_name,
      v_service_snapshot.service_id,
      v_service_snapshot.id,
      v_quantity,
      v_service_snapshot.price,
      v_service_snapshot.duration_minutes
    );
  end loop;

  return to_jsonb(v_booking);
end;
$$;

grant execute on function public.create_booking_with_services(
  uuid,
  uuid,
  timestamptz,
  uuid,
  text,
  jsonb
) to authenticated;

notify pgrst, 'reload schema';
