# MyLaws (আমার অধিকার ও আইন) ⚖️

> **A citizen-first legal companion for Bangladesh.**  
> Explaining everyday rights in warm, polite Bangla (আপনি) and English, citing the actual statutory laws, offering practical step-by-step action checklists, and drafting formal legal documents when you need them.

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Tests](https://img.shields.io/badge/Tests-99%2F99%20Passing-success?logo=github-actions&logoColor=white)](test/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-blue)]()

---

## Why MyLaws Exists

Navigating the legal system in Bangladesh can feel intimidating, expensive, and overwhelming. When an employer refuses to pay three months of wages, when a tenant faces unlawful eviction, or when someone is harassed online or cheated by a seller, most people don't know:
- *What specific law protects me?*
- *What should I do first, second, and third?*
- *Which office do I visit, and how do I write a formal complaint?*

**MyLaws** was built to bridge this gap. It does not replace a lawyer or act as a court, nor does it ever file cases without your control. Instead, it acts as an honest, trustworthy legal guide in your pocket: translating dense statutory provisions into everyday language, grounding every claim in verified legislation, breaking problems into bite-sized checklists, and preparing formal, court-ready drafts.

---

## 💡 What Makes MyLaws Different

### 1. Plain, Dignified Language (Polite "আপনি")
Legal issues are stressful. MyLaws speaks with empathy, patience, and cultural dignity. Whether you speak standard Bangla, English, or conversational phrasing, it understands your situation and gives clear, structured explanations without confusing legal jargon.

### 2. Dual-Engine Architecture (Online Speed + 100% Offline Privacy)
- **Online Mode:** Powered by a high-speed Cloudflare Edge API Worker, Cloudflare D1 serverless database, and Meta AI model reasoning for comprehensive legal grounding.
- **Offline Mode:** Download the on-device AI model (quantized Llama 3.2 1B, ~808 MB) and access the full statutory corpus completely offline. Perfect for remote areas, low connectivity, or total privacy.

### 3. Citations You Can Actually Verify
We never hallucinate remedies or cite non-existent laws. Every explanation links directly to the specific Act and Section from the *Laws of Bangladesh* and the *Bangladesh Gazette*, complete with verbatim statutory excerpts and official government URLs.

### 4. Interactive Citizen Checklists
Understanding the law is only half the battle—knowing what to do next is what matters. MyLaws builds a personalized, sequential checklist for your exact scenario:
- What evidence or receipts to preserve right now.
- What written notice to send to the other party.
- Which office or helpline (DIFE, DNCRP, Police Station, Legal Aid 16430) to contact.

### 5. Instant Formal Document Drafting & A4 PDF Export
Tired of paying for basic petition templates? MyLaws automatically formats and drafts ready-to-print legal documents according to standard Bangladeshi legal formats:
- **Police GD (General Diary):** Section 44, Police Act 1861 & Section 155 CrPC (threats, lost items, security concerns)
- **DIFE Labour Complaint:** Sections 132 & 289, Bangladesh Labour Act 2006 (unpaid wages, arbitrary termination)
- **DNCRP Consumer Complaint:** Sections 44, 45 & 76, Consumer Rights Protection Act 2009 (defective goods, overpricing)
- **Land Mutation & Land Dispute Complaints:** State Acquisition & Tenancy Act 1950 & Land Crime Prevention Act 2023
- **Cheque Dishonour Legal Notice:** Section 138, Negotiable Instruments Act 1881
- **Criminal Bail Petition:** Sections 496 & 497, Code of Criminal Procedure 1898
- **Family Court Maintenance & Domestic Violence:** Family Courts Act 2023 & Domestic Violence Act 2010

---

## 🛡️ Core Legal Areas Covered

| Domain | Key Statutes & Protections | Common Problems Solved |
| :--- | :--- | :--- |
| **Work & Employment** | Bangladesh Labour Act 2006 | Unpaid salaries, sudden dismissal, overtime dues, maternity benefits |
| **Police & Security** | Police Act 1861, CrPC 1898 | Threats, extortion, lost documents, physical intimidation, GD drafting |
| **Consumer Protection** | Consumer Rights Protection Act 2009 | Fraudulent online orders, expired medicine, fake goods, refund refusal |
| **Cyber & Digital Safety** | Cyber Security Act, Pornography Control Act | Facebook/WhatsApp blackmail, leaked photos, account hacking, online abuse |
| **Land & Property** | Land Crime Prevention Act 2023, SAT Act 1950 | Forged deeds, illegal land-grabbing, tenant harassment, boundary disputes |
| **Family & Marriage** | Muslim Family Laws 1961, Family Courts Act 2023 | Unpaid dower (দেনমোহর), child maintenance, dowry demands, custody |
| **Rights & Legal Aid** | Legal Aid Services Act 2000, CrPC ss. 54 & 61 | Illegal detention, right to free government lawyer (Helpline 16430) |

---

## 🔒 Privacy & Safety Principles

- **No Secrets or Credentials in App:** All authentication is handled through secure OAuth and token verification.
- **Strict Data Scrubbing:** Built-in loggers automatically redact sensitive information (Bangladeshi mobile numbers, email addresses, auth tokens) so private information is never logged.
- **Full Citizen Ownership:** In-app controls allow you to export your drafts, erase local case history, or delete your account at any time.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.27 or newer)
- Java 17+ and Android SDK 35
- Git

### 1. Clone & Setup
```bash
git clone https://github.com/EFTAKHAR-AMIN-SAKIB/mylaws-flutter.git
cd mylaws-flutter
flutter pub get
```

### 2. Run Test Suite & Static Analysis
```bash
# Run all 99 automated tests
flutter test

# Verify code analysis (0 errors, 0 warnings)
dart analyze lib
dart analyze test
```

### 3. Launching the App

#### Web Browser (Live Cloudflare Edge + Meta AI backend)
```bash
flutter run -d chrome -t lib/main_live.dart --web-port 8080
```

#### Android (Production Mode)
```bash
flutter run --flavor prod -t lib/main_live.dart
```

#### Android (Offline Dev Mode with synthetic fixtures)
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

---

## 📦 Building for Production

### Build Flutter Web Release
```bash
flutter build web -t lib/main_live.dart --release
```
The compiled SPA is output to `build/web/`, ready to deploy to Cloudflare Pages, Vercel, or Netlify.

### Build Android Release APK
```bash
flutter build apk --flavor prod --release --android-skip-build-dependency-validation
```
The output APK is generated at:
`build/app/outputs/flutter-apk/app-prod-release.apk`
- **Architecture:** Universal Android (ARM64, ARMv7, x86_64)
- **Minimum OS:** Android 8.0 (API 26)
- **Target OS:** Android 15 (API 35)

---

## ⚠️ Legal Notice & Disclaimer

MyLaws is an informational legal literacy and citizen aid software tool. It is not an attorney, law firm, or government office. Using this software does not form an attorney-client relationship. While all statutory citations and legal formulations are grounded in official legislation of the People's Republic of Bangladesh, always consult a licensed advocate enrolled with the Bangladesh Bar Council for formal litigation or complex contentious matters.
