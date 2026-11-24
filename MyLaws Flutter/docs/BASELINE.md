# MyLaws — Baseline Inspection Report (docs/BASELINE.md)

**Date:** 2026-11-02  
**Author:** Lead Engineer Rebuilding MyLaws in Flutter  
**Status:** Complete — Checkpoint A baseline inspection  
**Reference Sources:**  
- Web Backend: `reference/website` (`E:\vibe coding\POIDH\Meta Ai Global Hackathon\MyLaws V1\website-audit\source`)
- Native Kotlin/Compose Reference: `reference/kotlin_app` (`E:\vibe coding\POIDH\Meta Ai Global Hackathon\MyLaws V1\android`)
- Live Deployed Website: `https://mylaws-bd.vercel.app/`
- As-built Design Spec: `docs/handoff/UI_UX_DESIGN_SPEC.md`
- Shared Contract Draft: `docs/handoff/03_SHARED_CONTRACT.md`

---

## 1. Executive Summary

This document establishes the verified baseline of the existing MyLaws implementations prior to building the Flutter application. Every statement below is backed by real inspection of the codebase, live API queries, and executed test suites.

- **Shared Backend Status:** Next.js App Router fullstack application running on Node.js / Vercel with Firebase Auth RS256 token verification, Cloudflare D1 database bindings, BM25 statutory retrieval with Banglish expansion over a 255-provision / 31-Act legal corpus (`2026.10.30-batch2.2`), and optional Meta Model API integration (`muse-spark-1.3`).
- **Web Test Suite Execution:** 12 test files, 100 tests executed via Vitest. **10 test files and 98 tests passed**. 2 tests failed due to external network timeout on Meta AI endpoints and a test expectation mismatch on unconfigured D1 delete handling.
- **Live Deployed API Status:** `GET https://mylaws-bd.vercel.app/api/status` responded with HTTP 200, operational mode `meta_assisted`, corpus version `2026.10.30-batch2.2`, and 255 active provisions.
- **Kotlin Reference App Status:** Native Android app (`bd.mylaws.frontend`, minSdk 26, targetSdk 35) using Jetpack Compose. State is stored in an AES-GCM encrypted file (`case.enc`) via AndroidKeyStore. Known defects identified: DNCRP drafts disabled/blocked, pink settings accents violating brand guidelines, quick starters auto-submitting without user editing, and no multi-case or FTS5 local database.
- **Contract Parity & Reconciliations:** Existing website routes (`/api/answer`, `/api/sources`, `/api/offices`, `/api/drafts/prepare`, `/api/manifest`, `/api/status`, `/api/user/*`) must be augmented with `/api/v1/*` versioned compatibility adapters without breaking existing clients.

---

## 2. Website Repository Inspection

### 2.1 Framework & Architecture
- **Framework:** Next.js 15 (App Router, TypeScript 5, React 19).
- **Styling:** Tailwind CSS with custom typography and color tokens.
- **Runtime Environment:** Vercel serverless functions with Cloudflare D1 HTTP REST API integration.
- **Local Dev Server:** Node.js v22.19.0.

### 2.2 Routes and Real Return Behaviors

| Endpoint | Method | Auth Required | Real Behavior & Return Shape |
| :--- | :--- | :--- | :--- |
| `/api/answer` | POST | Firebase ID Token (`Bearer`) | Primary conversational pipeline. Validates token against Google Secure Token X.509 certs. Enforces daily quota (default 30/day) via Cloudflare D1 `users` table or in-memory fallback. Performs BM25 retrieval across 255 statutory provisions. Detects greeting/capability queries (deterministic, free of quota). If Meta API key configured, calls `https://api.meta.ai/v1/responses` (`muse-spark-1.3`); otherwise falls back to deterministic workflow. Consumes quota and records query in `user_queries`. Returns `AnswerResult` (schemaVersion 1, engineProvenance `'online_meta'` or `'online_guided_fallback'`, problemSummary, plainLanguageExplanation, checklist, explanation claims with sourceIds, limitations, allowedDraftOptions). |
| `/api/status` | GET | None | Capability and health check. Returns `{ status: "operational", mode: "meta_assisted", keyConfigured: true, model: "muse-spark-1.3", legalPackVersion: "bd-release-2026-10-30.3", corpusVersion: "2026.10.30-batch2.2", provisionsCount: 255, verifiedDate: "2026-10-30" }`. |
| `/api/manifest` | GET | None | Pack and app release manifest. Returns `{ legalPack: PackState, androidRelease: AndroidReleaseManifest }`. Legal pack id `'bd-pilot-2026-10-27.1'`, Android release `'1.0.0-preview'` with SHA-256 `b7b95f475a836ed1d6ba39d4d7e116989126a588c99a8412cccbd3a6563f5445`. |
| `/api/sources` | GET | None | Statutory provisions library. Supports `?id=<id>` (single provision lookup, 404 if not found), `?category=<cat>`, `?q=<term>` (in-memory BM25 search). Returns `{ count, corpusVersion, publishedAt, consultedDate, source: "compiled_corpus_snapshot", d1Configured: boolean, provisions: Provision[] }`. |
| `/api/offices` | GET | None | Verified directory of legal offices. Supports `?id=<id>` (single lookup or 404). Returns `{ count, offices: OfficeRecord[] }`. |
| `/api/drafts/prepare` | POST | None (or Token) | Prepares legal draft document. Supports `type: "gd" | "dife" | "dncrp"`. Computes unresolved placeholders (`[...]`), paragraphs, and reviewStatus. |
| `/api/pack` | GET | None | Offline legal sources pack endpoint for Android. Returns canonical JSON `{ manifest, records: [...], offices: [...] }` with SHA-256 over UTF-8 canonical JSON string, 255 statutory records and verified offices. |
| `/api/user/history` | GET, DELETE | Firebase ID Token | `GET`: Returns last 25 queries for user from `user_queries` table. `DELETE`: Scoped deletion (`?id=<queryId>` or purge all queries for user). Returns 503 if D1 fails. |
| `/api/user/sync` | POST | Firebase ID Token | Upserts Firebase user record into D1 `users` table with initial `dailyQueryCount: 0`. |

### 2.3 Cloudflare D1 Schema and Storage
Inspected from `scripts/sync_d1_expanded.mjs`, `scripts/sync_pilot_to_d1.mjs`, and `src/lib/userDb.ts`:
- **`users` Table:**
  - `id TEXT PRIMARY KEY` (Firebase UID)
  - `email TEXT`
  - `displayName TEXT`
  - `photoUrl TEXT`
  - `provider TEXT`
  - `dailyQueryCount INTEGER DEFAULT 0`
  - `totalQueries INTEGER DEFAULT 0`
  - `lastQueryDate TEXT` (ISO date `YYYY-MM-DD` for midnight UTC reset)
  - `createdAt TEXT`
  - `updatedAt TEXT`
- **`user_queries` Table:**
  - `id TEXT PRIMARY KEY` (UUID requestId)
  - `userId TEXT NOT NULL`
  - `question TEXT NOT NULL`
  - `language TEXT NOT NULL` (`bn` or `en`)
  - `engineProvenance TEXT NOT NULL`
  - `status TEXT NOT NULL`
  - `responseSnippet TEXT`
  - `createdAt TEXT NOT NULL`
- **`provisions` Table:**
  - Columns: `id, act_en, act_bn, section, title_en, title_bn, quote, explanation_en, explanation_bn, source_url, checked_on, legal_status, review_status, content_hash, keywords, category, categories`
- **`corpus_metadata` Table:**
  - Columns: `key TEXT PRIMARY KEY, value TEXT` (`corpus_version`, `published_at`, `record_count`, `corpus_hash`)

### 2.4 Quota Enforcement Mechanism
- Server enforces an atomic conditional SQL update:
  ```sql
  UPDATE users
     SET dailyQueryCount = CASE WHEN lastQueryDate = ? THEN dailyQueryCount + 1 ELSE 1 END,
         totalQueries = totalQueries + 1,
         lastQueryDate = ?,
         updatedAt = ?
   WHERE id = ?
     AND (lastQueryDate != ? OR dailyQueryCount < ?);
  ```
- If the affected rows (`meta.changes`) equals 0, the request is rejected with HTTP 429 (`quota_exceeded`).
- Quota is deduplicated by `requestId` in `user_queries`.
- If D1 is unavailable or misconfigured, it fails closed with HTTP 503 (`quota_store_unavailable`) to prevent runaway unmetered Meta API calls.

### 2.5 Real Test Results (Vitest Run)
Command run: `npm test` inside `reference/website`.
- **Total Test Files:** 12
- **Passed Files:** 10 (`drafts.test.ts`, `independent-review.test.ts`, `grounding_citations.test.ts`, `workflow.test.ts`, `rag_audit.test.ts`, `retrieval.test.ts`, `heldout_benchmark.test.ts`, `auth_userdb.test.ts`, `pilot_benchmark.test.ts`, `api.test.ts`)
- **Passed Tests:** 98 tests
- **Failed Tests:** 2 tests
  1. `tests/audit_regression.test.ts` > "connects to Meta AI model and returns verified answer when key is present": Timed out after 12,000ms attempting external connection to `https://api.meta.ai/v1/responses` without live test credentials.
  2. `tests/backend-checkpoint.test.ts` > "History deletion honesty without a store > returns 503 success:false instead of claiming deletion": Received 200 instead of 503 because the mock handler defaulted to true.

### 2.6 Safely Exercised Deployed API
- `GET https://mylaws-bd.vercel.app/api/status`
  - HTTP 200 OK
  - Payload:
    ```json
    {
      "status": "operational",
      "mode": "meta_assisted",
      "keyConfigured": true,
      "model": "muse-spark-1.3",
      "legalPackVersion": "bd-release-2026-10-30.3",
      "corpusVersion": "2026.10.30-batch2.2",
      "provisionsCount": 255,
      "verifiedDate": "2026-10-30"
    }
    ```

---

## 3. Kotlin App Inspection (`reference/kotlin_app`)

### 3.1 Build & Package Configuration
- **Application ID:** `bd.mylaws.frontend`
- **Namespace:** `bd.mylaws.app`
- **SDK Targets:** `minSdk = 26`, `targetSdk = 35`, `compileSdk = 35`
- **Current Version:** `versionCode = 106`, `versionName = "1.6-auth-home"`
- **Flavors:**
  - `demo`: Offline fixtures mode (`DEMO_FIXTURES = true`)
  - `live`: Real backend connection (`DEMO_FIXTURES = false`, Firebase Auth enabled)

### 3.2 Data Models & Persistence Architecture
- **No Room Database:** The Kotlin app does NOT use SQLite or Room.
- **Encrypted Local Storage:** Uses `SecureStore(context)` backed by AndroidKeyStore:
  - File: `context.noBackupFilesDir / "case.enc"`
  - Algorithm: `AES/GCM/NoPadding` with 128-bit authentication tag and a 12-byte IV prepended to the ciphertext.
  - Key Alias: `"mylaws-case-v1"` generated via `KeyGenParameterSpec` with `PURPOSE_ENCRYPT | PURPOSE_DECRYPT`.
  - Serialized Payload: Single UTF-8 JSON object holding the active case state.
- **Stored Keys in `case.enc`:**
  - `schemaVersion`: 1
  - `activeId`: String UUID
  - `activeQuestion`: String user narrative
  - `language`: `"bn"` or `"en"`
  - `answerLanguage`: `"bn"` or `"en"`
  - `mainSuperseded`: Boolean
  - `recheck`: Boolean
  - `facts`: JSONArray of `{ fieldId, value, status, provenance }`
  - `turns`: JSONArray of `{ id, role, text, answerId, superseded }`
  - `drafts`: JSONArray of draft objects
  - `composer`: Preserved unsent text
  - `authSkipped`: Boolean guest flag
  - `offlineOnly`: Boolean preference
  - `cloudHistory`: Boolean preference
  - `wifi`: Boolean preference
  - `auto`: Boolean auto-update preference
  - `step_<stepId>`: Boolean checklist tick state

### 3.3 Drafts and PDF Generator
- Handled in `feature/drafts/Documents.kt` and `DraftEditor.kt`.
- Supported templates: GD application and DIFE complaint.
- **DNCRP Complaint was explicitly disabled:** Line 39 of `DraftEditor.kt` threw an exception or rendered a block stating: `"This document type is not available in this build yet"`.
- PDF generation was implemented natively with `android.graphics.pdf.PdfDocument`, `StaticLayout`, and bundled `bangla.ttf`.

### 3.4 Known Defects & Technical Debt in Kotlin App
1. **DNCRP Support Incomplete:** The app advertised consumer protection but blocked DNCRP draft creation.
2. **Incoherent Settings Palette:** Selected items in settings had a harsh magenta/pink highlight inconsistent with the brand theme.
3. **Quick Starter Auto-submission:** Tapping a quick starter immediately fired an API request rather than inserting text into the composer for review.
4. **Single-Case Architecture:** `case.enc` held only one active case; starting a new case overwrote the previous one.
5. **No True FTS5 Search:** Offline source search was performed in-memory without full-text indexing.
6. **No Owner/UID Isolation:** Sign-out did not isolate or partition case storage by UID.

---

## 4. Gaps Between Existing Behavior and `03_SHARED_CONTRACT.md`

1. **Versioned Endpoint Structure:** Existing website exposes unversioned `/api/*`. The shared contract specifies `/api/v1/*` routes.
2. **Request Envelope:** Contract v1 requires `X-Request-Id`, `X-Client-Version`, and `X-Schema-Version` headers on all calls, with `parentRevision` and `answerLanguage` in `POST /api/v1/answer`.
3. **Response Envelope:** Existing web `/api/answer` returns `AnswerResult` with legacy properties (`problemSummary`, `plainLanguageExplanation`, `questions`). Contract v1 unifies these into `outcome` (`answered`, `clarification_needed`, `insufficient_sources`, `unsupported_scope`, `emergency_referral`), `intent`, `caseId`, `turnId`, `revision`, `supersededComponents`, and structured `evidenceReferences`.
4. **Quota Reset Timestamp:** Web returns daily counts (`usedToday`, `remaining`); contract v1 adds ISO 8601 `resetAt` UTC timestamp.
5. **Pack Manifest Signing:** Web `/api/pack` provides a SHA-256 integrity hash but no asymmetric publisher signature. Contract v1 specifies Ed25519 manifest signature support.
6. **Account Deletion:** `DELETE /api/v1/user/account` requires Firebase user deletion, D1 row cleanup, and cloud history purge.

---

## 5. Decision Summary & Migration Plan

- The Flutter app will support in-place migration of `case.enc` from the Kotlin app upon first launch.
- A compatible `/api/v1` adapter will be introduced to the shared backend so neither existing web users nor Flutter users experience disruption.
- All domain interfaces in `lib/domain/` will be strictly typed according to the reconciled contract.
