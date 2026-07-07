-- XP Ledger table for Brain Clean
create table if not exists public.xp_ledger (
  id uuid primary key,
  source text not null,
  ref_id text,
  amount integer not null check (amount > 0),
  created_at_utc timestamptz not null,
  device_id text not null,
  signature text not null,
  sync_state text not null default 'pendingVerify',
  created_at timestamptz default now()
);

create index if not exists xp_ledger_device_source_idx 
  on public.xp_ledger (device_id, source, created_at_utc);

-- Row Level Security: disable for service role, no user login required
alter table public.xp_ledger enable row level security;

create policy "service_role_all" on public.xp_ledger
  for all using (true) with check (true);
