/// Server sync outcome — defaults to [pendingVerify] until a future Edge Function runs.
enum XpSyncState {
  pendingVerify,
  verified,
  rejected,
}
