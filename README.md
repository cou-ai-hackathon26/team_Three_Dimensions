# ⚖️ MyLaws — AI Legal Assistant for Bangladesh

> **CoU AI Hackathon 2026**  
> **Team:** Three Dimensions  
> **Track:** 06. Accessibility & Social Innovation  
> **Live Website:** [https://mylaws-ai.vercel.app](https://mylaws-ai.vercel.app)  

---

## 📌 Executive Summary

**MyLaws** is an intelligent, bilingual legal assistance and document preparation platform tailored specifically for the legal framework of Bangladesh. It empowers ordinary citizens to navigate everyday legal challenges—including **unpaid wages, arbitrary job termination, cyber harassment, consumer fraud, land disputes, and domestic violence**—by transforming dense statutory texts into actionable, plain-language guidance, structured action checklists, and standardized formal complaint drafts (Police GD, DIFE Labor complaints, and DNCRP consumer petitions).

Built with a **ground-truth-first architecture**, MyLaws bridges the gap between the formal justice system and the public, promoting transparency, legal literacy, and social equity across Bangladesh.

---

## 🎯 Problem Statement & Solution

### The Access-to-Justice Challenge in Bangladesh
1. **Statutory Complexity & Language Barriers:** Major laws (such as the Bangladesh Labour Act 2006, The Penal Code 1860, and the Consumers' Right Protection Act 2009) are written in dense, archaic terminology that is difficult for non-lawyers to comprehend.
2. **Procedural Unawareness:** Citizens are frequently unaware of critical statutory deadlines (e.g., wages must be paid within 7 working days under Section 123 of the Labour Act; consumer fraud petitions must be filed within 30 calendar days under Section 60 of the Consumer Act).
3. **Drafting Hurdles:** Preparing formal complaints for administrative and law enforcement bodies (e.g., General Diary entries at Police Stations, inspection petitions to DIFE, or complaints to DNCRP) requires specific statutory grounding and formats that citizens cannot easily author without paid legal assistance.
4. **LLM Hallucinations in Legal Contexts:** General-purpose AI chatbots often fabricate non-existent penal sections, cite repealed statutes, or invent statutory rights, posing significant risks if relied upon by citizens.

### The MyLaws Solution
- **Plain-Language Legal Guidance:** Real-time translation of complex laws into understandable Bangla and English explanations.
- **Action Checklists & Official Hotlines:** Step-by-step instructions paired with verified emergency numbers (National Emergency: **999**, Legal Aid: **16699**, Child Helpline: **1098**, Consumer Rights: **16121**, Labour Inspection: **16104**).
- **Formal Complaint Drafting & A4 PDF Export:** Automated fact-merging into standardized legal templates, formatted with an HTML5 canvas text-shaping engine that faithfully renders complex Bengali conjuncts (যুক্তাক্ষর).
- **Zero-Hallucination Guardrails:** AI answers are grounded in an auditable corpus of official Bangladesh statutes and verified by a runtime citation validator.

---

## 🧠 Core AI Architecture

```
[User Query: Bangla / English / Phonetic Banglish]
                         │
                         ▼
                [/api/answer Endpoint]
                         │
        ┌────────────────┴────────────────┐
        ▼                                 ▼
 [1. Firebase Auth & Quota]      [2. Edge Corpus Retrieval]
  • User verification             • Phonetic Banglish Normalizer
  • Daily query rate-limiting     • BM25 Lexical + Token Expansion
  • Cloudflare D1 user storage    • 49 Acts | 1,046 Verified Provisions
        │
        ▼
 [3. Grounded Synthesis Engine]
   ├── Primary Branch: Meta AI Assistance (muse-spark-1.3)
   │    └── Strict Runtime Citation Validator (filters ungrounded claims)
   └── Resilient Branch: Deterministic Canonical Legal FSM
        └── Immediate, rule-verified fallback if AI times out
        │
        ▼
 [4. 4-Part Response Synthesis]
   ├── 1. Problem Summary (Identifies relevant statutes & violations)
   ├── 2. Plain-Language Explanation (Grounded in verified provisions)
   ├── 3. Action Checklist (Step-by-step guidance + hotlines)
   └── 4. Formal Draft Offer (GD, DIFE, or DNCRP complaint)
        │
        ▼
 [5. Bangla Draft Editor & A4 PDF Generator]
   • High-DPI Canvas rasterization with Noto Sans Bengali
   • Complete HarfBuzz conjunct shaping
   • Print-ready A4 PDF export via jsPDF
```

### 1. Grounded Retrieval-Augmented Generation (RAG)
MyLaws retrieves relevant statutory provisions directly from its localized, high-precision knowledge base before generating responses. Queries are indexed against 1,046 statutory provisions categorized across 7 core citizen domains:
1. **Employment & Labor:** Bangladesh Labour Act 2006 (unpaid wages, severance, maternity benefits).
2. **Threats & General Diary:** Penal Code 1860, Police Act 1861, CrPC 1898 (extortion, criminal intimidation, GD procedures).
3. **Cyber & Digital Security:** Cyber Protection Act 2026, Pornography Control Act 2012 (online blackmail, intimate imagery, identity fraud).
4. **Consumer Rights & Fraud:** Consumers’ Right Protection Act 2009 (adulterated goods, expired medicines, short measure, 25% reward).
5. **Land & Property Disputes:** Land Crime Act 2023, Specific Relief Act 1877 (illegal dispossession, deed forgery).
6. **Domestic Violence & Family Law:** Family Courts Act 2023 (Act 26 of 2023), MFLO 1961, DV Act 2010 (dower, maintenance, custody).
7. **Fundamental Rights & Legal Aid:** Constitution of Bangladesh 1972, Legal Aid Act 2000 (Article 33 arrest rights, legal aid).

### 2. Zero-Hallucination Guardrails & Citation Validation
- **Grounded Source Attribution:** Every response includes direct citations linking to official texts on `bdlaws.minlaw.gov.bd`.
- **Runtime Citation Validator (`src/lib/meta.ts`):** AI responses are audited by an automated verification layer. If an AI output references provisions outside the retrieved statutory context or fabricates rights, the output is discarded and redirected to the canonical deterministic engine.
- *Guardrail Accuracy Note:* Safeguards are implemented as robust, multi-stage software interceptors rather than speculative claims of mathematical impossibility.

### 3. Phonetic Banglish Normalizer
Citizens frequently communicate in phonetic Romanized Bengali (*Banglish*). The retrieval engine (`src/lib/retrieval.ts`) normalizes expressions (e.g., *"amr boss 2 mash dhori beton dey na"* is mapped to unpaid wages under Section 123 of the Labour Act), ensuring high-precision statutory retrieval regardless of script input.

---

## 💻 Technology Stack

| Layer | Technologies Used | Status |
|---|---|---|
| **Frontend Framework** | **Next.js 15.1 (App Router)**, **React 19**, **TypeScript 5.7** | Integrated & Verified |
| **Styling & UI** | **Tailwind CSS 3.4**, **Lucide React Icons**, Interactive 3D Canvas | Integrated & Verified |
| **AI Inference** | **Meta AI (`muse-spark-1.3`)** via edge REST adapter | Integrated & Verified |
| **Resilient Fallback** | Deterministic Canonical Legal Finite State Machine (FSM) | Integrated & Verified |
| **Edge Database** | **Cloudflare D1 (Serverless SQLite)** for quota & user state | Integrated & Verified |
| **Authentication** | **Firebase Authentication (Client SDK)** | Integrated & Verified |
| **PDF Generation** | HTML5 Canvas HarfBuzz Font Shaper + **jsPDF** | Integrated & Verified |
| **Test Suite** | **Vitest 3.0** | Integrated & Verified |
| **Mobile Client** | **Flutter 3.27+ (Dart)** with on-device GGUF / local SQLite FTS5 | Integrated & Verified (v1.0.0 APK Included) |

---

## 📚 Dataset Corpus & Sourcing (Rule 8.3)

In accordance with **Rule 8.3** of the CoU AI Hackathon Rulebook:

- **Corpus Breadth:** **49 Bangladesh Statutory Acts** comprising **1,046 verified provisions**.
- **Official Source:** Ministry of Law, Justice and Parliamentary Affairs, Government of the People’s Republic of Bangladesh ([bdlaws.minlaw.gov.bd](http://bdlaws.minlaw.gov.bd)).
- **Integrity & Verification:**
  - Standardized JSON representations (`src/data/corpus/acts.json`, `src/data/corpus/provisions.json`).
  - Cryptographic content verification via SHA-256 (`src/data/corpus/version.json`).
  - Precompiled in-memory fallback cache (`src/data/legal.generated.ts`) to maintain zero-latency operation during network interruptions.

---

## 🤖 AI Tools Disclosure (Rule 9.1)

In full compliance with **Rule 9.1** of the CoU AI Hackathon Rulebook, the team discloses the following AI tools utilized during the creation of this project:

- **ChatGPT (OpenAI):** Utilized during initial project ideation, corpus schema definition, and preliminary drafting of bilingual plain-language translation rules.
- **Antigravity (Google DeepMind):** Utilized for codebase inspection, test suite auditing, automated build verification, and repository structure preparation.
- **Human Verification:** All legal citations, section mappings, statutory deadlines, and hotline numbers were manually cross-referenced against the official Bangladesh Code on `bdlaws.minlaw.gov.bd`.

---

## 🛠️ Installation & Local Setup

### Prerequisites
- **Node.js:** v20.x or v22.x (tested on v22.19.0)
- **npm:** v10.x or higher

### Step-by-Step Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/EFTAKHAR-AMIN-SAKIB/MyLaws-CoU-AI-Hackathon-2026.git
   cd MyLaws-CoU-AI-Hackathon-2026
   ```

2. **Navigate to the web project directory:**
   ```bash
   cd "MyLaws Web"
   ```

3. **Install dependencies:**
   ```bash
   npm install
   ```

4. **Configure environment variables:**
   Copy the example environment template to `.env.local`:
   ```bash
   cp .env.example .env.local
   ```
   *Required Environment Variables (see `.env.example` for details):*
   - `MODEL_API_KEY`: Meta AI inference API key (*optional: if omitted, the deterministic fallback engine executes*).
   - `META_MODEL`: Meta AI model designation (`muse-spark-1.3`).
   - `PORT`: Local server port (default: `3000`).
   - `DAILY_QUERY_LIMIT`: Daily quota limit per user (default: `10`).
   - `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_D1_DATABASE_ID`: Cloudflare D1 edge database configuration.
   - `NEXT_PUBLIC_FIREBASE_*`: Firebase Client configuration keys.

5. **Start the local development server:**
   ```bash
   npm run dev
   ```
   Open [http://localhost:3000](http://localhost:3000) in your browser.

6. **Execute production build:**
   ```bash
   npm run build
   ```

7. **Execute test suite:**
   ```bash
   npm test
   ```

---

## 📱 Mobile Application & Production Release APK

The **MyLaws Flutter** application (`MyLaws Flutter/`) and the standalone production APK (`MyLaws-Production-Release.apk`) are fully integrated into this repository to provide 100% offline functionality for citizens in rural or low-connectivity areas.

### Key Capabilities & Architecture:
- **Offline Statutory Corpus:** 1,046 verified statutory provisions across 49 Bangladesh Acts pre-indexed with high-speed SQLite FTS5 search.
- **On-Device Small Language Model & Local AI:** Quantized on-device model support running directly on Android smartphones without internet access.
- **Draft Studio & Offline PDF Generation:** 10 standardized statutory templates (Police GD, DIFE, Domestic Violence, Family Court, Land Crime, SRA 9, Mutation, NI Act 138, Bail) with multi-page print-ready A4 PDF export.
- **Ultra-low RAM Footprint:** Optimized to operate smoothly on low-end budget smartphones (< 45 MB RSS).
- **Dual-Engine Privacy Architecture:** 100% offline local privacy mode alongside high-speed edge cloud sync.

### Download & Inspection:
- **Direct APK in Repository:** [`MyLaws-Production-Release.apk`](./MyLaws-Production-Release.apk)
- **Web Download Showcase:** [https://mylaws-ai.vercel.app/download](https://mylaws-ai.vercel.app/download)
- **Flutter Source Code:** [`MyLaws Flutter/`](./MyLaws%20Flutter/)

---

## ⚖️ Legal Disclaimer

**MyLaws** is an AI-assisted legal information and document preparation system created for educational and civic empowerment purposes. **It does not provide formal legal advice, does not establish an attorney-client relationship, and is not a substitute for licensed legal counsel, law enforcement, or the judiciary.**

For urgent legal assistance, citizens are urged to consult an advocate registered with the Bangladesh Bar Council or contact the **National Legal Aid Services Helpline at 16699** (toll-free).

---

*Developed with ❤️ by **Team Three Dimensions** for the **CoU AI Hackathon 2026**.*
