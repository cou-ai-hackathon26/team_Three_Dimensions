# MyLaws Flutter — 04: Acceptance and Test Plan

Prepared 2 November 2026. Used by both prompts. A checkpoint is only reported as done when its evidence exists. Anything not run is reported as "not run", never as "passed".

---

## 1. Status vocabulary

Every capability in the final report gets exactly one status and its evidence:

- Implemented: code exists, not independently exercised.
- Verified: exercised by a named test, device run or live call, with the result recorded.
- Limited: works for a stated subset. State the limit.
- Blocked: cannot proceed. State the exact blocker and who can remove it.

Report template, one row per capability: `capability | status | evidence (test name, command, file, device) | remaining gate`.

---

## 2. Regression journeys (all must be run, results recorded)

Use synthetic cases only. Run each in Bangla, English and Banglish where it applies.

1. Equivalent Bangla, English and Banglish stories, and small spelling errors. The explicit answer language setting is respected.
2. Story, typed clarification, relevant answer without re-asking answered questions, then "বুঝিনি", then a simpler contextual reply.
3. "কোন কাগজগুলো?" and "কোথায় যাব?" resolve against the current checklist and known location. No invented mandatory documents or jurisdiction.
4. A Bengali-digit and an Arabic-digit amount correction update the correct field and new value, flow through calculations, the checklist and the draft, and mark the older guidance superseded. A sector correction (for example EPZ or public service) rechecks applicability and draft eligibility.
5. A new unrelated case (theft, land, other) does not inherit wage, identity or location facts. "help" and "us" do not misroute. A Bangladeshi employer importing goods is not treated as foreign jurisdiction, while a truly foreign incident is distinguished.
6. A real source ID with a fake remedy or deadline, an uncited Bangla legal claim, an unknown source ID, an altered quotation and a repealed or inapplicable passage are each rejected or safely limited across every displayed field.
7. Prompt injection inside the story and inside retrieved text, malformed facts and history, malformed model JSON and oversized payloads produce safe behavior.
8. Missing key, invalid or expired token, provider 429 and credit failure, timeout, network loss, cancellation and stale-response races preserve user work and show accurate provenance.
9. The same UID on website and app shares one quota. Concurrent requests cannot exceed it. Retries do not normally double charge. A D1 failure never reports a successful write or delete and never opens unlimited paid calls.
10. Draft selection, decline and edit; unresolved recipient or date; API and UI eligibility agree; inferred prefill needs review; saved drafts reopen with IDs and versions; a multi-page Bangla PDF exports and extracts correctly.
11. Airplane mode after app kill and restart: a new uncached supported question, a follow-up and correction, exact local source access, a new local draft and an exported document all work, with instrumented proof that no case-processing network call occurred.
12. Real pack and model installation; corrupt, incompatible and interrupted updates; low storage; auto-update disabled; rollback. The app stays usable. Installed offline use survives token expiry with no identity calls.
13. Reconnection respects public-update versus private-history preferences. Switching modes preserves the case and never uploads without the relevant choice.
14. All seven advertised categories have separate evidence, coverage and abstention results. Unsupported subtopics are restricted rather than advertised.
15. Legacy migration: install the old Kotlin APK with seeded conversations, drafts, checklist state and preferences, upgrade in place to the Flutter build, and confirm every item. Force a failure mid-migration and confirm the old data survives and the migration resumes.
16. Account switching and sign-out on a shared device never expose another owner's cases. Account deletion removes the Firebase user, D1 rows and cloud history after recent re-authentication.

---

## 3. Evaluation set and metrics

- About 30 distinct scenario families, each with Bangla, English and Banglish variants, plus independently written held-out families. Keep paraphrases of one family grouped so they cannot leak across training and test.
- Report separately: retrieval, applicability, claim support, factual preservation, clarification quality, abstention and coverage, action usefulness, language quality. Never merge them into one accuracy number and never promise a percentage.
- Record professional or native-language review only where it actually happened. Do not invent approval.
- Known critical defects are fixed or the affected flow is blocked before release.

---

## 4. Frontend verification matrix

Widths: 360, 390, 412dp. Themes: light, dark. Languages: bn, en. Text scale: 1.0, 1.3, 2.0. States: empty, composing, sending, clarification, answered, insufficient sources, unsupported, emergency referral, quota exhausted, offline with pack, offline without pack, error with preserved input, superseded guidance, draft incomplete, draft ready, pack downloading, pack failed.

Checks:
- Golden screenshots for the main screens across the matrix, using bundled fonts.
- Contrast computed in tests (4.5:1 text, 3:1 large text and control boundaries).
- Tap targets at least 48dp and labeled (`androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`).
- Bangla rendering strings: কর্মস্থল, সংশ্লিষ্ট, প্রয়োজনীয়, ক্ষতিপূরণ, অধিকার, বুঝিনি, ধারা ১২৩, mixed Bangla and English with Bengali digits. No clipped marks, no missing glyphs.
- The app bar does not overflow at 360dp with large text.
- Keyboard open, rotation, activity recreation, process death and predictive back.
- TalkBack pass on a real device or emulator, written up honestly.
- Release build: no demo adapter, no debug banner, no staging URL (a test asserts this).

---

## 5. Backend and security verification

- Contract tests: the server validates its responses against the JSON Schemas, and Dart validates the same fixtures and round-trips them.
- Quota and idempotency concurrency tests (parallel requests at the limit, repeated idempotency keys, ambiguous timeout).
- Token tests: expired, wrong audience, wrong project, malformed, missing.
- Input limits: oversized message, too many facts, deeply nested JSON, invalid enums.
- Secret hygiene: a secret scanner over the repository and its history; inspect the built APK for embedded keys, tokens and staging URLs; confirm nothing secret is in `--dart-define` files, logs, screenshots, packs or fixtures.
- Logging: confirm no raw narratives, names, phone numbers, addresses or tokens appear in server or client logs.
- Supply chain: list added packages with license and maintenance status. Pin versions. Prefer packages published for more than two weeks.
- Pack security: tampered manifest, wrong signature, wrong hash, zip or path traversal attempt, downgrade and revoked-manifest attempts must all fail safely and keep the working pack.
- License report: Flutter packages, bundled fonts, legal text sources, local model (including attribution requirements).

---

## 6. Offline and device verification

On a real 4 GB Android phone (record exact model, chip, Android version):
- Build and pack identity, APK SHA-256.
- Whole-app memory before and during local generation, peak memory, storage use, thermal behavior over repeated turns.
- Input, output and context sizes, time to first useful validated reply, total latency, UI responsiveness during generation.
- Define the performance budget before running. State pass or fail against it.
- Check ABI handling: on a 32-bit-only device the model tier is disabled honestly, and the guided offline tier still works.
- Check native library 16 KB page-size compatibility as required by current Google Play policy.
- If no target phone or local model is available, mark the requirement "unverified" and continue other work. An emulator or desktop run is never offered as proof of phone performance.

Fixed records: `docs/OFFLINE_DEVICE_REPORT.md` holds the table, raw measurements and the device list.

---

## 7. PDF and export acceptance

For each of GD, DIFE and DNCRP templates, export a multi-page document and check:
- Correct Bangla shaping on the rendering strings above, no missing glyphs.
- A4 size, margins, true pagination, signature space.
- Text is extractable (`pdftotext` returns the Bangla text) or the limitation is stated plainly in the UI and report.
- Placeholders for unknown values are visible and not silently blank.
- Preview, copy, PDF, print and share all come from the same document model.
- Share and save work on the real device through the platform sharing mechanism, and temporary files are cleaned up.

---

## 8. Definition of done per checkpoint

- A. Baseline and contract: baseline document, port map, schemas, fixtures, contract tests green on both sides.
- B. Online flow: live sign-in, quota and idempotency tests, one real end-to-end turn recorded, deletion endpoints.
- C. Drafts: three templates end to end, PDF acceptance passed, journeys 1 to 10 recorded.
- D. Offline guided tier: journeys 11 to 13 and 15 to 16 recorded, migration proven.
- E. Local model: benchmark recorded, or the tier is shipped disabled with the reason.
- F. Updates and settings: every settings handler tested, rollback proven, release build checked, final report written.

---

## 9. Final report (one document, `docs/ACCEPTANCE_REPORT.md`)

1. Capability table using the status vocabulary and the row template above.
2. Test and command log with dates and real outputs.
3. Known limitations and unresolved defects.
4. Release gates still open (for example native-language review, legal review, Meta data-use terms confirmed, App Check decision, Play listing and account-deletion URL).
5. The honest demo script: natural story, clarification, explanation with source, checklist, optional reviewed draft and export, a real airplane-mode case, and an appropriate refusal.

The words "perfect", "production ready", "zero hallucinations", "verified answers" and "same as ChatGPT offline" do not appear unless a specific test result backs them.
