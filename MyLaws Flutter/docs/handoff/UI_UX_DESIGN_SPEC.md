# MyLaws — Complete UI/UX Design & Architectural Specification

> **Target Audience:** AI Agents, UI/UX Engineers, and Cross-Platform Developers (Flutter / React Native / Web).  
> **Purpose:** Comprehensive blueprint to understand, visualize, and reconstruct the complete MyLaws application interface and user experience with pixel-level fidelity.

---

## 1. Executive Summary & Brand Philosophy

**MyLaws (বাংলাদেশ আইনি সহায়তা ও খসড়া সহকারী)** is a citizen-first legal aid and preparation assistant designed specifically for Bangladesh. It translates complex statutory frameworks (Labour Act, Rent Control Act, Negotiable Instruments Act, CrPC) into plain-language guidance, actionable step-by-step checklists, and formally structured legal drafts (GD, DIFE wage claims, Tenancy contracts) exportable as ISO A4 PDFs.

### Core Design Tenets
1. **Editorial Gravitas & Trust:** The app blends the dignity of a traditional law library with modern, accessible Scandinavian-style minimalism. It deliberately avoids flashy gradients or playful aesthetics.
2. **Honesty & Provenance First:** Every legal answer clearly labels its sources, distinguishes between online AI generation vs. offline statute packs, and maintains strict disclaimers that drafts are preparation aids, not formal court filings.
3. **Respectful Bilingual Tone:** Full parity between **English** and natural, respectful everyday **Bangla** (using the polite *আপনি* form).
4. **Resilient Local-First Experience:** Local encrypted on-device storage, zero-friction guest/offline mode, and offline statutory downloads.

---

## 2. Visual Identity & Assets

| Asset Element | Description & Appearance |
| :--- | :--- |
| **Emblem / Logo** | Flat-vector navy hand holding the balanced Scales of Justice. |
| **Wordmark** | Bold, refined serif typography: **MyLaws** (English) / **মাই লজ** (Bangla). |
| **Color Archetype** | **Parchment Ivory** (calm paper), **Deep Navy Ink** (statutory authority), **Warm Gold/Bronze** (balance of justice). |
| **Icons & Glyphs** | Clean stroke icons (scales, feather pen ✎, document ▤, download ↓, settings ⚙, sparkle ✨). |

---

## 3. Design Tokens & Color Palette

The interface supports both **Light Mode** (warm parchment library) and **Dark Mode** (deep charcoal study).

### 3.1 Color Swatches (Exact Hex Values)

```
LIGHT THEME (Warm Ivory & Bronze)
┌────────────────────────────────────────────────────────┐
│ Background:           #FBF9F3  (Warm Ivory Cream)      │
│ Surface / Cards:      #FFFFFF  (Pure Paper White)       │
│ Surface Variant:      #F0EEE8  (Muted Parchment)       │
│ Primary (Brand Gold): #8C6735  (Warm Legal Bronze)     │
│ Primary Container:    #F4ECE0  (Soft Sand Tint)        │
│ On Primary:           #FFFFFF                          │
│ Text (Brand Ink):     #102332  (Deep Navy Ink)         │
│ Secondary / Muted:    #4E6072  (Slate Navy)            │
│ Border / Outline:     #E2DCCE  (Subtle Border Parchment)│
│ Outline Muted:        #807568  (Mid Border)            │
│ Error / Destructive:  #BA1A1A  (Deep Crimson)          │
└────────────────────────────────────────────────────────┘

DARK THEME (Deep Navy Charcoal & Luminous Gold)
┌────────────────────────────────────────────────────────┐
│ Background:           #121518  (Night Charcoal)        │
│ Surface / Cards:      #1B2228  (Elevated Charcoal Card)│
│ Surface Variant:      #252D35  (Container Tint)        │
│ Primary (Luminous):   #D8AE6A  (Restrained Pale Gold)  │
│ Primary Container:    #3A2D17  (Deep Amber Bronze)     │
│ On Primary:           #261905                          │
│ Text (Main Paper):    #F5F3ED  (Warm Off-White)        │
│ Secondary / Muted:    #B4BDC6  (Cool Silver Mist)      │
│ Border / Outline:     #2E3740  (Dark Slate Stroke)     │
│ Error / Destructive:  #FFB4AB  (Muted Coral Rose)      │
└────────────────────────────────────────────────────────┘
```

### 3.2 Spacing & Radii Standards
- **Corner Radii:**
  - Extra Large (Cards / Modal Sheets): `18dp` to `20dp`
  - Large (Panels / Message Containers): `14dp` to `16dp`
  - Medium (Buttons / Input Fields): `12dp`
  - Small (Badges / Tags): `6dp` to `8dp`
  - Pill / Capsule (Status & Filter Chips): `999dp` (fully rounded)
- **Grid & Margins:**
  - Screen Horizontal Padding: `20dp` (standard mobile container)
  - Card Inner Padding: `16dp` to `20dp`
  - Vertical Stacking Gap: `12dp` to `16dp`

---

## 4. Typography System

The app utilizes a dual-font strategy depending on the user's selected language:

### 4.1 Font Families
- **English Display & Legal Rulings:** **Newsreader** (Open Font License, Serif) — conveys judicial authority, clarity, and literary elegance.
- **English Body & UI Controls:** **Hind / System Sans** — high legibility, clean geometry.
- **Bangla Headings & Titles:** **Anek Bangla** (Weights 500 Medium & 600 SemiBold) — modern, balanced proportions without excessive calligraphic flourishes.
- **Bangla Body & Form Fields:** **Hind Siliguri** (Weights 400 Regular & 500 Medium) — natural spacing and optimal x-height for complex Bengali conjuncts (যুক্তাক্ষর).
- **Printable Legal A4 PDF:** **Noto Sans Bengali** (standard 12pt body with 5pt extra line spacing).

### 4.2 Type Scale

| Role | Font Family | Size / Line Height | Weight | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Display Large** | Newsreader / Anek Bangla | 32sp / 40sp | SemiBold (600) | Welcome Greeting, Major Titles |
| **Headline Medium** | Newsreader / Anek Bangla | 24sp / 32sp | SemiBold (600) | Auth Gate Title, Document Titles |
| **Headline Small** | Newsreader / Anek Bangla | 20sp / 26sp | SemiBold (600) | Core Legal Ruling Summary |
| **Title Medium** | Hind / Anek Bangla | 16sp / 22sp | SemiBold (600) | Section Headers, Step Titles |
| **Body Large** | Hind / Hind Siliguri | 15.5sp / 24sp | Regular (400) | Main Narrative Legal Explanation |
| **Body Medium** | Hind / Hind Siliguri | 14sp / 21sp | Regular (400) | User Bubbles, Checklist Descriptions |
| **Body Small** | Hind / Hind Siliguri | 12sp / 18sp | Regular (400) | Disclaimers, Footnotes, Dates |
| **Label Small** | Hind / Hind Siliguri | 11sp / 14sp | Bold (700) | Badges, Status Pills, Section Tags |

---

## 5. Navigation & Screen Flow

```
                      ┌──────────────────────┐
                      │    Native Splash     │
                      │ (Ivory + Navy Scale) │
                      └──────────┬───────────┘
                                 │
                    [Is User Signed Out & Live?]
                                 │
                 ┌───────────────┴──────────────┐
                YES                             NO
                 ▼                               ▼
       ┌──────────────────┐            ┌──────────────────┐
       │    Auth Gate     │            │    Home Screen   │
       │ (Sign In/SignUp) │───────────►│ (Greeting/Chat)  │
       │ [Skip/Guest ───►]│            └────────┬─────────┘
       └──────────────────┘                     │
                               ┌────────────────┴────────────────┐
                               ▼                                 ▼
                     ┌──────────────────┐              ┌──────────────────┐
                     │ Navigation Drawer│              │  Answer Display  │
                     │  - New Chat      │              │  - Plain Ruling  │
                     │  - Examples      │              │  - Sources Chips │
                     │  - Saved Chats   │              │  - Action Steps  │
                     │  - Drafts        │              │  - Timeline Box  │
                     │  - Downloads     │              │  - Draft CTA     │
                     │  - Settings      │              └────────┬─────────┘
                     └──────────────────┘                       │
                                                                ▼
                                                       ┌──────────────────┐
                                                       │   Draft Editor   │
                                                       │  - Facts Form    │
                                                       │  - Doc Preview   │
                                                       │  - Export A4 PDF │
                                                       └──────────────────┘
```

---

## 6. Comprehensive Screen-by-Screen UI Specifications

---

### Screen 1: The App Bar & Shell Header
Present across all primary screens. Highly customized editorial command bar.

```
┌──────────────────────────────────────────────────────────────┐
│ [☰]  ⚖️ MyLaws         [🌐 English]   [ (S) SAKIB  24/30 ▾ ] │
└──────────────────────────────────────────────────────────────┘
```

#### Visual Elements & Behavior:
1. **Left Navigation Icon:** `☰` (Hamburger menu opening Drawer) when on top level; changes to `←` (Back arrow) when inside sub-flows (Draft Editor, Settings).
2. **Brand Title:** Scales of Justice icon in primary bronze (`#8C6735`), accompanied by serif text **"MyLaws"** (or screen title).
3. **Language Capsule Pill:**
   - Oval capsule with subtle outline: `[ 🌐 English ]` or `[ 🌐 বাংলা ]`.
   - Single tap toggles the entire app language instantly without reload.
4. **User Profile & Quota Pill:**
   - Gold-bordered capsule: `[ (S) SAKIB  24/30 ▾ ]`
   - Features a circular avatar with user initial, uppercase user name, and an amber quota counter (`24/30`).
   - Tapping opens a sleek **Profile Dropdown Card**:
     - User full name + email address (`airdrop.sakib081@gmail.com`).
     - **Daily AI Quota Meter:** Visual amber progress bar indicating queries remaining today.
     - Quick Action: `[✨ Ask a Question]` (resets to empty state).
     - Sign Out: `[↪ Sign Out]` in soft crimson text.

---

### Screen 2: First-Launch Auth Gate (Live Mode)
Shown to first-time or signed-out users in live mode before entering the main assistant.

```
┌────────────────────────────────────────────────────────┐
│                        [ ⚖️ ]                          │
│                   Welcome to MyLaws                    │
│     [BANGLADESH LEGAL AID & PREPARATION ASSISTANT]     │
│  Log in to your citizen command center. Understand    │
│  constitutional rights and prepare legal drafts.      │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │       [ Sign In ]      |    Create Account       │  │
│  │                                                  │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │ [G] Continue with Google                   │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  │  ────────────────── or email ──────────────────  │  │
│  │  Account Email:    [________________________]    │  │
│  │  Account Password: [•••••••••••••••••••••• 👁]   │  │
│  │                                                  │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │              Sign In (Action)              │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│               [ Continue without account → ]           │
└────────────────────────────────────────────────────────┘
```

#### Key Components:
- **Scales Emblem:** Centered in an ivory/gold rounded container (72dp).
- **Segmented Switcher:** Pill-shaped toggle switching between **Sign In** and **Create Account**.
- **1-Tap Google Button:** Prominent elevation, authentic Google icon, triggers Android Credential Manager.
- **Divider:** Elegant horizontal rule with "or continue with email".
- **Skip Path:** Subtle bottom link: *"Continue without an account"* allowing immediate guest access to offline statutes, saved records, and draft tools.

---

### Screen 3: Home & Empty State (Screen A)
When no conversation is active and keyboard is closed.

```
┌────────────────────────────────────────────────────────┐
│                                                        │
│               Good Afternoon, Sakib                    │
│        Understand your rights in plain words           │
│                                                        │
│     (•) Everyday Legal Guidance • Bangladesh Law       │
│                                                        │
│  QUICK STARTERS                                        │
│  [🏠 Rent Agreement?] [⏱️ Cheque Bounce] [👮 File GD?]  │
│                                                        │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Describe your legal problem in plain words...    │  │
│  │                                                  │  │
│  │ [⚖️ Legal sources ↗]                           [↑]│  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

#### Key Components:
1. **Time-Aware Greeting:** Dynamically updates:
   - English: *"Good Morning"* / *"Good Afternoon"* / *"Good Evening, Sakib"* (Newsreader Serif).
   - Bangla: *"শুভ সকাল"* / *"শুভ দুপুর"* / *"শুভ বিকেল"* / *"শুভ রাত, সাকিব"* (Anek Bangla).
2. **Subtitle & Assurance Pill:** Informs the user of plain-language advice and strict privacy.
3. **Quick Starters (Horizontal Scroll Carousel):**
   - High-yield legal queries pre-packaged into rounded capsules:
     - `🏠 How to make rent agreement?` (Premises Rent Control Act)
     - `⏱️ Cheque bounce 30-day notice` (Section 138 NI Act)
     - `👮 How to file GD at Thana?` (General Diary procedure)
     - `💼 Boss didn't pay salary` (Labour Act Section 123/132)
   - Tapping an item immediately submits the query or inserts it into the composer.
4. **Docked Composer Bar (Sticky Bottom):**
   - Roomy rounded input box (auto-expands from 2 up to 5 lines).
   - Bottom row inside composer:
     - Left: `[⚖️ Legal sources ↗]` (quick link to local legal database).
     - Right: Circular button with up-arrow `[↑]` (disabled when empty; turns into square stop icon `[■]` while AI streams).

---

### Screen 4: Active Answer & Jurisprudence Card (Screen B)
The heart of the application. Displays grounded legal reasoning.

```
┌────────────────────────────────────────────────────────┐
│                                                        │
│               ┌──────────────────────────────────────┐ │
│               │ My boss has not paid salary 2 months │ │
│               └──────────────────────────────────────┘ │
│                                                        │
│  ✦ Checking statutory deadlines and Labour Court...   │
│                                                        │
│ ┌────────────────────────────────────────────────────┐ │
│ │ ⚖️ MyLaws   [MYLAWS LEGAL ASSISTANT]               │ │
│ │                                                    │ │
│ │ Unpaid Wages Relief & Compensation Entitlement     │ │
│ │ Under Section 123 of the Bangladesh Labour Act,    │ │
│ │ wages must be disbursed within 7 working days...   │ │
│ │                                                    │ │
│ │ ⚖️ STATUTORY SOURCES                               │ │
│ │ [BLA 2006 (§123) ↗] [BLA (§132) ↗] [Constitution ↗]│ │
│ │ ────────────────────────────────────────────────── │ │
│ │ RECOMMENDED STEPS TO TAKE                          │ │
│ │ 1. Serve written demand notice to employer         │ │
│ │ 2. File statutory claim with Labour Court          │ │
│ │ 3. Lodge inspection request with DIFE              │ │
│ │                                                    │ │
│ │ ┌────────────────────────────────────────────────┐ │ │
│ │ │ ▌ STATUTORY LIMITATION & FREE LEGAL AID        │ │ │
│ │ │ • 12-Month Limit: Claims must be filed within  │ │ │
│ │ │   12 months from the date wages became due.    │ │ │
│ │ │ • Free Legal Aid: Available via DLAC / BLAST.  │ │ │
│ │ └────────────────────────────────────────────────┘ │ │
│ │                                                    │ │
│ │ ┌────────────────────────────────────────────────┐ │ │
│ │ │ 📄 Need a Formal Written Complaint?            │ │ │
│ │ │ MyLaws will generate a structured document...  │ │ │
│ │ │ [ Prepare a Formal Legal Draft → ]             │ │ │
│ │ └────────────────────────────────────────────────┘ │ │
│ │ ────────────────────────────────────────────────── │ │
│ │ [Save chat]   [Office info]          [5 sources ↗] │ │
│ └────────────────────────────────────────────────────┘ │
│                                                        │
│ ┌────────────────────────────────────────────────────┐ │
│ │ Ask a follow-up or provide details...          [↑] │ │
│ └────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

#### Detailed Element Breakdown:
1. **User Bubble:** Right-aligned rounded bubble with ivory/sand container (`#F4ECE0`), soft navy text.
2. **Reasoning Indicator:** Small capsule above the card: `✦ Checking statutory deadlines and Labour Court precedents...`
3. **Jurisprudence Card Container:** Large white card (`#FFFFFF`), `18dp` corner radius, delicate border line.
   - **Header:** Mini wordmark + gold label badge `[MYLAWS LEGAL ASSISTANT]`.
   - **Headline Ruling:** Newsreader Serif, bold, prominent — direct answer to the user's issue.
   - **Narrative Explanation:** Clear statutory explanation in simple everyday language.
   - **Statutory Source Chips:** Horizontally scrollable pills linking directly to legal sections. Tapping opens the verified legal clause sheet.
   - **Checklist Steps:** Numbered sequentially with title, plain explanation, and action links.
   - **Statutory Callout Box (Parchment Alert):** Accent box with a thick primary bronze line on the left. Highlights non-negotiable statutory timelines (e.g. 30-day cheque notice, 12-month labour limitation).
   - **Draft Generator Banner:** Contextual card offering to generate a formal document based on the case facts. Prominent action button: `[ Prepare Legal Draft → ]`.
   - **Footer Bar:** `[Save chat]` to local storage, `[Office info]` (jurisdiction verification), and `[5 sources ↗]` count chip.

---

### Screen 5: Interactive Clarification Card (Within Thread)
Triggered when the user's query lacks essential legal parameters (e.g., whether employment was permanent or contractual, incident date, or police station territory).

```
┌────────────────────────────────────────────────────────┐
│ ❓ Additional Details Needed for Accurate Advice        │
│ "To determine which court or office has jurisdiction:" │
│                                                        │
│ Workplace Location:                                    │
│ [ Gazipur ] [ Dhaka North ] [ Chittagong EPZ ]         │
│                                                        │
│ Employment Contract Type:                              │
│ (•) Permanent Staff   ( ) Daily Rated   ( ) Contract   │
│                                                        │
│ [ I don't know / Skip ]          [ Update Guidance → ] │
└────────────────────────────────────────────────────────┘
```
- Lets users answer specific multi-choice or date questions.
- Once answered, the answer updates automatically without starting a new conversation.

---

### Screen 6: Legal Draft Editor & PDF Exporter
Where citizens generate formal, legally formatted A4 documents (e.g., General Diary for Police Thanas, DIFE Wage Recovery Complaints, Tenancy Agreements).

```
┌────────────────────────────────────────────────────────┐
│ [←] General Diary (GD) Application                     │
│                                                        │
│    [     Facts (Interview)    |     Preview Doc     ]  │
│                                                        │
│ ⚠️ Preparation only. No formal filing or seals generated│
│ ● Ready to export · facts reviewed                     │
│                                                        │
│ YOUR DETAILS                                           │
│ Applicant Name *        [ Sakib Ahmed                ] │
│ Contact Phone *         [ +880 1711-000000           ] │
│ Residential Address *   [ House 12, Road 4, Dhanmondi] │
│                                                        │
│ RECIPIENT & EVENT                                      │
│ Thana & Jurisdiction *  [ Dhanmondi Model Thana      ] │
│ Date & Time of Incident [ 28 October 2026, 9:30 PM   ] │
│ Place of Occurrence *   [ Dhanmondi Lake Park        ] │
│                                                        │
│ FACTS & REQUEST                                        │
│ Chronological Facts *   [ While walking near the lake│ │
│                           my bag containing NID and  │ │
│                           phone was misplaced...     ] │
│ Assistance Requested *  [ Record GD for tracking and │ │
│                           lost NID reissuance.       ] │
│                                                        │
│ [ Preview & Edit Document → ]                          │
└────────────────────────────────────────────────────────┘
```

#### Preview & Export Mode (Second Tab):
- Displays the generated document in **authentic Bangladeshi legal format**:
  - `বরাবর, অফিসার ইনচার্জ (ওসি), ধানমন্ডি মডেল থানা...`
  - `বিষয়: সাধারণ ডায়েরি (GD) করার আবেদন।`
  - Formal paragraphs, bullet points, and closing signatory line.
- **Controls & Actions:**
  - `[☑ I reviewed the facts and recipient]` (mandatory safety toggle).
  - `[ Copy Plain Text ]`
  - `[ Export A4 PDF ]` (saves to `Downloads/MyLaws/MyLaws-GD-draft.pdf`).
  - `[ Share PDF ]` (system Android share sheet to WhatsApp, Gmail, etc.).
  - `[ Print ]` (triggers system A4 print spooler).

---

### Screen 7: Modal Navigation Drawer
Slides out smoothly from the left edge (width: 320dp).

```
┌───────────────────────────────────────────────┐
│ ⚖️ MyLaws                                     │
│ Understand your rights. Find your next step.  │
│                                               │
│  +  New conversation                          │
│  ✎  Examples                                  │
│  ≡  Saved conversations                       │
│  ▤  Drafts                                    │
│  ↓  Downloads & offline                       │
│  ⚙  Settings                                  │
│ ───────────────────────────────────────────── │
│ Account                                       │
│ Sakib Ahmed                                   │
│ Verified Citizen Account                      │
│                                               │
│ ℹ️ All records stay encrypted on this phone.  │
└───────────────────────────────────────────────┘
```

---

### Screen 8: Downloads & Offline Center
Allows the app to work 100% offline in rural or low-connectivity areas of Bangladesh.

```
┌────────────────────────────────────────────────────────┐
│ Work without a connection                              │
│ Saved records and drafts already work offline. You can │
│ download verified statutory packs below.               │
│                                                        │
│ ┌────────────────────────────────────────────────────┐ │
│ │ 📖 Legal sources for offline reading               │ │
│ │ Complete Bangladesh labour & tenancy acts, PRB     │ │
│ │ regulations and court forms. (Size: ~12 MB)        │ │
│ │ Status: Installed & Verified (v2026.10.30)         │ │
│ │ [ Update Pack ]                 [ Check Integrity ]│ │
│ └────────────────────────────────────────────────────┘ │
│                                                        │
│ ┌────────────────────────────────────────────────────┐ │
│ │ 🧠 On-phone AI Help (Optional)                     │ │
│ │ On-device legal reasoning model for offline answers│ │
│ │ Status: Not installed · Requires 1.2 GB storage    │ │
│ │ [ Download Offline AI ]                            │ │
│ └────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

---

### Screen 9: Settings Screen

```
┌────────────────────────────────────────────────────────┐
│ APPEARANCE                                             │
│ [  System Default  |   Light   |   Dark   ]            │
│                                                        │
│ LANGUAGE & TEXT                                        │
│ App Language:       [  বাংলা  |   English   ]          │
│ Answer Language:    [  বাংলা  |   English   ]          │
│ Larger Text:        [  Off / On  Toggle   ]            │
│                                                        │
│ DOWNLOADS & OFFLINE                                    │
│ Wi-Fi Only Downloads:    [ Toggle ON  ]                │
│ Auto-update Laws:        [ Toggle ON  ]                │
│ Prefer Offline Mode:     [ Toggle OFF ]                │
│                                                        │
│ PRIVACY & ACCOUNT                                      │
│ Signed in as: airdrop.sakib081@gmail.com               │
│ [ Sign Out ]                                           │
│                                                        │
│ DANGER ZONE                                            │
│ [ Delete all local records on this phone ]             │
└────────────────────────────────────────────────────────┘
```

---

## 7. Micro-Interactions, Feedback & Edge States

1. **User Fact Correction Detection:**
   - If a user sends a follow-up correcting an earlier detail (e.g. *"Actually my salary was 12,000, not 20,000"*), the system flags the older assistant bubble with an **"Updated by your correction"** warning banner.
   - Any unreviewed drafts based on old facts are paused to prevent exporting incorrect legal claims.
2. **Quota Depletion State:**
   - When the user hits their 30-query daily limit:
   - Composer remains available, but displays: *"Today's online question limit is reached. Offline statutory sources and document drafts remain active."*
3. **No Network / Offline Fallback:**
   - Seamlessly falls back to the installed local statutory pack without crashing or displaying raw network exceptions.
   - Shows a warm pill: `● Offline Mode • Answering from installed law pack`.

---

## 8. Summary Table for UI Reproduction

| Screen / Feature | Primary Component | Key Visual Tokens | Primary Interaction |
| :--- | :--- | :--- | :--- |
| **App Bar** | Custom Header Row | `#8C6735` Gold logo, `#102332` Navy text, Pill badges | Tap Profile → Quota dropdown; Tap Lang → Toggle |
| **Home Greeting** | Hero Editorial Stack | Newsreader / Anek Bangla font, 32sp | Disappears when keyboard opens |
| **Quick Starters** | Horizontal Carousel | Capsule `999dp`, `#FFFFFF` bg, `#E2DCCE` border | Tap → Pre-populates query & submits |
| **Composer** | Docked Bottom Bar | Multi-line auto-expand (2–5 lines), circular send | Empty disables send; sending shows stop icon |
| **Answer Card** | Elevated Surface | `#FFFFFF` bg, `18dp` radius, gold badge, Newsreader headline | Tap source chip → Open legal passage sheet |
| **Limitation Box** | Warning Callout | Left accent bar `3dp`, parchment container `#F4ECE0` | Clearly presents filing deadlines & legal aid |
| **Draft CTA** | Embedded Action Card | Primary container tint, `[Prepare Legal Draft →]` | Tap → Opens Draft Interview Editor |
| **Draft Editor** | Two-Tab Form/Preview | Section labels, Outlined text fields, A4 preview | Reviewed toggle → Enables PDF/Print/Share |
| **Navigation** | Modal Drawer | Left 320dp width, clean glyph list, account status | Tap item → Navigates & closes drawer |

---
*Document verified against MyLaws v1.6 native implementation.*
