# Bottom Bar Git Actions Development Plan

## 1. Background and Goal

Current sync behavior couples `fetch/merge/push` into one flow, which is hard to control from the UI and hard to debug for users.

Goal: add two explicit actions in the bottom bar:

1. `Commit Local` - commit local file changes to the local Git repository.
2. `Push to GitHub` - push local commits to remote (`origin`) repository.

Design principle: keep existing auto-sync behavior compatible, while adding explicit manual controls for reliability and observability.

## 2. Scope

### In Scope

1. Add two bottom bar actions:
   1. Commit local changes.
   2. Push local commits to remote.
2. Add status feedback:
   1. Success/failure snackbar.
   2. Operation loading state (prevent duplicate taps).
3. Add pre-checks and safe guards:
   1. Remote configured check for push.
   2. No-local-change check for commit.
   3. No-outgoing-commit check for push.
4. Add unit/widget tests for new logic and UI interaction.

### Out of Scope (Phase 1)

1. Conflict resolution UI.
2. Multi-remote management.
3. Branch switching UX redesign.
4. Force push.

## 3. User Stories

1. As a user, I can manually commit my local edits before network sync.
2. As a user, I can manually push existing local commits to GitHub.
3. As a user, I can clearly know why commit/push did not run (for example, no changes, no remote, auth issue).

## 4. UX and Interaction Design

## 4.1 Bottom Bar Entry

Use the existing bottom bar area (where sort/view icons are shown now) and add two tappable actions:

1. `Commit` icon/button.
2. `Push` icon/button.

## 4.2 Click Flow

### Commit Flow

1. Tap `Commit`.
2. Optional small dialog for commit message (default prefilled, editable).
3. Run local git commit.
4. Show result:
   1. Success: "Committed N files".
   2. No changes: "No local changes to commit".
   3. Failure: show mapped error message.

### Push Flow

1. Tap `Push`.
2. Validate:
   1. remote configured.
   2. local has outgoing commits.
3. Run push.
4. Show result:
   1. Success: "Pushed successfully".
   2. Nothing to push.
   3. Failure with actionable message (auth/key/unsupported op).

## 5. Technical Design

## 5.1 Existing Code Entry Points

1. Git operations:
   1. `lib/core/git_repo.dart`
   2. `lib/repository.dart`
2. Bottom bar UI:
   1. folder list/bottom nav widgets under `lib/widgets/` and related folder view files.

## 5.2 New Service Methods (Recommended)

Add explicit repository methods:

1. `Future<CommitResult> commitLocalChanges({String? message})`
2. `Future<PushResult> pushLocalCommits()`

Where:

1. `CommitResult` includes `status`, `filesChanged`, `message`.
2. `PushResult` includes `status`, `aheadBy`, `message`.

Status enum example:

1. `done`
2. `noop`
3. `failed`

## 5.3 Validation and Guard Rules

### Commit

1. Check working tree changes before commit.
2. If clean, return `noop`.
3. Commit only local changes; do not run fetch/merge/push implicitly.

### Push

1. Check remote configuration first.
2. Check `numChangesToPush()`.
3. If `aheadBy <= 0`, return `noop` and skip native push.

## 5.4 Error Mapping

Consolidate mobile git errors into user-actionable messages:

1. auth/key mismatch.
2. remote permission denied.
3. unsupported operation (`function not implemented`).

## 6. Rollout Plan (Phased)

## Phase 0 - Refactor and Safety (Low Risk)

1. Extract commit/push helpers and result models.
2. Add unit tests for:
   1. no-change commit skip.
   2. no-outgoing push skip.
   3. mapped error surface.

## Phase 1 - UI Exposure

1. Add Commit/Push buttons in bottom bar.
2. Add loading/disabled states.
3. Add snackbar feedback.
4. Add widget tests for tap-flow and disabled logic.

## Phase 2 - Stabilization and Metrics

1. Add operation timing logs.
2. Add analytics events:
   1. `manual_commit_clicked`
   2. `manual_push_clicked`
   3. `manual_push_failed`
3. Run regression on startup/sync flows.

## 7. Testing Strategy

## 7.1 Unit Tests

1. Commit service:
   1. no local changes => noop.
   2. has changes => done.
2. Push service:
   1. no remote => failed/noop (as designed).
   2. aheadBy <= 0 => noop.
   3. push exception => failed with mapped message.

## 7.2 Widget Tests

1. Bottom bar shows Commit/Push actions.
2. Tap Commit triggers service once.
3. Tap Push disabled during operation.
4. Snackbar text shown for done/noop/failed.

## 7.3 Manual QA Checklist

1. Edit note -> Commit -> Push success.
2. No edits -> Commit noop.
3. No outgoing commits -> Push noop.
4. Remote key invalid -> Push failure message clear.
5. Auto-sync still works as before.

## 8. Risks and Mitigations

1. Risk: manual and auto-sync concurrent operations.
   1. Mitigation: reuse existing locks (`_gitOpLock`, `_networkLock`) and disable buttons during in-flight operation.
2. Risk: confusion between sync and push.
   1. Mitigation: clear button labels and separate success messages.
3. Risk: platform-specific push failures.
   1. Mitigation: preserve error mapping and add fallback guidance text.

## 9. Definition of Done

1. Two bottom bar actions are visible and usable.
2. Commit and push can run independently.
3. No-op guards prevent unnecessary push calls.
4. Added tests pass for changed logic/UI.
5. Existing sync flow has no regression in smoke testing.

## 10. Suggested Delivery Milestone

1. Day 1: Phase 0 (service + tests).
2. Day 2: Phase 1 (UI + widget tests).
3. Day 3: Phase 2 (stabilization + QA + release candidate build).

