-- Phase B: server-authoritative XP ledger (Edge Function writes via service role).

create table if not exists public.xp_ledger (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  source text not null,
  ref_id text,
  amount int not null check (amount > 0),
  created_at_utc timestamptz not null,
  status text not null check (status in ('accepted', 'rejected')),
  reject_reason text,
  server_received_at timestamptz not null default now()
);

-- Natural-window dedupe: one credit per (user, source, ref_id) when ref_id is set.
create unique index if not exists xp_ledger_user_source_ref_unique
  on public.xp_ledger (user_id, source, ref_id)
  where ref_id is not null;

create index if not exists xp_ledger_user_status_idx
  on public.xp_ledger (user_id, status);

create index if not exists xp_ledger_user_created_idx
  on public.xp_ledger (user_id, created_at_utc);

alter table public.xp_ledger enable row level security;

-- Users may read their own rows only; INSERT/UPDATE via service role (Edge Function).
create policy xp_ledger_select_own
  on public.xp_ledger
  for select
  using (auth.uid() = user_id);
