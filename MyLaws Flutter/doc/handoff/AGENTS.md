# AGENTS.md — MyLaws Flutter

Place this file at the root of the Flutter repository. Read it before every session.

## Project
MyLaws is a Bangladesh legal-information and document-preparation app. It explains situations in everyday Bangla and English, cites sources, gives a practical checklist and prepares optional drafts (GD, DIFE, DNCRP). It is not a lawyer, not a government authority and never files anything.

## Decisions already made
- Framework: Flutter, Android first. The Kotlin app is a read-only reference and a data-migration source.
- Shared online service: the existing website backend (Firebase Auth, Cloudflare D1, Meta Model API), extended compatibly. One service for website and app.
- Bangla and English both ship fully. Polite "আপনি".

## Reading order
1. `docs/handoff/00_START_HERE.md`
2. `docs/handoff/01_FLUTTER_UI_UX_FRONTEND_MASTER_PROMPT.md`
3. `docs/handoff/02_FLUTTER_BACKEND_AND_DATA_MASTER_PROMPT.md`
4. `docs/handoff/03_SHARED_CONTRACT.md`
5. `docs/handoff/04_ACCEPTANCE_AND_TEST_PLAN.md`
6. `docs/handoff/UI_UX_DESIGN_SPEC.md` and the two older master prompts

## Hard rules
- Never put a secret in code, `--dart-define` files, fixtures, logs, screenshots, packs or Git. Never ask the user to paste a secret into chat. Use environment-variable names and `docs/SECRETS_SETUP.md`.
- Never publish an APK, deploy to production, run a destructive migration on live data, buy a service or submit a complaint without explicit authorization. Work on branches.
- Never claim something works because it compiles. A feature is "verified" only with a named test, a device run or a live call.
- Never present a fixture, cached answer, emulator run or screenshot as live behavior, offline inference or device performance.
- Never hardcode legal facts, deadlines, quota limits, corpus counts, model names or office details in UI code. They come from the contract, the manifest or the installed pack.
- Never log raw user narratives, names, phone numbers, addresses or tokens.
- Do not add a dependency without checking pub.dev maintenance and license, and record the reason.
- Do not invent legal review, native-speaker approval, test results or hardware.
- Do not rewrite working code broadly. Make small, checkpointed changes.

## Working method
- Inspect before changing. Write the baseline first.
- Finish each checkpoint (A to F in Prompt 02) with tests, then report implemented, verified, limited or blocked with evidence.
- If a requirement conflicts with another, say so and use the source-of-truth order in Prompt 01, section 2. Do not silently choose.
- If access, credentials or hardware are missing, finish the independent work and state the exact blocker.
- Keep user-facing strings in ARB files. Keep routine implementation notes in `docs/`, not in the UI.

## Commands (fill in after bootstrap, keep current)
- Format and analyze: `dart format .` and `flutter analyze`
- Tests: `flutter test` and `flutter test integration_test`
- Debug build: `flutter run --flavor dev -t lib/main_dev.dart`
- Release build: `flutter build apk --flavor release --release` (record the exact command used and the output APK SHA-256)
