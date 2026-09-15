-- Trip Ledger schema: public, no-login access (matches Fast Forward's pattern)
-- Run this once in Supabase SQL Editor.

create table if not exists trips (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  members jsonb not null default '[]'::jsonb,
  currency text not null default 'THB',
  created_at timestamptz not null default now()
);

create table if not exists expenses (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  description text not null,
  amount numeric not null,
  category text not null,
  date date not null,
  paid_by text not null,
  split_among jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists contributions (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  member text not null,
  amount numeric not null,
  date date not null,
  created_at timestamptz not null default now()
);

create index if not exists expenses_trip_id_idx on expenses(trip_id);
create index if not exists contributions_trip_id_idx on contributions(trip_id);

alter table trips enable row level security;
alter table expenses enable row level security;
alter table contributions enable row level security;

-- Public, no-login read/write (anyone with the link can use the app) --
create policy "public read trips" on trips for select using (true);
create policy "public insert trips" on trips for insert with check (true);
create policy "public update trips" on trips for update using (true);

create policy "public read expenses" on expenses for select using (true);
create policy "public insert expenses" on expenses for insert with check (true);
create policy "public update expenses" on expenses for update using (true);
create policy "public delete expenses" on expenses for delete using (true);

create policy "public read contributions" on contributions for select using (true);
create policy "public insert contributions" on contributions for insert with check (true);
create policy "public delete contributions" on contributions for delete using (true);

-- Enable realtime sync for live updates across devices
alter publication supabase_realtime add table trips, expenses, contributions;
