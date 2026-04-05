do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'bookings'
      and column_name = 'addrsss'
  ) and not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'bookings'
      and column_name = 'address'
  ) then
    execute 'alter table public.bookings rename column addrsss to address';
  end if;
end;
$$;

notify pgrst, 'reload schema';
