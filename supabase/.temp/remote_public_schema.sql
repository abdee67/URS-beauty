

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."calculate_refund_quote"("p_payment_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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


ALTER FUNCTION "public"."calculate_refund_quote"("p_payment_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_booking_with_services"("p_customer_id" "uuid", "p_stylist_id" "uuid", "p_scheduled_at" timestamp with time zone, "p_address_id" "uuid", "p_notes" "text" DEFAULT NULL::"text", "p_items" "jsonb" DEFAULT '[]'::"jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
      and b.status in ('pending')
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
    is_reviewed
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
    timezone('utc', now()),
    false
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


ALTER FUNCTION "public"."create_booking_with_services"("p_customer_id" "uuid", "p_stylist_id" "uuid", "p_scheduled_at" timestamp with time zone, "p_address_id" "uuid", "p_notes" "text", "p_items" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reschedule_booking"("p_booking_id" "uuid", "p_new_stylist_id" "uuid", "p_new_scheduled_at" timestamp with time zone) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
    raise exception 'Scheduled date and time shouldnt be the same with the new rescheduled date and time';
  end if;

  if v_source.status = 'pending'
  and v_source.status = 'no_show' --not for no show bookings
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
    updated_at
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


ALTER FUNCTION "public"."reschedule_booking"("p_booking_id" "uuid", "p_new_stylist_id" "uuid", "p_new_scheduled_at" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_current_timestamp_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at := timezone('utc', now());
  return new;
end;
$$;


ALTER FUNCTION "public"."set_current_timestamp_updated_at"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."booking_cancellation_policies" (
    "id" bigint NOT NULL,
    "min_hours_before" integer NOT NULL,
    "refund_percentage" numeric(5,2) NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "booking_cancellation_policies_refund_percentage_check" CHECK ((("refund_percentage" >= (0)::numeric) AND ("refund_percentage" <= (100)::numeric)))
);


ALTER TABLE "public"."booking_cancellation_policies" OWNER TO "postgres";


ALTER TABLE "public"."booking_cancellation_policies" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."booking_cancellation_policies_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."booking_services" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "booking_id" "uuid" NOT NULL,
    "service_id" "uuid" NOT NULL,
    "stylist_service_id" "uuid" NOT NULL,
    "quantity" integer DEFAULT 1,
    "price_at_booking" numeric(10,2) NOT NULL,
    "duration_at_booking" integer NOT NULL,
    "service_name" "text"
);


ALTER TABLE "public"."booking_services" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bookings" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "customer" "uuid" NOT NULL,
    "stylist" "uuid" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "scheduled_at" timestamp with time zone NOT NULL,
    "end_at" timestamp with time zone NOT NULL,
    "address" "uuid" NOT NULL,
    "notes" "text",
    "total_amount" numeric(10,2) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_reviewed" boolean,
    "rescheduled_from" "uuid",
    "rescheduled_count" integer DEFAULT 0 NOT NULL,
    "payment_method" "text",
    "currency" "text" DEFAULT 'ETB'::"text",
    "payment_status" "text" DEFAULT ''::"text",
    "paid_amount" double precision DEFAULT '0'::double precision,
    "refund_amount" double precision DEFAULT '0'::double precision,
    CONSTRAINT "bookings_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'confirmed'::"text", 'completed'::"text", 'cancelled'::"text", 'rescheduled'::"text"])))
);


ALTER TABLE "public"."bookings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cancellation_policies" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text" NOT NULL,
    "cancellation_fee_percent" numeric(5,2) NOT NULL,
    "hours_before_cancellation" integer NOT NULL,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."cancellation_policies" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."customer_addresses" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "address_line1" "text" NOT NULL,
    "address_line2" "text",
    "city" "text" NOT NULL,
    "state" "text" NOT NULL,
    "postal_code" "text" NOT NULL,
    "country" "text" NOT NULL,
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "is_default" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."customer_addresses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."customers" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "first_name" "text" NOT NULL,
    "last_name" "text" NOT NULL,
    "email" "text" NOT NULL,
    "phone_number" "text" NOT NULL,
    "profile_image_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."customers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."deals" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text",
    "description" "text",
    "original_price" "text",
    "discounted_price" "text",
    "service_name" "text",
    "service_category" "uuid",
    "image_url" "text"
);


ALTER TABLE "public"."deals" OWNER TO "postgres";


ALTER TABLE "public"."deals" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."deals_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "body" "text" NOT NULL,
    "data" "jsonb",
    "is_read" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."payment_audit_logs" (
    "id" bigint NOT NULL,
    "payment_id" "uuid" NOT NULL,
    "booking_id" "uuid" NOT NULL,
    "event_type" "text" NOT NULL,
    "actor_id" "uuid",
    "payload" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."payment_audit_logs" OWNER TO "postgres";


ALTER TABLE "public"."payment_audit_logs" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."payment_audit_logs_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."payment_verifications" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "payment_id" bigint NOT NULL,
    "booking_id" "uuid",
    "verified_by" "uuid",
    "status" "text" DEFAULT ''::"text",
    "notes" "text",
    "verfieid_at" timestamp with time zone
);


ALTER TABLE "public"."payment_verifications" OWNER TO "postgres";


COMMENT ON TABLE "public"."payment_verifications" IS 'For manual bank flow tracking';



ALTER TABLE "public"."payment_verifications" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."payment_verifications_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "booking_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "payment_method" "text" NOT NULL,
    "payment_type" "text" DEFAULT 'payment'::"text" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "amount" numeric(10,2) NOT NULL,
    "currency" "text" DEFAULT 'etb'::"text" NOT NULL,
    "transaction_reference" "text",
    "payment_proof_url" "text",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "idempotency_key" "text" NOT NULL,
    "stripe_payment_intent_id" "text",
    "stripe_checkout_session_id" "text",
    "failure_reason" "text",
    "refundable_amount" numeric(10,2) DEFAULT 0 NOT NULL,
    "refunded_amount" numeric(10,2) DEFAULT 0 NOT NULL,
    "adjustment_amount" numeric(10,2) DEFAULT 0 NOT NULL,
    "paid_at" timestamp with time zone,
    "verified_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "payments_amount_check" CHECK (("amount" >= (0)::numeric)),
    CONSTRAINT "payments_payment_method_check" CHECK (("payment_method" = ANY (ARRAY['card'::"text", 'bank_transfer'::"text"]))),
    CONSTRAINT "payments_payment_type_check" CHECK (("payment_type" = ANY (ARRAY['payment'::"text", 'adjustment'::"text", 'refund'::"text"]))),
    CONSTRAINT "payments_refunded_amount_check" CHECK ((("refunded_amount" >= (0)::numeric) AND ("refunded_amount" <= "amount"))),
    CONSTRAINT "payments_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'processing'::"text", 'requires_action'::"text", 'succeeded'::"text", 'failed'::"text", 'cancelled'::"text", 'refunded'::"text", 'partially_refunded'::"text", 'pending_verification'::"text"])))
);


ALTER TABLE "public"."payments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."reviews" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "booking_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "stylists_id" "uuid" NOT NULL,
    "rating" double precision NOT NULL,
    "comment" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "reviews_rating_check" CHECK ((("rating" >= (1)::double precision) AND ("rating" <= (5)::double precision)))
);


ALTER TABLE "public"."reviews" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."service_categories" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "icon_url" "text",
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."service_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."services" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "category_id" "uuid",
    "duration_minutes" integer NOT NULL,
    "base_price" numeric(10,2) NOT NULL,
    "min_price" numeric(10,2),
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "icon_url" "text"
);


ALTER TABLE "public"."services" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stylists" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "business_name" "text" NOT NULL,
    "description" "text",
    "service_radius_km" integer DEFAULT 10,
    "is_verified" boolean DEFAULT false,
    "avg_rating" numeric(3,2) DEFAULT 0.0,
    "total_reviews" integer DEFAULT 0,
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "image_url" "text"
);


ALTER TABLE "public"."stylists" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stylists_availability" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "stylists_id" "uuid" NOT NULL,
    "start_time" time without time zone NOT NULL,
    "end_time" time without time zone NOT NULL,
    "is_available" boolean DEFAULT true,
    "day_of_week" "text"
);


ALTER TABLE "public"."stylists_availability" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stylists_services" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "stylists_id" "uuid" NOT NULL,
    "service_id" "uuid" NOT NULL,
    "price" numeric(10,2) NOT NULL,
    "is_available" boolean DEFAULT true
);


ALTER TABLE "public"."stylists_services" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "email" "text" NOT NULL,
    "phone" "text" NOT NULL,
    "name" "text" NOT NULL,
    "id" "uuid" DEFAULT "auth"."uid"() NOT NULL
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."booking_cancellation_policies"
    ADD CONSTRAINT "booking_cancellation_policies_min_hours_before_key" UNIQUE ("min_hours_before");



ALTER TABLE ONLY "public"."booking_cancellation_policies"
    ADD CONSTRAINT "booking_cancellation_policies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."booking_services"
    ADD CONSTRAINT "booking_services_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cancellation_policies"
    ADD CONSTRAINT "cancellation_policies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."customer_addresses"
    ADD CONSTRAINT "customer_addresses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."deals"
    ADD CONSTRAINT "deals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payment_audit_logs"
    ADD CONSTRAINT "payment_audit_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payment_verifications"
    ADD CONSTRAINT "payment_verifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stylists_availability"
    ADD CONSTRAINT "professionals_availability_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stylists"
    ADD CONSTRAINT "professionals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stylists_services"
    ADD CONSTRAINT "professionals_services_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stylists_services"
    ADD CONSTRAINT "professionals_services_provider_id_service_id_key" UNIQUE ("stylists_id", "service_id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_booking_id_key" UNIQUE ("booking_id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."service_categories"
    ADD CONSTRAINT "service_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."services"
    ADD CONSTRAINT "services_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_booking_services_booking_id" ON "public"."booking_services" USING "btree" ("booking_id");



CREATE INDEX "idx_booking_services_service_id" ON "public"."booking_services" USING "btree" ("service_id");



CREATE INDEX "idx_booking_services_stylist_service_id" ON "public"."booking_services" USING "btree" ("stylist_service_id");



CREATE INDEX "idx_bookings_customer" ON "public"."bookings" USING "btree" ("customer");



CREATE INDEX "idx_bookings_rescheduled_from" ON "public"."bookings" USING "btree" ("rescheduled_from");



CREATE INDEX "idx_payment_audit_logs_payment_id" ON "public"."payment_audit_logs" USING "btree" ("payment_id");



CREATE INDEX "idx_payments_booking_id" ON "public"."payments" USING "btree" ("booking_id");



CREATE INDEX "idx_payments_customer_id" ON "public"."payments" USING "btree" ("customer_id");



CREATE UNIQUE INDEX "idx_payments_idempotency_key" ON "public"."payments" USING "btree" ("idempotency_key");



CREATE INDEX "idx_payments_status" ON "public"."payments" USING "btree" ("status");



CREATE UNIQUE INDEX "idx_payments_stripe_payment_intent_id" ON "public"."payments" USING "btree" ("stripe_payment_intent_id") WHERE ("stripe_payment_intent_id" IS NOT NULL);



CREATE INDEX "idx_professionals_services_service" ON "public"."stylists_services" USING "btree" ("service_id");



CREATE INDEX "idx_reviews_professionals" ON "public"."reviews" USING "btree" ("stylists_id");



CREATE INDEX "idx_services_category" ON "public"."services" USING "btree" ("category_id");



CREATE OR REPLACE TRIGGER "trg_payments_set_updated_at" BEFORE UPDATE ON "public"."payments" FOR EACH ROW EXECUTE FUNCTION "public"."set_current_timestamp_updated_at"();



ALTER TABLE ONLY "public"."booking_services"
    ADD CONSTRAINT "booking_services_booking_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id");



ALTER TABLE ONLY "public"."booking_services"
    ADD CONSTRAINT "booking_services_service_fkey" FOREIGN KEY ("service_id") REFERENCES "public"."services"("id");



ALTER TABLE ONLY "public"."booking_services"
    ADD CONSTRAINT "booking_services_stylists_service_fkey" FOREIGN KEY ("stylist_service_id") REFERENCES "public"."stylists_services"("id");



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_address_fkey" FOREIGN KEY ("address") REFERENCES "public"."customer_addresses"("id");



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_customer_id_fkey" FOREIGN KEY ("customer") REFERENCES "public"."customers"("id");



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_rescheduled_from_fkey" FOREIGN KEY ("rescheduled_from") REFERENCES "public"."bookings"("id");



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_stylists_id_fkey" FOREIGN KEY ("stylist") REFERENCES "public"."stylists"("id");



ALTER TABLE ONLY "public"."customer_addresses"
    ADD CONSTRAINT "customer_addresses_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id");



ALTER TABLE ONLY "public"."deals"
    ADD CONSTRAINT "deals_service_category_fkey" FOREIGN KEY ("service_category") REFERENCES "public"."service_categories"("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id");



ALTER TABLE ONLY "public"."payment_audit_logs"
    ADD CONSTRAINT "payment_audit_logs_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payment_audit_logs"
    ADD CONSTRAINT "payment_audit_logs_payment_id_fkey" FOREIGN KEY ("payment_id") REFERENCES "public"."payments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payment_verifications"
    ADD CONSTRAINT "payment_verifications_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id");



ALTER TABLE ONLY "public"."payment_verifications"
    ADD CONSTRAINT "payment_verifications_verified_by_fkey" FOREIGN KEY ("verified_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stylists_availability"
    ADD CONSTRAINT "professionals_availability_professionals_id_fkey" FOREIGN KEY ("stylists_id") REFERENCES "public"."stylists"("id");



ALTER TABLE ONLY "public"."stylists_services"
    ADD CONSTRAINT "professionals_services_professionals_id_fkey" FOREIGN KEY ("stylists_id") REFERENCES "public"."stylists"("id");



ALTER TABLE ONLY "public"."stylists_services"
    ADD CONSTRAINT "professionals_services_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "public"."services"("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_stylists_id_fkey" FOREIGN KEY ("stylists_id") REFERENCES "public"."stylists"("id");



ALTER TABLE ONLY "public"."services"
    ADD CONSTRAINT "services_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."service_categories"("id");



CREATE POLICY "Allow Authenticated INSERT" ON "public"."users" FOR INSERT TO "authenticated" WITH CHECK (("id" = "auth"."uid"()));



CREATE POLICY "Allow Authenticated SELECT" ON "public"."users" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "id"));



CREATE POLICY "Allow users to DELETE own profile" ON "public"."users" FOR DELETE TO "authenticated" USING (("id" = "auth"."uid"()));



CREATE POLICY "Allow users to UPDATE own profile" ON "public"."users" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"()));



CREATE POLICY "Customers can view their booking services" ON "public"."booking_services" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."bookings" "b"
  WHERE (("b"."id" = "booking_services"."booking_id") AND ("b"."customer" = "auth"."uid"())))));



CREATE POLICY "Enable access for professionals on their bookings" ON "public"."bookings" USING ((EXISTS ( SELECT 1
   FROM "public"."stylists" "sp"
  WHERE (("sp"."id" = "bookings"."stylist") AND ("sp"."id" = "auth"."uid"())))));



CREATE POLICY "Enable access to own notifications" ON "public"."notifications" USING (("auth"."uid"() = "id"));



CREATE POLICY "Enable all access for admins" ON "public"."booking_services" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Enable all access for admins" ON "public"."bookings" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Enable all access for admins" ON "public"."cancellation_policies" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Enable all access for admins" ON "public"."customer_addresses" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Enable all access for admins" ON "public"."notifications" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Enable all access for admins" ON "public"."reviews" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Enable all access for admins" ON "public"."service_categories" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Enable all access for admins" ON "public"."services" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Enable all access for admins" ON "public"."stylists_availability" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Enable all access for admins" ON "public"."stylists_services" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Enable full access for customers on their own addresses" ON "public"."customer_addresses" USING ((EXISTS ( SELECT 1
   FROM "public"."customers" "c"
  WHERE (("c"."id" = "customer_addresses"."customer_id") AND ("c"."id" = "auth"."uid"())))));



CREATE POLICY "Enable full access for customers on their own bookings" ON "public"."bookings" TO "authenticated" USING (("customer" = "auth"."uid"()));



CREATE POLICY "Enable full access for customers on their own reviews" ON "public"."reviews" USING ((EXISTS ( SELECT 1
   FROM "public"."customers" "c"
  WHERE (("c"."id" = "reviews"."customer_id") AND ("c"."id" = "auth"."uid"())))));



CREATE POLICY "Enable full access for professionals on their own availability" ON "public"."stylists_availability" USING ((EXISTS ( SELECT 1
   FROM "public"."stylists" "sp"
  WHERE (("sp"."id" = "stylists_availability"."stylists_id") AND ("sp"."id" = "auth"."uid"())))));



CREATE POLICY "Enable full access for professionals on their own services" ON "public"."stylists_services" USING ((EXISTS ( SELECT 1
   FROM "public"."stylists" "sp"
  WHERE (("sp"."id" = "stylists_services"."stylists_id") AND ("sp"."id" = "auth"."uid"())))));



CREATE POLICY "Enable public read access" ON "public"."cancellation_policies" FOR SELECT USING (("is_active" = true));



CREATE POLICY "Enable public read access" ON "public"."reviews" FOR SELECT USING (true);



CREATE POLICY "Enable public read access" ON "public"."stylists_availability" FOR SELECT USING (("is_available" = true));



CREATE POLICY "Enable public read access for active categories" ON "public"."service_categories" FOR SELECT USING (("is_active" = true));



CREATE POLICY "Enable public read access for active services" ON "public"."services" FOR SELECT USING (("is_active" = true));



CREATE POLICY "Enable public read access for available services" ON "public"."stylists_services" FOR SELECT USING (("is_available" = true));



CREATE POLICY "Enable read access for authenticated custmers" ON "public"."service_categories" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for authenticated customers" ON "public"."services" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for customers on their booking services" ON "public"."booking_services" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."bookings" "b"
     JOIN "public"."customers" "c" ON (("b"."customer" = "c"."id")))
  WHERE (("b"."id" = "booking_services"."booking_id") AND ("c"."id" = "auth"."uid"())))));



CREATE POLICY "Enable read access for professionals on reviews about them" ON "public"."reviews" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."stylists" "sp"
  WHERE (("sp"."id" = "reviews"."stylists_id") AND ("sp"."id" = "auth"."uid"())))));



CREATE POLICY "Enable read access for professionals on their booking services" ON "public"."booking_services" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."bookings" "b"
     JOIN "public"."stylists" "sp" ON (("b"."stylist" = "sp"."id")))
  WHERE (("b"."id" = "booking_services"."booking_id") AND ("sp"."id" = "auth"."uid"())))));



CREATE POLICY "Enable read access for professionals with bookings" ON "public"."customer_addresses" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."bookings" "b"
     JOIN "public"."stylists" "sp" ON (("b"."stylist" = "sp"."id")))
  WHERE (("b"."address" = "customer_addresses"."id") AND ("sp"."id" = "auth"."uid"())))));



CREATE POLICY "Stylists can view assigned booking services" ON "public"."booking_services" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."bookings" "b"
  WHERE (("b"."id" = "booking_services"."booking_id") AND ("b"."stylist" = "auth"."uid"())))));



ALTER TABLE "public"."booking_cancellation_policies" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."booking_services" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."cancellation_policies" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."customer_addresses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."deals" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."payment_audit_logs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "payment_audit_logs_select_own" ON "public"."payment_audit_logs" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."payments" "p"
  WHERE (("p"."id" = "payment_audit_logs"."payment_id") AND ("p"."customer_id" = "auth"."uid"())))));



ALTER TABLE "public"."payment_verifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."payments" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "payments_select_own" ON "public"."payments" FOR SELECT TO "authenticated" USING (("customer_id" = "auth"."uid"()));



ALTER TABLE "public"."reviews" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."service_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."services" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."stylists_availability" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."stylists_services" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_refund_quote"("p_payment_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_refund_quote"("p_payment_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_refund_quote"("p_payment_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_booking_with_services"("p_customer_id" "uuid", "p_stylist_id" "uuid", "p_scheduled_at" timestamp with time zone, "p_address_id" "uuid", "p_notes" "text", "p_items" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_booking_with_services"("p_customer_id" "uuid", "p_stylist_id" "uuid", "p_scheduled_at" timestamp with time zone, "p_address_id" "uuid", "p_notes" "text", "p_items" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_booking_with_services"("p_customer_id" "uuid", "p_stylist_id" "uuid", "p_scheduled_at" timestamp with time zone, "p_address_id" "uuid", "p_notes" "text", "p_items" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."reschedule_booking"("p_booking_id" "uuid", "p_new_stylist_id" "uuid", "p_new_scheduled_at" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."reschedule_booking"("p_booking_id" "uuid", "p_new_stylist_id" "uuid", "p_new_scheduled_at" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."reschedule_booking"("p_booking_id" "uuid", "p_new_stylist_id" "uuid", "p_new_scheduled_at" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "service_role";



GRANT ALL ON TABLE "public"."booking_cancellation_policies" TO "anon";
GRANT ALL ON TABLE "public"."booking_cancellation_policies" TO "authenticated";
GRANT ALL ON TABLE "public"."booking_cancellation_policies" TO "service_role";



GRANT ALL ON SEQUENCE "public"."booking_cancellation_policies_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."booking_cancellation_policies_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."booking_cancellation_policies_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."booking_services" TO "anon";
GRANT ALL ON TABLE "public"."booking_services" TO "authenticated";
GRANT ALL ON TABLE "public"."booking_services" TO "service_role";



GRANT ALL ON TABLE "public"."bookings" TO "anon";
GRANT ALL ON TABLE "public"."bookings" TO "authenticated";
GRANT ALL ON TABLE "public"."bookings" TO "service_role";



GRANT ALL ON TABLE "public"."cancellation_policies" TO "anon";
GRANT ALL ON TABLE "public"."cancellation_policies" TO "authenticated";
GRANT ALL ON TABLE "public"."cancellation_policies" TO "service_role";



GRANT ALL ON TABLE "public"."customer_addresses" TO "anon";
GRANT ALL ON TABLE "public"."customer_addresses" TO "authenticated";
GRANT ALL ON TABLE "public"."customer_addresses" TO "service_role";



GRANT ALL ON TABLE "public"."customers" TO "anon";
GRANT ALL ON TABLE "public"."customers" TO "authenticated";
GRANT ALL ON TABLE "public"."customers" TO "service_role";



GRANT ALL ON TABLE "public"."deals" TO "anon";
GRANT ALL ON TABLE "public"."deals" TO "authenticated";
GRANT ALL ON TABLE "public"."deals" TO "service_role";



GRANT ALL ON SEQUENCE "public"."deals_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."deals_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."deals_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."payment_audit_logs" TO "anon";
GRANT ALL ON TABLE "public"."payment_audit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."payment_audit_logs" TO "service_role";



GRANT ALL ON SEQUENCE "public"."payment_audit_logs_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."payment_audit_logs_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."payment_audit_logs_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."payment_verifications" TO "anon";
GRANT ALL ON TABLE "public"."payment_verifications" TO "authenticated";
GRANT ALL ON TABLE "public"."payment_verifications" TO "service_role";



GRANT ALL ON SEQUENCE "public"."payment_verifications_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."payment_verifications_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."payment_verifications_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."payments" TO "anon";
GRANT ALL ON TABLE "public"."payments" TO "authenticated";
GRANT ALL ON TABLE "public"."payments" TO "service_role";



GRANT ALL ON TABLE "public"."reviews" TO "anon";
GRANT ALL ON TABLE "public"."reviews" TO "authenticated";
GRANT ALL ON TABLE "public"."reviews" TO "service_role";



GRANT ALL ON TABLE "public"."service_categories" TO "anon";
GRANT ALL ON TABLE "public"."service_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."service_categories" TO "service_role";



GRANT ALL ON TABLE "public"."services" TO "anon";
GRANT ALL ON TABLE "public"."services" TO "authenticated";
GRANT ALL ON TABLE "public"."services" TO "service_role";



GRANT ALL ON TABLE "public"."stylists" TO "anon";
GRANT ALL ON TABLE "public"."stylists" TO "authenticated";
GRANT ALL ON TABLE "public"."stylists" TO "service_role";



GRANT ALL ON TABLE "public"."stylists_availability" TO "anon";
GRANT ALL ON TABLE "public"."stylists_availability" TO "authenticated";
GRANT ALL ON TABLE "public"."stylists_availability" TO "service_role";



GRANT ALL ON TABLE "public"."stylists_services" TO "anon";
GRANT ALL ON TABLE "public"."stylists_services" TO "authenticated";
GRANT ALL ON TABLE "public"."stylists_services" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






