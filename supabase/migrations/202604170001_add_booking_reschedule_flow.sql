alter table if exists public.bookings
  add column if not exists rescheduled_from uuid references public.bookings (id);

alter table if exists public.bookings
  add column if not exists rescheduled_count integer not null default 0;

create index if not exists idx_bookings_rescheduled_from
  on public.bookings (rescheduled_from);

drop function if exists public.reschedule_booking(
  uuid,
  uuid,
  timestamptz
);

create or replace function public.reschedule_booking(
  p_booking_id uuid,
  p_new_stylist_id uuid,
  p_new_scheduled_at timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_source public.bookings%rowtype;
  v_source_item record;
  v_stylist_service record;
  v_new_booking public.bookings%rowtype;
  v_total_amount numeric(10, 2) := 0;
  v_total_duration integer := 0;
  v_new_booking_end_at timestamptz;
  v_local_scheduled_at timestamp;
  v_local_booking_end_at timestamp;
  v_selected_day text;
  v_next_reschedule_count integer := 0;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  select *
  into v_source
  from public.bookings
  where id = p_booking_id
    and customer = auth.uid();

  if not found then
    raise exception 'Booking not found';
  end if;

  if v_source.status not in ('pending', 'cancelled', 'no_show') then
    raise exception 'Only pending, cancelled, or no-show bookings can be rescheduled';
  end if;

  if p_new_scheduled_at <= timezone('utc', now()) then
    raise exception 'Scheduled time must be in the future';
  end if;
  --if the scheduled date and time is the same with the new rescheduled date and time do not reschdule,
  if v_source.scheduled_at = p_new_scheduled_at then
    raise exception 'Scheduled date and time is the same with the new rescheduled date and time';
  end if;

  if v_source.status = 'pending' --not for pending bookings
  and v_source.status = 'no_show' --not for no-show bookings
     and v_source.scheduled_at <= timezone('utc', now()) + interval '5 hours' then
    raise exception 'Bookings can only be rescheduled at least 5 hours before the appointment';
  end if;

  v_next_reschedule_count := coalesce(v_source.rescheduled_count, 0) + 1;
  if v_next_reschedule_count > 2 then
    raise exception 'This booking has reached the maximum number of reschedules';
  end if;

  if v_source.address is null then
    raise exception 'Booking address is required';
  end if;

  if not exists (
    select 1
    from public.customer_addresses ca
    where ca.id = v_source.address
      and ca.customer_id = v_source.customer
  ) then
    raise exception 'Selected address does not belong to the customer';
  end if;

  for v_source_item in
    select
      bs.service_id,
      bs.quantity,
      s.name as service_name,
      coalesce(s.duration_minutes, 0) as duration_minutes
    from public.booking_services bs
    join public.services s
      on s.id = bs.service_id
    where bs.booking_id = v_source.id
    order by bs.id
  loop
    select
      ss.id,
      ss.service_id,
      ss.price,
      s.name as service_name,
      coalesce(s.duration_minutes, 0) as duration_minutes
    into v_stylist_service
    from public.stylists_services ss
    join public.services s
      on s.id = ss.service_id
    where ss.stylists_id = p_new_stylist_id
      and ss.service_id = v_source_item.service_id
      and coalesce(ss.is_available, true) = true
    limit 1;

    if not found then
      raise exception 'The selected stylist is not available for one or more services in this booking';
    end if;

    v_total_amount := v_total_amount
      + (coalesce(v_stylist_service.price, 0) * coalesce(v_source_item.quantity, 0));
    v_total_duration := v_total_duration
      + (coalesce(v_stylist_service.duration_minutes, 0) * coalesce(v_source_item.quantity, 0));
  end loop;

  if v_total_duration <= 0 then
    raise exception 'Selected service duration is invalid';
  end if;

  v_new_booking_end_at := p_new_scheduled_at + make_interval(mins => v_total_duration);
  v_local_scheduled_at := timezone('Africa/Addis_Ababa', p_new_scheduled_at);
  v_local_booking_end_at := timezone('Africa/Addis_Ababa', v_new_booking_end_at);
  v_selected_day := trim(to_char(v_local_scheduled_at, 'Dy'));

  if not exists (
    select 1
    from public.stylists_availability sa
    where sa.stylists_id = p_new_stylist_id
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
    where b.stylist = p_new_stylist_id
      and b.id <> v_source.id
      and b.status = 'pending'
      and p_new_scheduled_at < b.end_at
      and v_new_booking_end_at > b.scheduled_at
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
    is_reviewed,
    rescheduled_from,
    rescheduled_count,
    created_at,
    updated_at,
    payment_method,
    payment_status,
    paid_amount,
    refund_amount,
    currency
  )
  values (
    v_source.customer,
    p_new_stylist_id,
    'pending',
    v_source.notes,
    v_source.address,
    v_total_amount,
    p_new_scheduled_at,
    v_new_booking_end_at,
    false,
    v_source.id,
    v_next_reschedule_count,
    timezone('utc', now()),
    timezone('utc', now())
  )
  returning *
  into v_new_booking;

  for v_source_item in
    select
      bs.service_id,
      bs.quantity
    from public.booking_services bs
    where bs.booking_id = v_source.id
    order by bs.id
  loop
    select
      ss.id,
      ss.service_id,
      ss.price,
      s.name as service_name,
      coalesce(s.duration_minutes, 0) as duration_minutes
    into v_stylist_service
    from public.stylists_services ss
    join public.services s
      on s.id = ss.service_id
    where ss.stylists_id = p_new_stylist_id
      and ss.service_id = v_source_item.service_id
      and coalesce(ss.is_available, true) = true
    limit 1;

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
      v_new_booking.id,
      v_stylist_service.service_name,
      v_stylist_service.service_id,
      v_stylist_service.id,
      v_source_item.quantity,
      v_stylist_service.price,
      v_stylist_service.duration_minutes
    );
  end loop;

  with recursive booking_lineage as (
    select b.id, b.rescheduled_from
    from public.bookings b
    where b.id = v_source.id
    union all
    select parent.id, parent.rescheduled_from
    from public.bookings parent
    join booking_lineage child
      on child.rescheduled_from = parent.id
  )
  update public.bookings target
  set
    status = case
      when target.id = v_source.id and target.status = 'pending' then 'cancelled'
      else target.status
    end,
    rescheduled_count = greatest(coalesce(target.rescheduled_count, 0), v_next_reschedule_count),
    updated_at = timezone('utc', now())
  where target.id in (select id from booking_lineage);

  return to_jsonb(v_new_booking);
end;
$$;

grant execute on function public.reschedule_booking(
  uuid,
  uuid,
  timestamptz
) to authenticated;

notify pgrst, 'reload schema';
