-- Kalender: kjør dette én gang i Supabase → SQL Editor → New query → Run.
-- Lager tre tabeller i det samme prosjektet som habit trackeren. Hver bruker ser bare sine egne rader.

create table if not exists public.cal_events (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  day date not null,
  title text not null default '',
  start_time text not null default '',
  end_time text not null default '',
  color text not null default '#5B8DEF',
  updated_at timestamptz not null default now()
);
create index if not exists cal_events_user_day on public.cal_events (user_id, day);

create table if not exists public.cal_deadlines (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null default '',
  due_date date not null,
  due_time text not null default '23:59',
  done boolean not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists public.cal_notes (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  week_id text not null,
  body text not null default '',
  updated_at timestamptz not null default now(),
  primary key (user_id, week_id)
);

alter table public.cal_events    enable row level security;
alter table public.cal_deadlines enable row level security;
alter table public.cal_notes     enable row level security;

create policy "Events: read own"   on public.cal_events for select using (auth.uid() = user_id);
create policy "Events: add own"    on public.cal_events for insert with check (auth.uid() = user_id);
create policy "Events: change own" on public.cal_events for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Events: delete own" on public.cal_events for delete using (auth.uid() = user_id);

create policy "Deadlines: read own"   on public.cal_deadlines for select using (auth.uid() = user_id);
create policy "Deadlines: add own"    on public.cal_deadlines for insert with check (auth.uid() = user_id);
create policy "Deadlines: change own" on public.cal_deadlines for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Deadlines: delete own" on public.cal_deadlines for delete using (auth.uid() = user_id);

create policy "Notes: read own"   on public.cal_notes for select using (auth.uid() = user_id);
create policy "Notes: add own"    on public.cal_notes for insert with check (auth.uid() = user_id);
create policy "Notes: change own" on public.cal_notes for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Notes: delete own" on public.cal_notes for delete using (auth.uid() = user_id);
