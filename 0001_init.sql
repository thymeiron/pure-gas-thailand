-- PURE GAS Thailand | initial schema; ALREADY APPLIED to project pdaukbcswsbtsjraumpf. Do not re-run on this project.
-- Public readers see only approved stations. Only designated admins may approve/verify.
create extension if not exists pgcrypto;

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.stations (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 3 and 120),
  brand text check (brand is null or char_length(brand) <= 80),
  address text check (address is null or char_length(address) <= 250),
  province text not null check (char_length(trim(province)) between 1 and 100),
  latitude double precision not null check (latitude between 5 and 21),
  longitude double precision not null check (longitude between 97 and 106),
  fuel_type text not null default 'benzine_95' check (fuel_type = 'benzine_95'),
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  submitted_by uuid not null references auth.users(id),
  photo_path text check (photo_path is null or char_length(photo_path) <= 250),
  notes text check (notes is null or char_length(notes) <= 1000),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  last_verified_at timestamptz
);
create index if not exists stations_status_idx on public.stations(status);
create index if not exists stations_coordinates_idx on public.stations(latitude,longitude);

create table if not exists public.station_reports (
  id uuid primary key default gen_random_uuid(),
  station_id uuid not null references public.stations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('confirm','not_available','incorrect')),
  note text check (note is null or char_length(note) <= 1000),
  created_at timestamptz not null default now()
);
create index if not exists station_reports_station_idx on public.station_reports(station_id,created_at desc);

alter table public.admins enable row level security;
alter table public.stations enable row level security;
alter table public.station_reports enable row level security;

-- Admin membership: user can read only own membership; cannot self-enroll.
create policy "Admin can see own membership" on public.admins
for select to authenticated using (user_id = (select auth.uid()));

-- Security-definer function tests membership without recursive RLS; never accessible to anon.
create schema if not exists private;
grant usage on schema private to authenticated;
create or replace function private.is_puregas_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.admins where user_id = (select auth.uid()));
$$;
revoke all on function private.is_puregas_admin() from public;
grant execute on function private.is_puregas_admin() to authenticated;

create policy "Anyone reads approved stations" on public.stations
for select to anon, authenticated using (status = 'approved');
create policy "Admins read all stations" on public.stations
for select to authenticated using (private.is_puregas_admin());
create policy "Users submit pending only" on public.stations
for insert to authenticated with check (
 submitted_by = (select auth.uid()) and status = 'pending'
 and reviewed_at is null and last_verified_at is null
);
create policy "Admins update stations" on public.stations
for update to authenticated using (private.is_puregas_admin()) with check (private.is_puregas_admin());

create policy "Members read own reports" on public.station_reports
for select to authenticated using (user_id = (select auth.uid()));
create policy "Admins read all reports" on public.station_reports
for select to authenticated using (private.is_puregas_admin());
create policy "Members report approved stations" on public.station_reports
for insert to authenticated with check (
 user_id = (select auth.uid()) and
 exists(select 1 from public.stations s where s.id=station_id and s.status='approved')
);

-- Public photo bucket. Anyone with a URL can view an uploaded photo.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('station-photos','station-photos',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];

create policy "Members upload images to own folder" on storage.objects
for insert to authenticated with check (
 bucket_id = 'station-photos'
 and (storage.foldername(name))[1] = (select auth.uid())::text
);
create policy "Public reads uploaded photos" on storage.objects
for select to anon, authenticated using (bucket_id = 'station-photos');

-- ADMIN BOOTSTRAP: replace UUID with your Supabase Auth user id after signing in.
-- INSERT INTO public.admins(user_id) VALUES ('PUT-YOUR-AUTH-USER-UUID-HERE');
-- Do not grant admin to untrusted users or expose a service_role key on the website.
