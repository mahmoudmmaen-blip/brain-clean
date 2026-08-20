-- Brain Clean reconnect migration
-- Project: fqnlqkkgscmflmunxtwj
--
-- Run after restoring a paused project:
--   1. Dashboard → Restore project
--   2. Authentication → Providers → enable Anonymous sign-ins
--   3. SQL Editor → paste this file (idempotent)
--   4. Edge Functions: redeploy `verify-xp` and `safa-chat`
--      (secret CLAUDE_API_KEY must exist for Safa)
--
-- Client tables used by lib/:
--   user_progress, focus_journey, user_diagnostics, detox_protocol,
--   daily_snapshots, emotion_logs, xp_ledger

create extension if not exists pgcrypto;

-- Shared updated_at trigger
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- user_progress — durable recovery / counter state (one row per user)
-- ---------------------------------------------------------------------------
create table if not exists public.user_progress (
  user_id uuid primary key references auth.users (id) on delete cascade,
  start_date timestamptz,
  deductions double precision not null default 0,
  lapse_count integer not null default 0,
  slip_count integer not null default 0,
  baseline_json jsonb not null default '{}'::jsonb,
  state_json jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.user_progress enable row level security;

drop policy if exists user_progress_select_own on public.user_progress;
drop policy if exists user_progress_insert_own on public.user_progress;
drop policy if exists user_progress_update_own on public.user_progress;
drop policy if exists user_progress_delete_own on public.user_progress;

create policy user_progress_select_own
  on public.user_progress for select
  using (auth.uid() = user_id);

create policy user_progress_insert_own
  on public.user_progress for insert
  with check (auth.uid() = user_id);

create policy user_progress_update_own
  on public.user_progress for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy user_progress_delete_own
  on public.user_progress for delete
  using (auth.uid() = user_id);

drop trigger if exists user_progress_set_updated_at on public.user_progress;
create trigger user_progress_set_updated_at
  before update on public.user_progress
  for each row execute function public.set_updated_at();

grant select, insert, update, delete on table public.user_progress to authenticated;

-- ---------------------------------------------------------------------------
-- focus_journey — local-first journey snapshot (Hive journey_data_v1)
-- ---------------------------------------------------------------------------
create table if not exists public.focus_journey (
  user_id uuid primary key references auth.users (id) on delete cascade,
  journey_json jsonb not null default '{}'::jsonb,
  current_day integer,
  current_step text,
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.focus_journey enable row level security;

drop policy if exists focus_journey_select_own on public.focus_journey;
drop policy if exists focus_journey_insert_own on public.focus_journey;
drop policy if exists focus_journey_update_own on public.focus_journey;
drop policy if exists focus_journey_delete_own on public.focus_journey;

create policy focus_journey_select_own
  on public.focus_journey for select
  using (auth.uid() = user_id);

create policy focus_journey_insert_own
  on public.focus_journey for insert
  with check (auth.uid() = user_id);

create policy focus_journey_update_own
  on public.focus_journey for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy focus_journey_delete_own
  on public.focus_journey for delete
  using (auth.uid() = user_id);

drop trigger if exists focus_journey_set_updated_at on public.focus_journey;
create trigger focus_journey_set_updated_at
  before update on public.focus_journey
  for each row execute function public.set_updated_at();

grant select, insert, update, delete on table public.focus_journey to authenticated;

-- ---------------------------------------------------------------------------
-- user_diagnostics — DiagnosticRepository.table
-- ---------------------------------------------------------------------------
create table if not exists public.user_diagnostics (
  user_id uuid primary key references auth.users (id) on delete cascade,
  bc_score double precision,
  pillar_matrix_bc_score double precision,
  recovery_penalty_deduction double precision,
  committed_at timestamptz,
  brain_performance double precision,
  digital_discipline double precision,
  healthy_habits double precision,
  consistency double precision,
  bhi_frozen_at timestamptz,
  bhi_frozen_bc_score double precision,
  bhi_frozen_snapshot jsonb,
  questionnaire_json jsonb,
  mapped_brain_performance double precision,
  mapped_digital_discipline double precision,
  mapped_healthy_habits double precision,
  mapped_consistency double precision,
  sleep_quality integer,
  sustained_attention integer,
  fragmentation integer,
  dopamine_seeking integer,
  task_switching integer,
  burnout integer,
  questionnaire_phase text,
  questionnaire_current_index integer,
  questionnaire_answered_count integer,
  session_json jsonb,
  brain_rot_score double precision,
  interpretation_band text,
  interpretation_ar text,
  brain_rot_answers jsonb,
  questionnaire_completed_at timestamptz,
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.user_diagnostics enable row level security;

drop policy if exists user_diagnostics_select_own on public.user_diagnostics;
drop policy if exists user_diagnostics_insert_own on public.user_diagnostics;
drop policy if exists user_diagnostics_update_own on public.user_diagnostics;
drop policy if exists user_diagnostics_delete_own on public.user_diagnostics;

create policy user_diagnostics_select_own
  on public.user_diagnostics for select
  using (auth.uid() = user_id);

create policy user_diagnostics_insert_own
  on public.user_diagnostics for insert
  with check (auth.uid() = user_id);

create policy user_diagnostics_update_own
  on public.user_diagnostics for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy user_diagnostics_delete_own
  on public.user_diagnostics for delete
  using (auth.uid() = user_id);

drop trigger if exists user_diagnostics_set_updated_at on public.user_diagnostics;
create trigger user_diagnostics_set_updated_at
  before update on public.user_diagnostics
  for each row execute function public.set_updated_at();

grant select, insert, update, delete on table public.user_diagnostics to authenticated;

-- ---------------------------------------------------------------------------
-- detox_protocol — DetoxProtocolRepository.table
-- ---------------------------------------------------------------------------
create table if not exists public.detox_protocol (
  user_id uuid primary key references auth.users (id) on delete cascade,
  boredom_befriended boolean,
  delayed_gratification_count integer,
  body_activated boolean,
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.detox_protocol enable row level security;

drop policy if exists detox_protocol_select_own on public.detox_protocol;
drop policy if exists detox_protocol_insert_own on public.detox_protocol;
drop policy if exists detox_protocol_update_own on public.detox_protocol;
drop policy if exists detox_protocol_delete_own on public.detox_protocol;

create policy detox_protocol_select_own
  on public.detox_protocol for select
  using (auth.uid() = user_id);

create policy detox_protocol_insert_own
  on public.detox_protocol for insert
  with check (auth.uid() = user_id);

create policy detox_protocol_update_own
  on public.detox_protocol for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy detox_protocol_delete_own
  on public.detox_protocol for delete
  using (auth.uid() = user_id);

drop trigger if exists detox_protocol_set_updated_at on public.detox_protocol;
create trigger detox_protocol_set_updated_at
  before update on public.detox_protocol
  for each row execute function public.set_updated_at();

grant select, insert, update, delete on table public.detox_protocol to authenticated;

-- ---------------------------------------------------------------------------
-- daily_snapshots — CloudSyncService
-- ---------------------------------------------------------------------------
create table if not exists public.daily_snapshots (
  user_id uuid not null references auth.users (id) on delete cascade,
  date date not null,
  bcs_value double precision,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, date)
);

alter table public.daily_snapshots enable row level security;

drop policy if exists daily_snapshots_select_own on public.daily_snapshots;
drop policy if exists daily_snapshots_insert_own on public.daily_snapshots;
drop policy if exists daily_snapshots_update_own on public.daily_snapshots;
drop policy if exists daily_snapshots_delete_own on public.daily_snapshots;

create policy daily_snapshots_select_own
  on public.daily_snapshots for select
  using (auth.uid() = user_id);

create policy daily_snapshots_insert_own
  on public.daily_snapshots for insert
  with check (auth.uid() = user_id);

create policy daily_snapshots_update_own
  on public.daily_snapshots for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy daily_snapshots_delete_own
  on public.daily_snapshots for delete
  using (auth.uid() = user_id);

grant select, insert, update, delete on table public.daily_snapshots to authenticated;

-- ---------------------------------------------------------------------------
-- emotion_logs — CloudSyncService
-- ---------------------------------------------------------------------------
create table if not exists public.emotion_logs (
  user_id uuid not null references auth.users (id) on delete cascade,
  timestamp timestamptz not null,
  emotion_label text,
  category text,
  recovery_impact double precision,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, timestamp)
);

alter table public.emotion_logs enable row level security;

drop policy if exists emotion_logs_select_own on public.emotion_logs;
drop policy if exists emotion_logs_insert_own on public.emotion_logs;
drop policy if exists emotion_logs_update_own on public.emotion_logs;
drop policy if exists emotion_logs_delete_own on public.emotion_logs;

create policy emotion_logs_select_own
  on public.emotion_logs for select
  using (auth.uid() = user_id);

create policy emotion_logs_insert_own
  on public.emotion_logs for insert
  with check (auth.uid() = user_id);

create policy emotion_logs_update_own
  on public.emotion_logs for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy emotion_logs_delete_own
  on public.emotion_logs for delete
  using (auth.uid() = user_id);

grant select, insert, update, delete on table public.emotion_logs to authenticated;

-- ---------------------------------------------------------------------------
-- xp_ledger — already created by 20260624120000_xp_ledger.sql; re-assert RLS
-- ---------------------------------------------------------------------------
alter table if exists public.xp_ledger enable row level security;

grant select on table public.xp_ledger to authenticated;
