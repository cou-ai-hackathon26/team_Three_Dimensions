# MyLaws Flutter — 02: Backend, Shared Contract, Data Layer and Offline Master Prompt

Prepared 2 November 2026. Read together with `AGENTS.md`, `01_FLUTTER_UI_UX_FRONTEND_MASTER_PROMPT.md`, `03_SHARED_CONTRACT.md` and `04_ACCEPTANCE_AND_TEST_PLAN.md`. Replaces the earlier `MyLaws_App_02_Backend_Online_Offline_Master_Prompt.md` for this implementation.

---

## 0. Assignment and scope

You are the principal backend, integration, retrieval and local-inference engineer for MyLaws. Implement the working services behind the Flutter app and complete the real online and supported offline journeys. Do not stop at architecture, fixtures or a polished sample APK.

There are two work areas. Keep their boundaries clear.

**Area A. Shared online service (the website repository).** The existing website backend (Firebase Auth, Cloudflare D1, BM25 retrieval, a deterministic workflow, Meta Model API) becomes the one reusable service for website and app. Make additive, compatible changes, add a versioned `/api/v1` adapter, and add the missing pieces (quota atomicity, idempotency, contract, scoped deletion, pack manifest publishing).

**Area B. Flutter data, domain and platform layer.** Everything under `lib/data/`, `lib/domain/` (implementations of the interfaces Prompt 01 consumes), `packages/` and `android/`: API client, auth, local database, legacy-data migration, offline engine, pack installer, optional local model plugin, drafts and PDF export, background updates and settings handlers.

Final decisions already made:
- The app is Flutter. The old Kotlin app is a read-only reference and a source of data to migrate. The website stays a website. Do not make it offline and do not rewrite it.
- Do not publish an APK, deploy to production, migrate live data destructively, purchase anything or submit a complaint without specific authorization. Work on branches and open reviewable changes. If credentials, hardware or access are missing, finish the independent work and report the exact blocker.
- If the website repository is not writable in your workspace, deliver exact additive endpoint, schema and migration changes plus fixtures for its own agent, and do not claim synchronization happened.

Website references (treat as leads, not proof):
- Repository: https://github.com/EFTAKHAR-AMIN-SAKIB/mylaws-website
- Live base supplied by the user: https://mylaws-bd.vercel.app/

The earlier workflow report said the site uses Firebase Auth, Cloudflare D1, BM25 with Banglish expansion, a deterministic workflow, Meta `muse-spark-1.3`, GD/DIFE/DNCRP drafts, and about 255 provisions across 31 Acts at `2026.10.30-batch2.2`, with a 30-per-day quota. Those are changeable data. Its "zero hallucination", "verified" and "instant fallback" claims need evidence, and the report showed a cancelled test run. Read the current source, run the tests, and never hardcode those values into the app.

---

## 1. Baseline inspection (do this first)

Write `docs/BASELINE.md` before changing anything. Cover:

1. Website repository: framework, routes (`/api/answer`, `/api/user/sync`, `/api/user/history`, `/api/sources`, `/api/offices`, `/api/drafts/prepare`, `/api/manifest`, `/api/status`, and any others), what each really returns, D1 schema and migrations, environment example file, existing tests, deployment configuration. Run existing tests and record real results. Safely exercise the deployed API only where it cannot spend quota or change data.
2. Kotlin app: data models, Room schema, DataStore keys, repositories, any offline pack format, guided-answer rules and regexes, PDF generator, prompts, settings, and known defects. Produce `docs/KOTLIN_PORT_MAP.md` (shared with Prompt 01): port, redo, or drop, with reasons.
3. Gaps between the existing behavior and `03_SHARED_CONTRACT.md`.

Do not copy an older snapshot, or an inaccurate summary, just to claim parity.

---

## 2. Service responsibilities and secrets

- **Firebase:** identity and sign-in only. Register the Android app in the intended Firebase project with the real package name and signing SHA-1 and SHA-256 fingerprints (debug and release), reuse established accounts and UIDs, and never merge accounts because unverified email strings match. Do not add Firestore just because Firebase Auth is used.
- **Shared backend:** authenticate, validate, control quota and spend, interpret case context, retrieve approved sources, apply workflow rules, call Meta, validate every returned claim, and return the canonical contract.
- **Cloudflare D1:** the verified deployed schema for approved legal records, minimal account and quota data, and intentionally saved history. If compiled, versioned source snapshots are the real retrieval source, label them as such. A configured D1 token is not evidence that an answer came from D1.
- **Meta Model API:** server-side interpretation and grounded explanation. Keep the model name configurable. Verify actual project access, request/response shape, timeout, and data-use terms (Standard versus Contributor mode matters) before calling it live. Use a bounded call budget. No multi-provider agent platform and no automatic tool or filing loop.
- **Flutter local layer:** app-private cases, drafts and preferences, plus separately installed public source packs, search index and an optional local model.

Secrets:
- Meta keys, Cloudflare tokens, Firebase Admin credentials, signing keystores and pack-signing private keys stay in server or release secret storage. They must never appear in the APK, the Dart code, `--dart-define` values (these are recoverable from the compiled app), browser bundles, packs, logs, screenshots or Git.
- The Firebase client configuration (`google-services.json`, `firebase_options.dart`) is public project configuration. Restrict and configure it properly. It does not replace server authorization.
- Never ask the user to paste a secret into chat. Provide environment-variable names and a secure setup guide (`docs/SECRETS_SETUP.md`). Run a secret scan on the repository and inspect the built APK for embedded keys before every checkpoint report.

---

## 3. The shared contract

`03_SHARED_CONTRACT.md` is the starting point, not a finished authority. Reconcile it with what the website really returns, then publish:

- `contract/openapi.yaml` and JSON Schemas for requests, responses, errors, manifests and draft documents.
- Synthetic fixtures in `contract/fixtures/` (answered, clarification, correction and superseded, insufficient sources, unsupported, emergency referral, each error code, a draft, a manifest).
- Contract tests on both sides: the server validates its responses against the schemas, and Dart validates the same fixtures and round-trips them through the Dart models.

Extend compatibly or add a versioned adapter. Do not break the existing website. Treat an endpoint list as a lead only: an endpoint named `/api/sources` is not proof it returns passages with spans. Document required website changes in `docs/WEB_APP_CONTRACT.md` and `docs/WEBSITE_ALIGNMENT.md`.

Needed capabilities (see the contract file for fields): case, turn, request, idempotency and revision IDs; explicit answer language and processing preference; typed facts with canonical field IDs, original wording, uncertainty, origin and correction history; pending clarifications; turn intent; concise reply, understanding, explanation claims, checklist, draft offers, limitations and outcome; evidence references linking each claim to a source ID, revision and passage span, resolved by trusted records; superseded components; safe typed errors with retry and quota data; actual engine provenance; installed pack and model state.

Do not repeat the full four-part answer on every turn. Every substantive legal statement in a short reply still goes through evidence validation. No unchecked free-text escape hatch.

---

## 4. Authentication, quota and history

### 4.1 Authentication
- The app sends Firebase ID tokens over TLS (`Authorization: Bearer`). The server verifies signature, expiry, audience, project and issuer with the supported Admin SDK or an equivalently configured verifier, and derives the UID server-side. A client-supplied UID, a decoded token, a CORS rule or a shared password in the APK is not authentication.
- In Dart, attach the token in an HTTP interceptor. On a 401 for an expired token, force-refresh once and retry with the same idempotency key. Preserve unsent input.
- Firebase App Check (Play Integrity) is recommended. Because the app may also be distributed as a directly shared APK, which fails Play Integrity, run App Check in monitor or soft mode first and enforce it only if distribution is Play-only. Record the decision in `docs/BACKEND_HANDOFF.md`.
- Guest mode: no online assistant. Installed sources, local drafts and offline assistance work without any live Firebase call. An expired token must not break installed offline use.
- Local private data is partitioned by owner (a UID or `guest`). Sign-out and account switching must never expose another owner's cases. Guest records stay guest-scoped unless the person explicitly moves them into an account (optional, default off).

### 4.2 Quota
- One authoritative server quota per UID, shared by web and app. The 30-per-day figure is configuration. The app shows the server's remaining count and reset time. Offline turns never consume it.
- Document the reset timezone (match the website's existing behavior; Asia/Dhaka is the natural default if none exists), which events count, and the cancellation and failure policy. A sensible default: reserve at request start, release the reservation if the provider call never started or the provider failed, consume once the provider call has been made.
- Enforce atomically with the actual D1 semantics. A SELECT followed by an unconditional UPDATE is not enforcement. Use a conditional update whose affected-row count decides success, a unique request ledger keyed by `(uid, requestId or idempotencyKey)` for deduplication, and bound SQL parameters. Handle an ambiguous upstream timeout explicitly and never claim exactly-once behavior across a third-party network. Add concurrency tests that try to exceed the limit.
- If the quota store cannot enforce spend, return a controlled limitation and offer supported local or guided functions. Never quietly allow unlimited Meta calls.
- A per-process IP map is supplementary only. Validate payload size, history and fact counts, nested fields and enums before any expensive work.

### 4.3 History, privacy and deletion
- Prefer local case storage by default and minimal quota metadata on the server. Cloud-saved history is an explicit, accurately described choice, off by default in the app. If the website currently stores history automatically, document and reconcile that across clients rather than claiming "everything stays on your phone".
- Explain cloud processing before first use: relevant case text and context go to the backend and to Meta. Keep raw narratives out of operational logs and crash reports.
- Do not upload draft names, phone numbers or full addresses for routine explanation when minimized facts suffice. Keep identity fields local and merge them locally.
- Scoped deletion endpoints and app actions: local conversations, local drafts, all local records, cloud history, and account. They are separate. Never report a successful delete or save when persistence failed. If accounts can be created in the app, implement in-app account deletion with recent re-authentication (required by Google Play policy; verify the current text), covering Firebase Auth, D1 rows and cloud history.
- Do not sync old offline conversations merely because the network returns.

---

## 5. The case and conversation pipeline (server)

Implement a bounded sequence, not necessarily separate model calls:

1. Authenticate, validate, establish case revision and request ordering, reserve quota by policy.
2. Merge the current turn with structured facts and pending clarification answers. Interpret language, negation, dates, numbers and issue identity. Respect the requested answer language independently of the detected input language.
3. Apply corrections to canonical fields before generating guidance. Check issue boundaries, jurisdiction, applicability and missing information.
4. Retrieve current statutory passages, definitions, exceptions and verified procedure and office records. Do not fix the budget at exactly three passages when a question needs related definitions or exceptions.
5. Generate a concise grounded reply and the relevant structured components from current facts, recent exchanges, pending questions and evidence.
6. Validate the whole rendered result and draft eligibility, return one coherent revision, and finalize quota and history by policy.

Rules:
- Keep assistant prose separate from authoritative case facts and evidence. Bound the context but retain confirmed values, corrections and uncertainty. Previous assistant text is never a statute. A summary must not restore a superseded amount.
- Meta receives the actual necessary structured facts. The model must genuinely shape what the app renders. Do not generate one explanation and show a different canned paragraph.
- Handle malformed JSON, unknown references, provider 401, 429, exhausted credits, timeouts and cancellation as honest typed outcomes. A reviewed deterministic fallback is allowed within its supported scope. It is labeled `online_guided_fallback`, is not a Meta response and is not a correctness guarantee.
- Immediate-danger routing may precede ordinary content, using currently verified official contacts only. No automated calls, filing or decisions about anyone's legal eligibility.

Conversation behavior to support: "বুঝিনি", "আরও সহজ করে বলুন", "কোন কাগজগুলো?", "কোথায় যাব?", "কোন ধারায়?", "Are you sure?", language changes, thanks, added facts, corrections, draft edits, and related or unrelated new issues. Answer the follow-up first, re-retrieve when it needs new evidence, avoid repeated boilerplate, and do not push a declined draft again.

Corrections: "না, ২০ হাজার নয়, ১২ হাজার" must update the actual amount field, handle Bengali digits, select the new value, recompute dependent totals, applicability, checklist, draft offer and review state, and record revision and provenance. Do not add a meaningless `corrected_fact` field and claim recalculation happened. A new unrelated case must not inherit employment, identity or location from the last one. Related issues may share a case with explicit issue scope.

Avoid fragile routing: the word "help" must not hijack a legal story into a capability overview; "paid in full" must respect negation; English "us" is not automatically the USA; a Bangladeshi employer importing from abroad does not create foreign jurisdiction. Overtime, termination, wages and appointment documents are separate issues. Theft, loss, assault and GD/FIR procedures need their own handling. Unknown facts lead to a clarification or a narrower answer.

Support Bangla, Banglish, English, mixed text and minor typos with measured tests. Never claim all phrasing or all seven categories are supported just because the corpus has seven category labels.

---

## 6. Evidence, retrieval and publication

- Use official law, gazettes and agency procedure records with provenance. Store exact original text separately from simplified explanations, translations and normalized search fields. Record stable source and revision IDs, act and section, official URL, passage boundaries, retrieval and check dates, legal status and amendment or effective date where established. Unknown effective dates stay unknown. Never invent a January 1 placeholder. Automatic schema checks are not qualified legal review, and no approval may be invented.
- Inspect current records against official sources before enabling high-consequence advice. Corpus growth is not correctness. A source URL, an official-domain badge, a content hash or a `verified` boolean does not prove the text matches the law or applies to the case. Preserve exceptions, cross-references and incident-date limits. Do not assume an older cyber statute remains active.
- Reuse the evaluated BM25 and reviewed Banglish and typo aliases where suitable. Semantic retrieval is optional and only if it measurably helps. An offline vector index needs a compatible local query encoder; stored document vectors alone are useless offline.
- Define one text normalization specification in `docs/NORMALIZATION.md` and implement it identically on the server (index build and query) and in Dart (query time), with shared test vectors. It must cover Unicode NFC, Bengali and Arabic digits, the precomposed versus decomposed forms of য়, ড় and ঢ় (NFC decomposes these, so choose and document one canonical form), ZWJ and ZWNJ handling without destroying meaning, punctuation, Banglish aliases and case folding.
- Validate every substantive visible field: summary, follow-up text, rights and options, checklist, procedure claims, draft rationale. Check exact quotes, source existence, passage support, applicability, status and date, consequential amounts, deadlines, fees and penalties, and cross-field consistency. A real source ID attached to an invented entitlement must fail. Unknown IDs must be rejected, not silently stripped while accepting the claim. Source chips follow the claims actually returned, including in follow-ups.
- Do not claim a few regexes or a second model eliminate hallucination. Use bounded reviewed rules for consequential details, conservative claim checks, and abstention or clarification when support is thin. Treat user, retrieved and model text as untrusted data. Strict JSON and prompt instructions alone do not establish grounding.
- Offices and procedures need verified coverage, territory, contact, source, checked date and limitations. Jurisdiction follows the relevant verified workplace, incident or property rules, not the nearest GPS fix, the home district or the IP location. Ask when unresolved and show a verified national referral with an uncertainty note. Recheck helplines and hours before release. No invented local office details.
- One release process for source snapshots, D1 data, public packs, indexes, templates, the source drawer and health metadata. Report the real corpus and pack version from the same data. Avoid hardcoded counts and silent 200-row limits. `/api/v1/status` separates configuration from the last live success and current capability, and does not spend a Meta request on every app launch.

---

## 7. One rules source, two interpreters

The offline "guided" engine must give consistent answers with the online guided fallback. Do not hand-maintain two sets of legal rules.

- Put reviewed guidance rules, checklist templates, issue routing tables, clarification trees, eligibility rules and Banglish aliases in **data** (versioned JSON inside the pack), not in code.
- Two small interpreters read that data: TypeScript on the server, Dart in the app. Shared golden test vectors (input facts in, expected components out) run in both and must pass identically. A change to the rules data is a pack release, not an app release.
- The evidence validator follows the same pattern: checks defined once, run on both sides, shared vectors.

---

## 8. Drafts and export

- Support GD application, DIFE citizen complaint or application, and DNCRP complaint only where each has verified applicability, template and procedure references, and end-to-end implementation. Enforce eligibility in the API and the local domain layer, not just by hiding a button. A DIFE complaint is not an inspector's notice. A GD application is not an accepted GD or FIR record. No generic GD for unsupported cases and no legally effective notice the system cannot substantiate. Tenancy agreements are out of scope.
- Versioned deterministic templates (data in the pack) are the foundation online and offline. A model may extract facts or suggest neutral wording, but must never invent guilt, allegations, evidence, dates, signatures, witnesses, addresses, recipients or reference numbers. Keep identity fields local and merge them locally.
- Ask for missing draft-specific facts only after the person selects a draft. Confirm recipient and jurisdiction, incident date versus application date, chronology, requested assistance and records. A generic recipient title does not establish local jurisdiction. Inferred prefill is not user-confirmed. Unknown details stay as conspicuous placeholders.
- Material edits to facts, sources, templates or text reset review and flag dependents. Preserve user edits and exported versions, and never silently overwrite them after a law update. Save and reopen keep IDs and versions. Nothing is uploaded or submitted automatically.
- One document model drives preview, copy, PDF, print and share.
- **PDF rendering decision (time-boxed spike, then record the result).** Bengali needs complex text shaping. The pure-Dart `pdf` package has had known problems with Indic shaping, so verify rather than assume. Evaluate in this order and choose the first that passes: (1) `pdf` plus bundled Noto Sans Bengali; (2) native Android `PdfDocument` drawing text through the platform text stack via a platform channel; (3) the platform print and HTML path (for example through `printing`). Acceptance for the chosen path: correct conjuncts and vowel signs on the strings in `04_ACCEPTANCE_AND_TEST_PLAN.md`, real A4 pagination with margins and signature space, bundled licensed fonts, and extractable text (check with `pdftotext`). If only a raster path passes, say so, do not call it embedded-font text, and tell the user in the UI that the PDF is an image.
- Save to the Downloads area through MediaStore or the Storage Access Framework, share through a `FileProvider` on user action, clean temporary files. A screen preview is not proof the exported PDF works. Verify the actual files, including multi-page output.

---

## 9. Local data layer (Flutter)

- Use Drift on SQLite (or an equally capable option you justify). Run queries in a background isolate. Private data and public legal data live in **separate databases**: an owner-scoped, encrypted-if-claimed `private.db`, and a read-only, replaceable `legal.sqlite` from the installed pack.
- Encryption: if the UI or docs say "encrypted", implement and verify it (for example SQLCipher with a key held in the Android Keystore through `flutter_secure_storage`, and confirm FTS5 and Drift still work). If you do not implement it, the app must not claim it.
- Private tables, at minimum: owners, cases, turns (with idempotency key and status), facts (with provenance and revision), pending clarifications, answer revisions (stored contract payloads), checklist state, drafts, draft versions, exports, composer drafts, preferences, quota cache, pack installs, migration ledger. You own the final schema. Version it and test migrations.
- Pending turns are written before the network call so a process kill or crash does not lose input and a retry reuses the same idempotency key.
- Preferences persist across restarts, including theme, language, answer language, larger text, Wi-Fi only, auto-update, prefer offline, cloud processing permission and history sync choice.

### 9.1 Legacy data migration from the Kotlin app
- Default assumption: the Flutter app ships under the same application ID and signing key, so it upgrades the Kotlin app in place. Confirm in `00_START_HERE.md` decisions. If the user chose a new app instead, provide an export and import path and document it.
- Reuse the Kotlin repo's Room entities and DataStore access inside `android/` to read old data on first launch and hand it to Dart over a platform channel, or read the old database file directly if simpler. Import conversations, drafts, checklist state and preferences into the new schema with a ledger so it runs once and can resume.
- The old data is never deleted by the migration. Failure shows a clear screen and keeps the legacy data. Verify by installing the old APK with seeded data, upgrading to the new build, and checking every imported item.

---

## 10. Dart HTTP and repository layer

- Use `dio` (or equivalent) with: base URL from public config, auth interceptor, request IDs, cancel tokens, timeouts, and a typed error mapper from the contract's error body to `AppFailure`. Never log request bodies.
- Repository implementations for the interfaces Prompt 01 defined: auth, conversation (send turn, cancel, retry), cases, sources, offices, drafts, quota, packs and downloads, settings, privacy and deletion.
- Request ordering and revision: one request in flight per case, a stale-revision response is discarded, a retry reuses `turnId` and `idempotencyKey`, a newer correction always wins.
- Map every contract outcome and error to UI state. Transport failures never look like completed legal responses.

---

## 11. Offline engine (Flutter)

Three separate capabilities. Say which one is active; never conceal the mode.
1. **Online assistant** through the shared backend.
2. **Installed offline sources and guided answers:** FTS5 search over the installed pack, the data-driven guidance rules from section 7, validation, and deterministic drafts and export.
3. **Optional offline model-assisted conversation** on evaluated device and model combinations.

Tier 2 is useful and ships first. It does not satisfy "generative offline". Mark tier 3 incomplete until real local generation works. A cached prior answer, a pack JSON on a server, an emulator mock, a LAN inference server or hidden cloud translation is not offline reasoning.

### 11.1 Retrieval
SQLite FTS5 with BM25 ranking over normalized columns, using the section 6 normalization and the Banglish alias table. Verify FTS5 is really compiled into the SQLite build you ship, and test tokenization on Bangla text (vowel signs, conjuncts, digits). Measure retrieval on the evaluation set, and report retrieval, applicability, claim support and abstention separately.

### 11.2 Processing mode state machine
Connectivity, processing preference and installed capability are three independent dimensions.
- No network and an installed pack: answer offline, show the offline mode chip.
- No network and no pack: explain, and offer the install screen.
- Network present and preference online: online. If online fails (provider down, quota reached), say what happened and offer the offline option or the guided fallback as a visible choice. Do not switch a private case to cloud processing, or off it, silently.
- Strict offline processing makes no case-processing network calls. Verify with instrumentation.
- Reconnecting may check for public legal-pack updates, according to settings. It never uploads offline history or changes processing mode on its own.

### 11.3 Optional local model
- Target real 4 GB physical-RAM Android phones. 2 GB phones use online or guided functions. RAM size alone is not a performance result. Virtual or extended RAM is not the baseline.
- Evaluate a compact, licensed Meta open-weights checkpoint with a compatible quantized runtime. Llama 3.2 1B Instruct is a candidate, not a foregone winner, and Bangla is not in its officially supported language list, so verify Bangla and Banglish comprehension and output quality before enabling it for legal explanations. Consider a Bangla-adapted derivative only with verified lineage, license and measurements. Do not put a huge model on a 4 GB phone because it is open-weight. Satisfy the model license obligations (attribution such as "Built with Llama", redistribution and acceptable-use terms) and show them in the app.
- Pick one justified runtime (for example ExecuTorch or a native llama.cpp integration) after inspecting checkpoint format, tokenizer and chat template, ABI, minimum Android version and license. GGUF and PTE are not interchangeable. File size is not runtime memory. Avoid an unmeasured 3B default.
- Implement it as a local Flutter plugin, `packages/mylaws_local_llm`, with a typed Pigeon interface: `getCapabilities`, `load`, `generate` (token events used internally only, never shown unvalidated), `cancel`, `unload`, `status`. Native code runs off the UI thread, loads one model at a time, bounds context and output, and handles low-memory and thermal pressure without losing the case. Use constrained or grammar-guided output where the runtime supports it and it helps. Return a clear unsupported capability on devices that cannot run it.
- Android specifics to check explicitly: many low-cost phones in the target market run 32-bit userspace, so confirm the ABI at runtime and disable the model tier honestly on `armeabi-v7a`; native libraries must be 16 KB page-size compatible under current Google Play requirements (verify); build per-ABI APKs or an AAB.
- Local generation is validated by the same evidence validator before display. If local reasoning is inadequate, fall back to guided clarification or abstention and say so.
- Benchmark on a real 4 GB phone: model, runtime, quantization, device, chip, OS, build and pack versions, available memory, peak whole-app memory, input, output and context sizes, time to first useful validated reply, total latency, UI responsiveness and repeated-turn thermal behavior. Define the budget before declaring a pass. If no target phone is available, mark the requirement unverified and continue other work.

---

## 12. Packs, downloads, updates and settings

### 12.1 Components and manifest
Version these independently, with compatibility rules: legal text, procedure directory, guidance and rules data, templates, search index and query encoder, model, tokenizer. Legal updates normally change data, rules and templates, not model weights. Do not redownload the model for every new statute record.

The manifest (see contract file) contains real component IDs, versions, byte sizes, SHA-256 hashes, coverage, supported app and schema versions, and a publisher signature. Sign the canonicalized manifest (JCS) with Ed25519. Signing keys stay server-side. The app embeds trusted public keys with key IDs, supports rotation, and honors a minimum manifest version for revocation. A checksum from an unauthenticated manifest is not authenticity, and a signature does not establish legal correctness. Provide the tooling to build, sign and verify packs (`tools/pack/`), documented, with a licenses report.

### 12.2 Installer
- Download each component as its own file over HTTPS with HTTP Range resume. Real byte progress, free-space check before starting (small native call for available storage), cancel, pause where supported, and Wi-Fi-only handling.
- Hash streaming in a background isolate. Verify hash, signature, schema and compatibility, then stage in `packs/staging/<releaseId>/` and activate by one transactional pointer switch plus atomic directory rename. Keep the previous working release until activation succeeds. Avoid archives where possible. If you must extract, bound the size and block path traversal.
- Recover safely from corruption, interruption, process death, low storage and migration. A failed update never destroys saved cases or the working pack.
- Pin in-flight turns to the source version they started with. After a relevant update, mark affected saved guidance and drafts "recheck" instead of rewriting them. Handle withdrawn or incompatible sources. Distinguish "freshness unknown", "update available" and "unsupported or withdrawn". Never claim a pack is current when the phone could not check.

### 12.3 Background work and settings
Use the current Android background-work constraints (for example `workmanager` or `background_downloader`; evaluate which fits), unique jobs and backoff. Reconnect scheduling is best effort. Also check on foreground and resume. Any download notification must contain no personal data.

Every settings control from Prompt 01 gets a real handler:
- Appearance, language and text preferences persist.
- Wi-Fi only constrains the relevant downloads and says when it is waiting for Wi-Fi.
- Auto-update laws controls public legal-data updates only. Default on for installed packs unless a user setting says otherwise. A first model install always needs a deliberate action, and models never upgrade silently.
- Manual check shows the real result, the current version, an available update or the failure.
- Prefer offline uses the installed capability and explains unavailable cases. Online processing is offered as a choice where needed, never as a hidden fallback.
- Cloud processing permission and history sync are separate from public update permission.
- Remove model, remove pack, and each delete scope are separate with proportionate safeguards.

Do not leave "preference saved, download not connected" as finished behavior, and do not fake a successful update check with a timer.

---

## 13. Observability and logging

Structured, redacted logs. No raw narratives, names, phone numbers, addresses or tokens in logs, crash reports or analytics. Request IDs on every request and typed error to support debugging. No analytics SDK unless the user asks.

---

## 14. Verification, checkpoints and delivery

Use synthetic cases and protect real user history. Separate unit and mock results, live server and Meta integration, real export checks, and physical-device offline proof. A cancelled test run is not a pass. Retrieval hit rate is not legal-answer accuracy. Never promise a percentage.

Run the regression journeys, evaluation method and security checks in `04_ACCEPTANCE_AND_TEST_PLAN.md`.

Execution checkpoints (preserve each working state, no broad rewrites):
- **A. Baseline and contract:** `docs/BASELINE.md`, port map, schemas, fixtures, contract tests on both sides, Prompt 01 interfaces agreed.
- **B. Shared online flow:** Firebase registration, token verification, atomic quota and idempotency, `/api/v1` answer, Dart repositories, live conversation with the UI, scoped deletion and account deletion.
- **C. Drafts and multi-turn acceptance:** templates, eligibility, export spike result and verified PDFs, regression journeys 1 to 10.
- **D. Local data and offline guided tier:** private database, legacy migration, installed pack and installer, FTS5 offline engine, offline journeys.
- **E. Optional local model:** plugin, evaluation, device benchmark. May ship disabled if it fails its budget.
- **F. Updates, settings and device evidence:** background updates, rollback, all settings handlers, release build, device report.

Deliverables:
- The implemented app and compatible backend changes (or exact change set for the website's own agent).
- Reproducible build and test commands; an installable APK with truthful identity and SHA-256; environment and setup instructions without secrets.
- Contract and schema examples, pack, template and source tooling, licenses.
- Docs: `docs/BASELINE.md`, `docs/BACKEND_HANDOFF.md`, `docs/WEB_APP_CONTRACT.md`, `docs/WEBSITE_ALIGNMENT.md`, `docs/NORMALIZATION.md`, `docs/SECRETS_SETUP.md`, `docs/OFFLINE_DEVICE_REPORT.md`, and an acceptance and limitations report.

The final handoff lists each capability as implemented, verified, limited or blocked with real evidence, plus the remaining release gates. Include a short honest demo: natural story, clarification, explanation and source, checklist, optional reviewed draft and export, a real airplane-mode case, and an appropriate refusal. The words "perfect", "production ready", "same as ChatGPT offline" and "zero hallucinations" are not substitutes for results.

---

## 15. Official references (recheck current versions and account capabilities)

- Firebase ID-token verification: https://firebase.google.com/docs/auth/admin/verify-id-tokens
- FlutterFire: https://firebase.flutter.dev/
- Android offline-first data layer: https://developer.android.com/topic/architecture/data-layer/offline-first
- Android WorkManager constraints: https://developer.android.com/develop/background-work/background-tasks/persistent/getting-started/define-work
- Cloudflare D1 prepared statements and batch: https://developers.cloudflare.com/d1/worker-api/prepared-statements/
- Meta models and data-use variants: https://dev.meta.ai/docs/models
- Llama 3.2 1B Instruct model card, languages and license: https://huggingface.co/meta-llama/Llama-3.2-1B-Instruct
- ExecuTorch Android LLM guidance: https://docs.pytorch.org/executorch/stable/llm/run-on-android.html
- Drift: https://drift.simonbinder.eu/
- SQLite FTS5: https://www.sqlite.org/fts5.html
- Flutter platform channels and Pigeon: https://docs.flutter.dev/platform-integration/platform-channels
- Android 16 KB page size: https://developer.android.com/guide/practices/page-sizes

This prompt is an implementation specification. It is not a fresh audit of the current repositories and not a legal certification of the corpus.
