# AGENTS.md

## Scope
- This file applies to the entire repository.
- Prefer small, reviewable changes that are easy to verify.

## Project Context
- Stack: Flutter/Dart (not Python).
- Main app entry: `lib/main.dart`.
- Build flavors used in this repo: `dev` and `prod`.
- Local development is primarily Android (`BUILD.md`).

## Required Workflow
1. Confirm the goal and expected behavior.
2. Inspect related code paths before editing (routes, settings, storage, iap).
3. Implement minimal changes with clear boundaries.
4. Run verification commands (at least targeted checks for changed files).
5. Update docs/comments only when behavior or usage changed.

## Verification Commands
- Install deps: `flutter pub get`
- Static checks (required): `flutter analyze`
- Targeted tests (required when logic changes):  
  `flutter test <test_path>`
- Full tests (recommended before merge):  
  `flutter test`

Do not claim completion without reporting what was actually run.

## Definition Of Done
- Changed code compiles and passes `flutter analyze`.
- Relevant tests are added/updated when behavior changes.
- Any user-visible behavior changes are documented.
- No unrelated refactors in the same change.

## Guardrails For This Repo
- Do not use Python tooling assumptions like `python -m unittest`.
- Do not commit secrets, keys, profiles, or credentials.
- Do not bypass purchase logic in release builds.
- Any Pro unlock shortcut must be development-only (non-release).
- Keep i18n consistent: if you add new localizable strings, update l10n artifacts as needed.

## IAP / Pro Mode Rules
- IAP and Pro-related code is under `lib/iap/` and `lib/settings/app_config.dart`.
- `proMode` behavior must remain explicit and auditable.
- Development convenience switches are allowed only behind debug/non-release constraints.
- Avoid introducing hidden passwords/backdoors.

## File Hygiene
- Avoid editing generated files unless regeneration is required.
- Keep line endings and formatting consistent with existing files.
- Preserve existing behavior outside the requested scope.

## Commit Hygiene
- One logical change per commit.
- Commit message should include:
  - what changed
  - why
  - how it was verified
