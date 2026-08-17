-- Drops the fully permissive policy that exposed the whole XP ledger to the
-- `anon` / `authenticated` Data API roles. Writes go through the Edge Function
-- (service role), which bypasses RLS, so no replacement policy is needed.
drop policy if exists "service_role_all" on public.xp_ledger;
