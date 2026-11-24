# MyLaws Flutter — 01: UI/UX and Frontend Master Prompt

Prepared 2 November 2026. Read together with `AGENTS.md`, `02_FLUTTER_BACKEND_AND_DATA_MASTER_PROMPT.md`, `03_SHARED_CONTRACT.md` and `04_ACCEPTANCE_AND_TEST_PLAN.md`.

---

## 0. Assignment

You are the senior Flutter engineer and product designer for MyLaws, a Bangladesh legal-information and document-preparation assistant. Build the complete frontend of the app in Flutter. Android is the first-class and verified platform.

The framework decision is final: Flutter. The existing native Kotlin/Jetpack Compose app is a read-only reference for behavior, copy, data shapes and known defects. Do not wrap a WebView, do not use React Native, do not rewrite the website, and do not keep Kotlin screens alongside Flutter ones. Kotlin is allowed only inside `android/` for small platform channels that Flutter cannot do itself.

Implement real screens bound to real state. A visual prototype, a screenshot gallery or a fixture-only app is not the deliverable. Where live services are not yet wired, use the service interfaces from Prompt 02 and fixtures that are isolated and honestly labeled (section 12).

---

## 1. Read before writing code

1. `AGENTS.md`, then this file, then `03_SHARED_CONTRACT.md`, then Prompt 02.
2. `UI_UX_DESIGN_SPEC.md`: the as-built design of the Kotlin app (tokens, fonts, screen structure).
3. The earlier `MyLaws_App_01_UI_UX_Master_Prompt.md` and `MyLaws_App_02_Backend_Online_Offline_Master_Prompt.md`: the behavior and honesty rules this rebuild must preserve.
4. The user's hand-drawn sketch, current app screenshots and the three-screen concept image, if provided. They show layout intent only. Their sample text, numbers, names, statuses and statute references are illustrative and must never be hardcoded.
5. The Kotlin repository: inspect every screen, ViewModel, string resource, theme file and navigation graph. Write `docs/KOTLIN_PORT_MAP.md` listing, for each screen and feature, what you will port, what you will redo, and which existing defects you will not copy.

If a referenced file is missing, say so in your first report and continue with what exists. Do not invent its contents.

---

## 2. Source-of-truth order

When two sources disagree, the higher one wins:

1. Safety and honesty rules in this prompt and `AGENTS.md`.
2. `03_SHARED_CONTRACT.md` (what the app may display is what the contract can carry).
3. `UI_UX_DESIGN_SPEC.md` for colors, fonts, shape language and screen structure.
4. The user's sketch and concept images for layout intent.
5. The older Prompt 01 for behavior not covered above.

Where the as-built spec contradicts an honesty rule, the honesty rule wins. The conflicts already found are listed in `00_START_HERE.md`; follow the resolutions there. Report any new conflict you find instead of silently choosing.

---

## 3. Product experience

MyLaws helps ordinary people in Bangladesh:

1. Describe what happened and clarify important missing facts.
2. Understand the situation in everyday language, with relevant legal sources.
3. Follow a practical, ordered action checklist.
4. Optionally prepare a supported draft after reviewing the details.

The journey is a conversation, not a report generator. A follow-up such as "বুঝিনি" gets a focused, simpler reply. A material correction updates the case and marks affected guidance as superseded. A thank-you gets a short reply with no citations, checklist or repeated draft offer. Which response shape to render is decided by the contract's `intent` and `outcome`, never by guessing from text on the client.

Tone: warm, respectful, everyday Bangla with "আপনি", natural English. No forced slang, theatrical reassurance, guaranteed outcomes or repeated "As an AI" boilerplate. MyLaws helps with information and preparation. It is not a lawyer and not a government authority, and it never says it has filed, submitted or reported anything.

Product naming: English "MyLaws", Bangla "মাই লজ". Avoid unverifiable labels such as "Verified Citizen Account", "citizen command center", "zero hallucination" or "verified answer".

---

## 4. Technical foundation

### 4.1 Toolchain
- Latest stable Flutter and Dart at the time of work. Record the exact version with `flutter --version` in `docs/UI_HANDOFF.md` and pin it (for example `.fvmrc` or documented in the README).
- Android first. Choose `minSdk` as the lowest value that satisfies Firebase, the chosen local-model runtime and Flutter itself; record the decision. Meet the current Google Play target API requirement. iOS must not be broken by your choices, but it is not verified or shipped in this task.
- Lints: `flutter_lints` or stricter. `flutter analyze` must finish with zero errors and zero warnings you have not consciously suppressed.
- Check current versions and maintenance status on pub.dev before adding any package. Add a dependency only when it removes real work. Record each added package and the reason in `docs/UI_HANDOFF.md`.

### 4.2 Suggested stack (justify any deviation in writing)
- State: `flutter_riverpod` with immutable state classes (`freezed` or hand-written equivalents).
- Navigation: `go_router`.
- Localization: `flutter_localizations` plus `gen_l10n` with `app_bn.arb` and `app_en.arb`; `intl` for dates and numbers.
- Public/secure local settings: `shared_preferences` for non-sensitive preferences; secrets are handled in Prompt 02, never in the UI layer.
- Platform helpers: `url_launcher`, `share_plus`, `path_provider`; `printing` only where Prompt 02's PDF decision selects it.
- Testing: `flutter_test`, `integration_test`, `mocktail`.

### 4.3 Structure (feature-first)
```
lib/
  main.dart            # release entry point
  main_staging.dart
  main_dev.dart        # only entry point allowed to register the demo adapter
  app/                 # MaterialApp.router, theme mode, locale, bootstrap
  core/                # design system, l10n helpers, errors, logging, platform channels (UI side)
  domain/              # models and repository interfaces (shared with Prompt 02)
  features/
    auth/  home/  conversation/  clarification/  answer/  sources/
    checklist/  offices/  drafts/  drawer/  library/
    downloads/  settings/  privacy/  about/
  l10n/
assets/fonts/  assets/images/  assets/licenses/
test/  integration_test/  goldens/
```
- UI code never calls Dio, the database or a plugin directly. It depends on repository interfaces in `domain/` and on Riverpod providers. Prompt 02 owns the implementations.
- Flavors: `dev`, `staging`, `release` as Android product flavors with matching Dart entry points. Public configuration (API base URL, feature flags) comes from `--dart-define-from-file=config/<env>.json`. Secrets never go there, because `dart-define` values are recoverable from the compiled app.
- The release build must contain no demo adapter, no debug banner and no staging endpoint. Add a test that fails if the release provider graph resolves a demo or fixture implementation.

### 4.4 Errors and logging
- A sealed `AppFailure` hierarchy mirrors the contract's typed error codes plus local-only failures (storage full, migration failed, pack corrupt). Transport failures never appear as completed legal responses.
- A single `AppLogger` redacts. Raw user narratives, names, phone numbers and addresses never reach logs, crash reports or analytics. Do not add an analytics SDK.

---

## 5. Design system

### 5.1 Color tokens (from the as-built spec; start here, then verify contrast)

| Role | Light | Dark |
| :-- | :-- | :-- |
| Background (scaffold) | `#FBF9F3` | `#121518` |
| Surface / cards / composer | `#FFFFFF` | `#1B2228` |
| Surface variant | `#F0EEE8` | `#252D35` |
| Primary | `#8C6735` | `#D8AE6A` |
| On primary | `#FFFFFF` | `#261905` |
| Primary container (user bubble, callout) | `#F4ECE0` | `#3A2D17` |
| Text | `#102332` | `#F5F3ED` |
| Secondary text | `#4E6072` | `#B4BDC6` |
| Outline variant (decorative separators) | `#E2DCCE` | `#2E3740` |
| Outline (input borders, control edges) | `#807568` | derive, at least 3:1 on its surface |
| Error | `#BA1A1A` | `#FFB4AB` |

- Build `ColorScheme` explicitly from these values, not with `fromSeed`. Derive the missing roles (on-primary-container, error container, scrim, inverse) yourself and document them. Put brand-only values (callout accent bar, parchment tint) in a `ThemeExtension`.
- Dark mode is a coordinated palette, not inverted colors. Light, dark and system are all supported and persisted.
- Contrast is a hard requirement: normal text 4.5:1, large text and meaningful UI boundaries 3:1. Rough check: bronze `#8C6735` on ivory `#FBF9F3` is about 4.8:1, which passes with little margin, so use it for controls, links and labels at 14sp or larger, never for small body text. Input borders use `outline`, not `outline variant`. Compute contrast in a test, do not eyeball it.
- Replace the pink selection treatment seen in the old settings screen with a coherent brand treatment (primary container fill plus a check icon).
- Status never relies on color alone: pair color with an icon and a text label.
- No gradients, glass effects, large gold panels, decorative justice-statue animation, ornamental borders or dashboard metrics. Shadows are subtle or absent.

### 5.2 Spacing, shape, motion
- 8dp rhythm. Horizontal screen margin 20dp. Card padding 16 to 20dp. Vertical gaps 12 to 16dp.
- Radii: sheets and cards 18 to 20dp, panels and message containers 14 to 16dp, buttons and fields 12dp, badges 6 to 8dp, chips fully rounded.
- Content max width about 640dp, centered, so large phones and tablets stay readable. Phones in portrait are the design target; landscape must work without clipping.
- Motion is short and functional. Honor the system "remove animations" setting. No timed fake progress anywhere.

### 5.3 Typography
Bundle all fonts as assets (declared in `pubspec.yaml`). No runtime font downloads; if `google_fonts` is present, disable runtime fetching or remove it. Keep every font's license file in `assets/licenses/` and in the in-app licenses page.

| Use | Family |
| :-- | :-- |
| English display, headlines, summary line | Newsreader (serif) |
| English body and controls | Hind |
| Bangla headings and titles | Anek Bangla (500 and 600) |
| Bangla body and form fields | Hind Siliguri (400 and 500) |
| Printable A4 documents (Prompt 02) | Noto Sans Bengali |

Define explicit `fontFamily` plus `fontFamilyFallback` chains for each language so mixed Bangla/English strings, Bengali numerals and punctuation render with matching metrics. Verify real rendering on a device.

Type scale (sizes are `sp`; multiplied by the system text scaler and the optional "Larger text" setting):

| Role | Latin | Bangla | Line height |
| :-- | :-- | :-- | :-- |
| Display (welcome title) | 32 | 30 | 1.25 |
| Headline (summary line, titles) | 24 / 20 | 22 / 20 | 1.3 |
| Title (section headers, step titles) | 16 semibold | 17 medium | 1.35 |
| Body large (explanations) | 16 | 17 to 18 | 1.5 to 1.6 |
| Body medium (bubbles, checklist text) | 15 | 16 | 1.5 |
| Body small (disclaimers, dates) | 13 | 14 | 1.45 |
| Label (badges, chips, pills) | 12 minimum | 13 | 1.3 |

The as-built spec used an 11sp label and 15.5sp body; those are raised here for readability. Do not clip vowel marks, conjuncts or matras: set explicit line heights, test `TextHeightBehavior` choices, avoid synthetic italics, letter spacing on Bangla, and heavy bold Bangla paragraphs.

Rendering test strings (use in golden and device tests): কর্মস্থল, সংশ্লিষ্ট, প্রয়োজনীয়, ক্ষতিপূরণ, অধিকার, বুঝিনি, ধারা ১২৩, "বেতন ১২,০০০ টাকা", mixed "Labour Act ২০০৬-এর ধারা 123".

### 5.4 Component catalog
Build these once, test each in light/dark, bn/en and at large text: `AppBarShell`, `ModeStatusChip`, `LanguageCapsule`, `ProfileQuotaPill`, `QuickStarterChip`, `Composer`, `UserBubble`, `AssistantMessage`, `AnswerCard`, `ClaimText` (text with inline source chips), `SourceChip`, `SourceSheet`, `ChecklistStep`, `LimitationCallout`, `ClarificationCard`, `SupersededBanner`, `StateBanner` (error, quota, offline), `ProvenanceChip`, `DraftOfferCard`, `FactField` (with provenance label), `DocumentPreview`, `PackCard`, `ProgressRow`, `ConfirmSheet`.

---

## 6. Screens

For every screen implement loading, empty, error and offline states. Copy lives in ARB files in both languages (section 9).

### S1. Startup
Native splash (ivory background, scales mark) with `flutter_native_splash` or equivalent. Bootstrap opens the local database, loads preferences and checks auth state. No invented loading steps. If a legacy-data migration from the Kotlin app is pending (Prompt 02), show one honest screen: "আপনার সংরক্ষিত তথ্য নতুন অ্যাপে আনা হচ্ছে" with real progress or an indeterminate indicator, and a clear failure screen that never deletes the legacy data.

### S2. Auth gate
Shown to a signed-out first-time user. Scales emblem, welcome title, segmented "Sign in / Create account", "Continue with Google", email and password with show/hide, forgot-password, and "Continue without an account".
- Guest mode means: no online assistant, but installed legal sources, local drafts and installed offline assistance work. Say this in one plain sentence on the screen.
- Map Firebase error codes to everyday messages. Never show raw exception text.
- Google sign-in uses the current supported Android credential flow of the `google_sign_in` plugin; verify its current API.
- Signing out or switching accounts must not reveal another account's saved cases (data is owner-scoped in Prompt 02).

### S3. App shell and app bar
Left: drawer button, or back arrow in sub-flows. Center-left: small scales mark and "MyLaws" / "মাই লজ". Right: new-conversation action, `LanguageCapsule` (toggles app language instantly, no restart), `ProfileQuotaPill`.
- Below about 360dp, collapse the pill to the avatar and move the quota text into the dropdown. Never let the bar overflow at 360dp with large text; test it.
- `ModeStatusChip` sits below the bar or inside it on the home screen. It states the processing mode in words: "Online assistant", "Offline: installed law pack", "Offline: unavailable, install law pack", "Sample mode" (dev only). A network dot alone is never used as proof that the service works.
- `ProfileQuotaPill` dropdown: name and email, a quota meter showing the server's actual remaining count and reset time (or "unknown" when guest or offline), "Ask a question" (new conversation) and "Sign out". The quota is never a constant in the app.

### S4. Home and new conversation
- When the keyboard is closed: a small time-aware greeting with the first name if signed in, then the primary message "কী হয়েছে বলুন" / "Tell us what happened", supporting line "আপনার কথায় ঘটনাটা লিখুন। সহজ ভাষায় পরের ধাপ বুঝতে সাহায্য করব।" / "Describe the situation in your own words. We'll help you understand the next steps." Place it in the upper-middle area. When the keyboard opens, compress the greeting gracefully; do not leave a large block of empty space or debug text.
- Quick starters: three or four short chips. Source them from the installed or online coverage manifest so a chip is shown only for a topic the app can actually support. Tapping inserts editable text into the composer. It never auto-sends and never spends quota. (This replaces the as-built behavior of submitting immediately.)
- `Composer` pinned above the keyboard and system insets: multiline from 2 to about 6 lines then internal scroll, paste and text selection, whitespace-only text disables send, clearly labeled send button, a stop button while a request is active, character counter only near the server limit from the contract. Unsent text survives recoverable errors, app restarts and process death.
- A small "Legal sources" text action opens the sources library (S12). No microphone icon, no GPS icon, no attachment icon unless the Kotlin app already has a working version, in which case port it with permission, transcript review and honest availability.

### S5. Conversation thread
- Lazy list with stable IDs. User messages: subtle tinted bubble (`primary container`). Assistant text: comfortable reading width with minimal framing.
- Preserve the reader's scroll position. If new content arrives while they are reading older content, show a "latest reply" button instead of jumping.
- Genuine waiting state only: a quiet "working" row with a stop button. Do not show invented stages such as "Checking Labour Court precedents". If the contract later provides real stage events, show those exact stages.
- A cancelled or failed turn stays in the thread marked "not answered" with Retry and Edit. Retry reuses the same turn ID and idempotency key (no duplicate user turn, no double quota charge, never overwrites a newer correction). Edit changes the unanswered turn in place.
- Each assistant message carries a `ProvenanceChip` (Online assistant, Online guided answer, Offline model, Offline guided, Sample). Tapping it opens a short plain-language sheet: how this answer was produced, the legal data version it used, and what was checked. Do not use the words "verified" or "guaranteed".

### S6. Clarification
Ask one or two material questions at a time, rendered from `pendingClarifications`:
- Input types from the contract: single choice, multiple choice, text, date, amount, district/upazila (typed text is enough).
- Each question shows a short "why we ask". Offer "I don't know" and "Skip" only when the contract marks them allowed.
- Do not ask for names, phone numbers or addresses until a draft needs them.
- Answers update the same case and thread. They do not start a new conversation and do not re-ask answered questions.

### S7. Answer view
Render the contract's answer components in this order, each only when present:
1. Understanding: a short, conditional paraphrase. Not a finding that anyone broke a law.
2. Plain explanation: a short summary line, then the explanation with inline `SourceChip`s next to the claims they support. Use "Summary" or no label. Do not label it a "ruling".
3. Checklist: three to five compact steps, expandable for documents, contacts and conditions.
4. Limitations callout: parchment tint, left accent bar, an icon and a text label. Rendered only from validated `limitations` returned for this case. Never hardcode deadlines, limitation periods or legal-aid bodies in the UI.
5. Draft offer: one contextual card, only for an `eligible` draft offer from the contract.
6. Footer: source count chip, "Office info" when the checklist has an office reference, and an overflow menu (copy answer, share text, and save to cloud history only when that feature is enabled and permitted).

Rules:
- Use progressive disclosure. Do not create one endless message or repeat the same information in duplicate cards.
- Follow-ups with `intent` other than a new issue render as plain assistant messages without card chrome and do not repeat the whole answer.
- When a correction supersedes earlier guidance, mark older answer blocks with `SupersededBanner` ("Updated after your correction"), collapse them by default and keep a "show previous guidance" control. Preserve the conversation record. Mark affected checklist steps "recheck" and pause export of affected drafts until they are reviewed again.
- Outcomes `insufficient_sources`, `unsupported_scope` and `emergency_referral` each have their own calm layout. They never look like a normal answer. An emergency referral shows only verified contact information from the response, ahead of any other content.

### S8. Source detail sheet
Opened from any source chip. Shows: act title, section or article, the exact stored original passage, official link (opens externally on user tap), source and pack version, retrieved/checked dates, legal status (in force, amended, repealed, unknown), and an honest review label (for example "Machine-checked, not reviewed by a lawyer"). Keep original text, translation and plain-language explanation visually separate. A generic portal link is never presented as verification of a particular claim. If the passage is unavailable offline, say so and offer the install screen.

### S9. Checklist and office info
- Persist step state locally by case and stable step ID with the answer revision when it was ticked. Support undo. A fact or source change sets the step to "recheck" instead of silently keeping the tick. Never reuse ticks across unrelated cases.
- Separate "required documents" from "helpful records". Do not invent mandatory paperwork.
- "Office info" sheet: name, address, phone with tap-to-call (user initiated), coverage area, source and checked date. If jurisdiction is unresolved, ask for district/upazila and show a verified national referral with an uncertainty note. No decorative map and no guessed nearest office.

### S10. Draft flow
Offer, then: template choice (only eligible templates), interview, fact review, recipient confirmation, preview, export.
- Templates: GD application, DIFE complaint/application, DNCRP complaint, only as far as Prompt 02 supports each end to end. Tenancy agreements in the old spec are out of scope. An unsupported case never gets a generic GD fallback button.
- Interview and review are a sectioned form: "Needs your input" first, then "Already collected" collapsed. Every field shows its provenance: "From your chat, please confirm", "You confirmed", or "Missing". Inferred values are not treated as confirmed until the user taps confirm or edits.
- Recipient and jurisdiction: confirm the office, show whether jurisdiction is verified or unresolved, and distinguish incident date from application date.
- Preview: A4-shaped document view with true pagination. Unresolved values appear as conspicuous bracketed placeholders (text plus underline, not color alone).
- Review checkbox "I reviewed the facts and recipient". Material edits reset it.
- Actions: copy plain text, save PDF, share PDF, print. PDF/share/print stay disabled until required fields are complete and the review box is ticked. Local save of an incomplete draft is always allowed.
- A persistent line states the draft is preparation only and has not been submitted. Never imply a filing happened.
- Back navigation from a dirty draft asks before discarding (use `PopScope`).

### S11. Drawer
New conversation, Examples, Saved conversations, Drafts, Legal sources, Downloads and offline, Settings, and an Account block (name, "Signed in" or "Guest"). Compact, no bottom tab bar, no feed. A new conversation never inherits another case's facts. Do not claim "All records stay encrypted on this phone" unless Prompt 02 has implemented and verified encryption; otherwise use accurate wording such as "Your conversations are stored on this phone."

### S12. Lists: saved conversations, drafts, examples, legal sources library
- Conversations: title, date, status, search, delete with confirmation.
- Drafts: status chips (Draft, Needs review, Ready, Exported with date, Needs recheck after a law update), reopen keeps IDs and versions.
- Examples: coverage-gated sample situations that insert into the composer.
- Legal sources library: search and browse installed (or online) acts and sections, opening the same source sheet. Keep it simple.

### S13. Downloads and offline center
Two separate cards, never merged:
- Legal data: plain benefit sentence, size, installed version and release date, coverage summary taken from the manifest (never a hardcoded promise like "complete"), real progress, pause/resume/cancel where supported, "Check for updates" with the actual last result and time, "Verify files", remove.
- Offline assistant model (optional): compatibility result (RAM, CPU architecture, free space) with a plain reason when unsupported, size and storage needed, explicit confirm before download, real byte progress, errors, remove. Technical identifiers go under "Details". Show required license attribution (for example "Built with Llama") if that model is used.
Progress is real or absent. Never simulate it.

### S14. Settings
Grouped rows: Appearance (system, light, dark); Language and text (app language; answer language: same as app, বাংলা, English; larger text); Downloads and offline (Wi-Fi only, auto-update laws, prefer offline); Privacy and account (cloud processing permission, cloud history sync, hide content in app switcher, delete scopes, sign out, delete account); About.
- A control is enabled only when its handler works. Until Prompt 02 connects it, show it disabled with one short explanation. No toggle that only stores a preference.
- Public legal-pack update permission and private case cloud processing are separate controls.
- Delete scopes are separate and clearly worded: delete conversations on this phone, delete drafts on this phone, delete all local records, delete cloud history (only if signed in), delete account. "Delete local records" never implies cloud history or the account was deleted. Destructive actions confirm with the count of items affected. Delete account requires recent re-authentication and is required if the app allows account creation on Google Play; verify current Play policy.
- Preferences survive restart.

### S15. About and licenses
Version, build, installed pack versions, plain disclaimer ("মাই লজ আইনি তথ্য ও প্রস্তুতিতে সাহায্য করে; এটি আইনজীবী বা সরকারি কর্তৃপক্ষ নয়"), open source and font licenses (use Flutter's license registry plus the bundled font licenses), model license if installed.

---

## 7. Interaction rules that apply everywhere

- One request in flight per case. A late response for a stale revision is discarded and never overwrites a newer correction.
- Keep user work: composer text, answered clarifications, draft edits and checklist ticks survive errors, rotation, app kill and process death.
- Error and limit states in everyday language, each with the right next action: no network, sign-in required, token expired, quota reached, provider unavailable, timeout, insufficient sources, unsupported scope, storage full, pack corrupt. Quota reached keeps the composer usable and says offline sources and drafts still work.
- Switching between online and offline never silently changes where a private case is processed (Prompt 02, processing mode). If online is unavailable and offline is installed, say what will happen and let the person choose where a choice is needed.
- Never stream unvalidated legal claims. Show a complete validated answer or a typed outcome.
- Predictive back and system back behave correctly in every flow, including the open drawer, sheets and dirty drafts.

---

## 8. State model

Define immutable state for at least:
- Startup: loading, migrating, ready, fatal.
- Auth: guest, signed out, signed in, refreshing, session expired.
- Processing capability: online reachable or not, offline legal pack installed, offline model installed, user preference. These are independent dimensions.
- Turn: idle, sending (request ID, cancellable), failed (typed failure, retryable, preserved input), received.
- Outcome: answered, clarification needed, insufficient sources, unsupported scope, emergency referral.
- Provenance: online assistant, online guided fallback, offline model, offline guided, demo sample.
- Quota: unknown, known (limit, remaining, reset time), exhausted.
- Source sheet: loading, loaded, unavailable offline.
- Draft: not started, interviewing, reviewing facts, confirming recipient, ready, exported, needs recheck.
- Pack and model install: not installed, downloading (bytes, total), verifying, staged, activating, installed (version), update available, failed (reason), incompatible, removing.

Write a transition table in `docs/UI_HANDOFF.md` and cover it with tests.

---

## 9. Localization

- Both languages ship in full from the first build. No hardcoded user-visible strings. Use ICU plurals and placeholders. Format dates and numbers with `intl`; support Bengali digits for display.
- First launch: use the system locale if it is Bangla or English, otherwise Bangla. The user can change it in the app bar capsule or settings.
- Three language values stay separate: app language (UI), answer language (user setting, may follow app language), and detected input language (never overrides the answer language).
- Starting copy (needs native review before release):

| Situation | Bangla | English |
| :-- | :-- | :-- |
| No connection | ইন্টারনেট সংযোগ পাওয়া যাচ্ছে না। আপনার লেখা সংরক্ষিত আছে। | No internet connection. Your message is saved. |
| Quota reached | আজকের অনলাইন প্রশ্নের সীমা শেষ হয়েছে। ইনস্টল করা আইনের তথ্য ও খসড়া আগের মতোই ব্যবহার করতে পারবেন। | Today's online question limit is reached. Installed legal sources and drafts still work. |
| Not enough sources | এই বিষয়ে যথেষ্ট নির্ভরযোগ্য উৎস পাইনি, তাই অনুমান করে কিছু বলছি না। | We couldn't find enough reliable sources for this, so we won't guess. |
| Service down | এই মুহূর্তে অনলাইন সহায়তা পাওয়া যাচ্ছে না। একটু পরে আবার চেষ্টা করুন। | Online help isn't available right now. Please try again shortly. |
| Superseded | আপনার সংশোধনের কারণে এই উত্তর আপডেট হয়েছে। | Updated after your correction. |
| Draft notice | এটি শুধু প্রস্তুতির খসড়া। এটি দাখিল করা হয়নি। | This is a preparation draft. It has not been submitted. |

---

## 10. Accessibility

- Semantic headings, labels on every control and chip ("Source: Labour Act section 123, opens details"), logical focus order, visible focus, and at least 48dp touch targets (`kMinInteractiveDimension`).
- Do not clamp the text scaler. Layouts must scroll and wrap at 200% system text. Test at 1.0, 1.3 and 2.0 with long Bangla strings.
- Announce new assistant replies and errors through the current Flutter live-region or announcement API (check the current name).
- Test with TalkBack on a real device or emulator and record the result honestly, including what you could not test.
- Use `meetsGuideline` checks in widget tests (contrast, tap target size, labeled targets) on the main screens.

---

## 11. Privacy surfaces in the UI

- Before the first online use, explain in plain words that the case text and needed context go to the MyLaws service and its AI provider, and require an explicit choice. Offline use needs no such consent.
- Distinguish three things everywhere they appear: stored on this phone, processed online, and (optional, off by default) saved to cloud history.
- Keep personal details out of notifications and the app switcher: use `Activity.setRecentsScreenshotEnabled(false)` on supported Android versions through a small platform channel, and `FLAG_SECURE` only on draft screens when "hide content" is on and only where the first option is unavailable.
- No biometrics, contacts, GPS or attachments without a concrete existing requirement.

---

## 12. Demo and fixture isolation

- Build a fixture adapter implementing the same repository interfaces, using the synthetic fixtures from `03_SHARED_CONTRACT.md`. Every fixture sets provenance `demo_fixture`, and the UI shows a persistent "Sample mode" label.
- The demo adapter is registered only in `main_dev.dart`. A fixture answer must never look like a live answer or reach release.
- Do not put real or realistic legal claims in fixtures. Use clearly synthetic text such as "[SYNTHETIC SAMPLE: not legal content]".

---

## 13. Platform behavior and performance

- Edge-to-edge layout, correct system bar contrast, keyboard insets and `SafeArea`. Check activity recreation, process recovery and rotation.
- Heavy work (JSON parsing of large responses, hashing, PDF generation, database queries) stays off the UI isolate. Lists are virtualized.
- Define budgets before testing, for example cold start to first frame, scroll jank, memory on a 4 GB phone, then measure on a real device. Report the numbers and the device. Do not declare a pass without a budget.
- Do not add a dependency for a single small animation.

---

## 14. Testing and evidence

Required, with results reported honestly (details in `04_ACCEPTANCE_AND_TEST_PLAN.md`):
- Widget tests for every component and every state in section 8.
- Golden tests for the main screens at 360, 390 and 412dp, light and dark, Bangla and English, normal and large text, using the bundled fonts.
- Contrast and tap-target tests.
- Integration tests for: first run, auth gate and guest, story, clarification, answer, source sheet, checklist tick and undo, correction and superseded banner, draft interview to preview, quota-reached state, offline state, settings persistence, language switch.
- Real screenshots from a real device or emulator. Report the device or emulator model, Android version, Flutter version and the APK identity and checksum. Never present an emulator screenshot as proof of offline inference or device performance.
- `flutter analyze`, `flutter test` and a release build must pass. Report any that do not.

---

## 15. Deliverables

1. The implemented Flutter app (screens, state, navigation, design system, localization).
2. Design tokens as code (`ThemeData`, `ThemeExtension`, text styles) and the ARB files.
3. Bundled fonts with licenses.
4. The repository interfaces in `domain/`, handed to Prompt 02, plus the fixture adapter.
5. Tests and real screenshots.
6. `docs/KOTLIN_PORT_MAP.md` and `docs/UI_HANDOFF.md` (stack decisions, packages and reasons, state transition table, known gaps, what is implemented / verified / limited / blocked).

Finish this stage with a short implemented / verified / remaining list. If both prompts were assigned to you, continue into Prompt 02 immediately after the UI checkpoint. Do not stop because the screens look finished. A good-looking frontend is not evidence that the backend, quota, offline mode or exports work.
