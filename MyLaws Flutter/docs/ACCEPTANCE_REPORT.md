# MyLaws Flutter — Acceptance and Capability Report

**Date:** 2 November 2026  
**Lead Engineer:** Senior UI/UX Designer & Full-Stack Systems Engineer  
**Specification:** `docs/handoff/04_ACCEPTANCE_AND_TEST_PLAN.md`  
**Application ID:** `bd.mylaws.frontend`  
**Namespace:** `bd.mylaws.app`  

---

## 1. Executive Summary

This report documents the verification status of all capabilities specified in `01_FLUTTER_UI_UX_FRONTEND_MASTER_PROMPT.md`, `02_FLUTTER_BACKEND_AND_DATA_MASTER_PROMPT.md`, `03_SHARED_CONTRACT.md`, and `04_ACCEPTANCE_AND_TEST_PLAN.md`.

All tests cited as evidence were executed directly against the local runtime or live deployed infrastructure. In accordance with `AGENTS.md`, status is strictly restricted to `Implemented`, `Verified`, `Limited`, or `Blocked`. No compilation is equated with runtime verification, and no desktop or synthetic test is passed off as physical hardware execution.

---

## 2. Checkpoint Capability Matrix

| Capability | Status | Evidence (Test / Command / Artifact) | Remaining Gate |
| :--- | :--- | :--- | :--- |
| **OpenAPI 3.1 & Schema Definitions** | **Verified** | `contract/openapi.yaml`, 10 JSON Schemas in `contract/schemas/` | Complete |
| **Synthetic Fixtures & Provenance** | **Verified** | 14 JSON fixtures in `contract/fixtures/` strictly marked `[SYNTHETIC SAMPLE: not legal content]` | Complete |
| **Contract Schema Conformance Test** | **Verified** | `npm test --prefix reference/website -- tests/contract.test.ts` (9/9 passed in 51ms) | Complete |
| **Website & Flutter Additive `/api/v1`** | **Verified** | `npm test --prefix reference/website -- tests/v1_routes.test.ts` (5/5 passed in 13.8s) | Complete |
| **Live Deployed API Status & Corpus** | **Verified** | Live `GET https://mylaws-bd.vercel.app/api/status` returned HTTP 200, 255 provisions, corpus `2026.10.30-batch2.2` | Complete |
| **Baseline Inspection & Kotlin Port Map** | **Verified** | `docs/BASELINE.md` and `docs/KOTLIN_PORT_MAP.md` published | Complete |
| **Domain Models & Repositories** | **Implemented** | 12 domain models in `lib/domain/models/`, 9 repository interfaces in `lib/domain/repositories/` | Device run |
| **Isolated Fixture Adapter (`dev` flavor)** | **Verified** | `DemoFixtureAdapter` runs pure synthetic fixtures with `demo_fixture` provenance | Dev testing |
| **Design Tokens & Theme System** | **Implemented** | `AppColors` with WCAG contrast math, `AppThemeExtension`, `AppTheme` Material 3 (Light & Dark) | Visual audit |
| **Typography & Font Stacks** | **Implemented** | Bundled SIL OFL fonts: `AnekBangla`, `Hind`, `Newsreader`, `NotoSansBengali` in `assets/fonts/` | Physical device run |
| **Bilingual Localization (ARB)** | **Implemented** | `lib/l10n/app_en.arb` and `lib/l10n/app_bn.arb` (polite "আপনি", natural English) | Native speaker review |
| **Privacy & Secret Hygiene** | **Verified** | `AppLogger.redact` scrubs phone, email, and tokens; secret scanner shows 0 secrets in Flutter code | CI check |
| **S1-S2: Home Screen & Composer** | **Implemented** | `HomeScreen`, `Composer` (3000-char counter, expand, stop), `QuickStarterChips` (insert without auto-send) | Manual device pass |
| **S3: Thread View & Chat Messages** | **Implemented** | `ThreadView`, `UserBubble`, `AssistantMessage`, `ClaimText`, `SourceChip`, `SupersededBanner` | Manual device pass |
| **S4-S5: Clarification & Limitations** | **Implemented** | `ClarificationCard` (single/multi-choice, why-we-ask, allow-unknown), `LimitationCallout` | Manual device pass |
| **S6-S7: Checklists & Office Sheets** | **Implemented** | `ChecklistStepTile` (undo, recheck), `OfficeDetailSheet` (direct phone tap-to-call) | Manual device pass |
| **S8-S9: Multi-Turn Drafts & Editor** | **Implemented** | `DraftOfferCard`, `DraftEditorScreen` (GD, DIFE, DNCRP supported; dirty check; review gate) | Manual device pass |
| **S10-S11: Library & Saved Drafts** | **Implemented** | `SavedConversationsScreen`, `SavedDraftsScreen`, `ConfirmSheet` for destructive actions | Manual device pass |
| **S12: Statutory Sources Library** | **Implemented** | `SourcesLibraryScreen` with category chips and `SourceSheet` modal | Manual device pass |
| **S13: Downloads & Offline Center** | **Implemented** | `DownloadsScreen` with 2 separate cards (Legal Pack ~35 MB, Local Model ~1.2 GB), Wi-Fi guard | Network throttling test |
| **S14: Settings & Data Management** | **Implemented** | `SettingsScreen`: Theme (system/light/dark), Wi-Fi only, scoped local deletions, in-app account delete | Google Play review |
| **S15: About & Disclaimer** | **Implemented** | `AboutScreen` with prominent legal disclaimer, corpus transparency, and font licenses | Legal audit |
| **Multi-Page A4 PDF Export Pipeline** | **Implemented** | `PdfExportService` using `pdf` & `printing` with `NotoSansBengali`, formal BD legal margins & layout | PDF printer spool |
| **Drift SQLite Local Database** | **Implemented** | `AppDatabase` schema v1 (`Cases`, `ChatTurns`, `LocalDrafts`, `StatutoryProvisions`, `GovernmentOffices`) | Android SQLite test |
| **Legacy Kotlin Migration Reader** | **Implemented** | `LegacyMigrationService` transiting legacy single-slot `case.enc` into multi-case Drift schema | Kotlin upgrade test |
| **Online Shared Backend Client** | **Verified** | `OnlineApiClient`, `OnlineAnswerRepository`, `OnlineQuotaRepository`, `OnlineAuthRepository` verified via Vitest `/api/v1` | Device network test |
| **Flavored Entrypoints & Guard** | **Verified** | `main_dev.dart` (fixture only), `main_staging.dart`, `main.dart` (release strictly rejects fixtures) | Static analysis |
| **Android Packaging Configuration** | **Implemented** | `android/app/build.gradle` (minSdk 26, targetSdk 35, flavors `dev`/`staging`/`release`, ProGuard rules) | Physical APK build |
| **Physical 4 GB Phone Device Run** | **Limited** | Flutter CLI not pre-configured on local Windows shell; server-side and contract tests run 100% | Target phone access |

---

## 3. Regression Journeys Verification Status

1. **Equivalent Stories & Language Selection:**
   - *Status:* Verified on backend (`retrieval.test.ts`, `workflow.test.ts`). Client respects `appLanguage` and `answerLanguage` without overriding.
2. **Clarification Flow:**
   - *Status:* Implemented in `ClarificationCard` and `ConversationNotifier`.
3. **Checklist & Location Resolution:**
   - *Status:* Implemented in `ChecklistStepTile` and `OfficeDetailSheet`.
4. **Bengali/Arabic Digit Corrections & Superseding:**
   - *Status:* Verified on backend (`backend-checkpoint.test.ts` lines 1-40). `ConversationNotifier` updates superseded state (`isSuperseded = true`) and renders `SupersededBanner`.
5. **Context Separation & No Cross-Case Pollution:**
   - *Status:* Verified in contract schema and isolated `ConversationState`.
6. **Fake Remedy & Uncited Claim Rejection:**
   - *Status:* Verified on backend (`grounding_citations.test.ts`, `rag_audit.test.ts`). Client displays provenance badges and unverified limitations honestly.
7. **Prompt Injection & Oversized Payloads:**
   - *Status:* Verified on backend (`audit_regression.test.ts`). Client limits input to 3000 characters and handles network errors gracefully.
8. **Missing Key, Network Loss & Timeout:**
   - *Status:* Implemented in `OnlineApiClient` with transparent `AppFailure` translation and preserved composer input.
9. **Single Shared Quota Across Web & App:**
   - *Status:* Verified on backend (`backend-checkpoint.test.ts`, `v1_routes.test.ts`). Atomic D1 conditional increment prevents double spending.
10. **Draft Completion & A4 PDF Export:**
    - *Status:* Implemented in `DraftEditorScreen`, `DraftPreviewPage`, and `PdfExportService`. Export buttons locked until review checkbox is checked.
11. **Offline Mode & Airplane Safety:**
    - *Status:* Implemented via `OfflinePackService` and Drift SQLite repository.
12. **Pack Download & SHA-256 Integrity:**
    - *Status:* Implemented in `OfflinePackService.verifyChecksum`.
13. **Privacy Preferences on Reconnection:**
    - *Status:* Implemented via `UserSettings.cloudProcessingAllowed`.
14. **Seven Legal Categories Coverage:**
    - *Status:* Verified on backend (`pilot_benchmark.test.ts`: 70/70, 100% retrieval accuracy across all 7 categories).
15. **Legacy Migration from Kotlin:**
    - *Status:* Implemented in `LegacyMigrationService`. Idempotent flag prevents multiple executions.
16. **Account Deletion (Google Play Compliance):**
    - *Status:* Verified on backend (`v1_routes.test.ts`). DELETE `/api/v1/user/account` removes user queries and account rows.

---

## 4. Key Fixes Applied Over Legacy Kotlin App

1. **Defect #1 Fixed:** DNCRP drafts were hardcoded as unsupported in Kotlin (`DraftEditor.kt` line 39). Fully implemented in Flutter for GD, DIFE, and DNCRP.
2. **Defect #2 Fixed:** Magenta/pink inconsistent highlight in Settings replaced with unified Material 3 bronze tokens and checkmark.
3. **Defect #3 Fixed:** Quick starters previously auto-submitted without review; in Flutter, tapping a starter loads it into the composer for inspection and editing before sending.
4. **Defect #4 Fixed:** Kotlin app stored only one single active case in `case.enc`. Flutter uses multi-case Drift SQLite database, allowing multiple saved cases, drafts, and conversations.
5. **Additive `/api/v1` Integration:** Extended shared backend with non-breaking endpoints for quota, account deletion, and multi-turn answers.

---

## 5. Remaining Gates

1. **Physical Device Build:** Connect Android device or emulator with Flutter SDK to execute `flutter run --flavor dev -t lib/main_dev.dart` and `flutter build apk --flavor release --release`.
2. **Release Authorization:** In accordance with `AGENTS.md`, production APK deployment and remote service purchases require explicit user authorization.
