# MyLaws — Kotlin Port Map (docs/KOTLIN_PORT_MAP.md)

**Date:** 2026-11-02  
**Author:** Lead Engineer Rebuilding MyLaws in Flutter  
**Status:** Approved for Prompt 01 & Prompt 02 implementation  
**Reference Codebase:** `reference/kotlin_app` (`E:\vibe coding\POIDH\Meta Ai Global Hackathon\MyLaws V1\android`)  
**Target Codebase:** `lib/` (Flutter Rebuild)

---

## 1. Architectural Strategy

The Kotlin codebase serves as a read-only functional reference for user journeys, legal copy, and data migration. The Flutter rebuild is an architectural upgrade:
1. **Separation of Concerns:** The monolithic `AppModel.kt` (which mixed UI state, persistence, network dispatch, and formatting) is decomposed into clean Domain Repositories, Data Sources, and Riverpod State Notifiers.
2. **Proper Localization:** Ad-hoc inline `t("English", "বাংলা")` ternaries scattered throughout Compose files are replaced with standard Flutter ARB localization (`app_bn.arb` and `app_en.arb`).
3. **Multi-Case Local Database:** The single-slot `case.enc` file is migrated on first startup into an owner-partitioned SQLite database (via Drift) supporting multiple conversations and drafts.
4. **Offline First with FTS5:** In-memory keyword matching is replaced with a local SQLite FTS5 search index over the installed legal pack.
5. **No Defect Propagation:** Known UX and legal defects in the Kotlin prototype are explicitly dropped.

---

## 2. Screen & Component Porting Matrix

| Kotlin Screen / Component | Kotlin File | Action | Flutter Target Location | Technical Rationale & Defect Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Splash / Startup** | `MainActivity.kt` | **Redo** | `lib/features/startup/` | Kotlin used basic system splash and initialized `case.enc` on main thread. Flutter will use `flutter_native_splash`, asynchronously initialize Drift database, verify auth state, and run background legacy migration with a graceful progress indicator. |
| **Auth Gate** | `EditorialScreens.kt` (`AuthGate`) | **Port & Redo** | `lib/features/auth/` | Port the visual layout (scales emblem, segmented sign-in/up, Google sign-in button). Redo error handling to map Firebase errors to clear bilingual messages. Support true guest mode without online assistant access. |
| **App Shell & App Bar** | `HomePage.kt` (`TopBar`) | **Redo** | `lib/core/widgets/app_bar_shell.dart` | Port scales mark, title, quick toggle for language. Redo to prevent overflow at 360dp with 200% text scale. Quota meter in profile pill must bind to server-authoritative numbers, not static values. |
| **Mode Status Chip** | `HomePage.kt` (`ModeChip`) | **Port** | `lib/core/widgets/mode_status_chip.dart` | Port explicit state labels: "Online assistant", "Offline: installed law pack", "Offline: unavailable, install law pack", "Sample mode" (dev). Never rely on a network icon alone. |
| **Home & Composer** | `HomePage.kt` (`HomeGreeting`, `Composer`) | **Redo** | `lib/features/home/`, `lib/features/conversation/composer.dart` | **Defect dropped:** Kotlin auto-submitted quick starters immediately on click. Flutter will insert starter text into the composer for review and editing before sending. Pinned above keyboard with proper insets. |
| **Conversation Thread** | `HomePage.kt` (`ConversationView`) | **Redo** | `lib/features/conversation/thread_view.dart` | Replace unindexed JSON turns list with structured Riverpod stream. Add scroll position preservation and "latest reply" button when user scrolls up. Ensure unsent input survives app kill. |
| **Clarification Card** | `HomePage.kt` (`ClarificationCard`) | **Port & Redo** | `lib/features/clarification/clarification_card.dart` | Port canonical fieldIds, importance notes, and choice/text input modes. Redo to update existing case in-place rather than starting a new conversation. Never ask for identity details prematurely. |
| **Answer Card** | `HomePage.kt` (`AnswerCard`) | **Redo** | `lib/features/answer/answer_card.dart` | Port 4-step canonical structure (Understanding, Summary/Explanation with inline source chips, Action Checklist, Limitations, Draft Offer). Redo with progressive disclosure to avoid endless cards. |
| **Source Detail Sheet** | `HomePage.kt` (`SourceSheet`) | **Port** | `lib/features/sources/source_detail_sheet.dart` | Port provision citation details, original statutory text, verified dates, official links, and machine-check disclaimer. Display offline availability status truthfully. |
| **Checklist & Offices** | `HomePage.kt` (`Checklist`, `OfficeSheet`) | **Port & Redo** | `lib/features/checklist/`, `lib/features/offices/` | Port step completion, undo capability, required documents vs helpful evidence. Redo checklist state persistence in SQLite with `needsRecheck` flag when facts or laws update. Tap-to-call for offices. |
| **Draft Editor** | `DraftEditor.kt`, `Documents.kt` | **Redo** | `lib/features/drafts/` | **Defect dropped:** Kotlin explicitly blocked DNCRP drafts (`"not available in this build yet"`). Flutter will fully implement GD, DIFE, and DNCRP drafts. Add sectioned fact review with provenance badges, placeholder highlighting (`[...]`), A4 paginated preview, and review checkbox before export. |
| **Navigation Drawer** | `HomePage.kt` (`DrawerContent`) | **Port & Redo** | `lib/features/drawer/drawer_shell.dart` | Port navigation links (New conversation, Saved, Drafts, Sources Library, Downloads, Settings, Account). Redo data-scope labels honestly (do not claim encryption unless verified). |
| **Saved Conversations** | `EditorialScreens.kt` (`SavedConversations`) | **Redo** | `lib/features/library/saved_conversations_screen.dart` | Port listing, search, and delete. Redo from single `case.enc` into multi-case SQLite query with owner UID isolation. |
| **Downloads & Offline** | `EditorialScreens.kt` (`DownloadsScreen`) | **Port & Redo** | `lib/features/downloads/downloads_screen.dart` | Port two distinct cards for Legal Pack and Local Model. Redo with real byte-progress tracking, HTTP Range resume, SHA-256 integrity verification, and safe rollback. |
| **Settings Screen** | `EditorialScreens.kt` (`SettingsScreen`) | **Redo** | `lib/features/settings/settings_screen.dart` | **Defect dropped:** Kotlin used harsh pink selection highlights. Flutter will use brand bronze container fill and checkmark icons. All controls will be backed by real handlers. Separate public pack auto-update from private cloud processing. Add in-app account deletion. |
| **About & Licenses** | `EditorialScreens.kt` (`AboutScreen`) | **Port** | `lib/features/about/about_screen.dart` | Port legal disclaimers, version info, pack versions, open-source and bundled font licenses. |

---

## 3. Data Layer & State Management Mapping

### 3.1 Persistence & Data Migration
- **Kotlin Implementation:** `SecureStore.kt` storing JSON in `case.enc` via AES/GCM AndroidKeyStore.
- **Flutter Implementation:**
  - `lib/data/migration/legacy_migration_service.dart`: Reads existing `case.enc` (via platform channel if key is hardware-backed, or native decrypt), extracts saved active question, facts, turns, drafts, and preferences.
  - `lib/data/local/database/`: SQLite database via `drift` with tables:
    - `conversations`: `id, owner_id, title, language, answer_language, created_at, updated_at`
    - `turns`: `id, conversation_id, role, content, answer_id, superseded, created_at`
    - `facts`: `id, conversation_id, field_id, value, value_type, status, provenance, turn_id, created_at`
    - `checklist_items`: `id, conversation_id, step_id, title, completed, needs_recheck, completed_revision`
    - `drafts`: `id, conversation_id, owner_id, type, template_version, facts_json, recipient, review_status, export_status, updated_at`
    - `offline_sources`: FTS5 virtual table for installed legal corpus.

### 3.2 State Management
- **Kotlin Implementation:** Single `AppModel : AndroidViewModel` holding 15+ `mutableStateOf` variables.
- **Flutter Implementation:** Riverpod feature providers:
  - `authProvider`: StateNotifier managing `AuthState` (guest, signed_out, signed_in, token_refreshing).
  - `conversationProvider`: StateNotifier managing the active chat, message streaming, turns, and idempotency.
  - `quotaProvider`: Provider observing remaining quota and daily reset from backend.
  - `checklistProvider`: Notifier managing ticks, undo state, and recheck flags.
  - `draftsProvider`: Notifier managing draft editing, required field validation, and A4 export.
  - `packManagerProvider`: Notifier managing pack download, hashing, staging, activation, and removal.
  - `settingsProvider`: StateNotifier persisting theme, language, Wi-Fi constraints, and cloud sync flags.

---

## 4. Typography & Design Tokens Mapping

### 4.1 Fonts Mapping
All fonts from `reference/kotlin_app/app/src/main/res/font/` are migrated to Flutter `assets/fonts/`:
- `anek_400.ttf`, `anek_500.ttf`, `anek_600.ttf` -> Headings & Titles in Bangla (`Anek Bangla`).
- `hind_regular.ttf`, `hind_medium.ttf`, `hind_semibold.ttf` -> Body & Controls in Bangla & English (`Hind / Hind Siliguri`).
- `newsreader_medium.ttf`, `newsreader_semibold.ttf` -> Editorial display & summary lines in English (`Newsreader`).
- `bangla.ttf` -> Document PDF export rendering (`Noto Sans Bengali`).
- `FONT_LICENSE.txt` -> Bundled into `assets/licenses/` for in-app licensing compliance.

### 4.2 Color Palette (Tokens)
Directly imported from `DesignSystem.kt` into `lib/core/theme/app_colors.dart`:
- **Light:**
  - Background: `#FBF9F3` (Ivory)
  - Surface: `#FFFFFF`
  - Surface Variant: `#F0EEE8`
  - Primary: `#8C6735` (Deep Bronze, 4.8:1 contrast on ivory)
  - Primary Container: `#F4ECE0` (Soft Parchment)
  - Text: `#102332` (Deep Navy)
  - Secondary Text: `#4E6072` (Slate)
  - Outline: `#807568`
  - Outline Variant: `#E2DCCE`
  - Error: `#BA1A1A`
- **Dark:**
  - Background: `#121518` (Dark Charcoal)
  - Surface: `#1B2228`
  - Surface Variant: `#252D35`
  - Primary: `#D8AE6A` (Warm Gold)
  - Primary Container: `#3A2D17`
  - Text: `#F5F3ED`
  - Secondary Text: `#B4BDC6`
  - Outline: `#5A6673`
  - Outline Variant: `#2E3740`
  - Error: `#FFB4AB`

---

## 5. Defects and Omissions Dropped (Do Not Copy)

1. **Do not copy DNCRP blockage:** Replace `DraftEditor.kt` line 39 with complete DNCRP complaint generation.
2. **Do not copy pink settings accent:** Replace magenta selection with bronze container + check icon.
3. **Do not copy quick starter auto-send:** Starter buttons will populate the composer without submitting.
4. **Do not copy single-case `case.enc` overwrites:** Support independent saved cases in SQLite.
5. **Do not copy unmetered guest illusions:** Accurately inform guests that the online assistant requires sign-in, while offline packs and local drafts are free.
6. **Do not copy unhandled token expiration crashes:** Gracefully catch 401s, force-refresh token once, and retry with the same idempotency key without losing user input.
