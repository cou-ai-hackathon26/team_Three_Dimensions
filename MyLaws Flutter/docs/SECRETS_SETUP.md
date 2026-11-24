# MyLaws — Secrets & Environment Configuration Guide

**Updated:** 2 November 2026  
**Security Policy:** Strict Zero-Secret Architecture per `AGENTS.md`  

---

## 1. Core Security Rules

1. **Client Application (`MyLaws Flutter`):**
   - **Zero Secrets in Code:** The Flutter client MUST NOT contain any private API keys, database credentials, service account tokens, or signing private keys.
   - **Zero Secrets in Git:** Never commit keystores, `.jks` files, `.env` files with secret values, or credentials into repository branches.
   - **Non-Secret Configuration Only:** Client configuration is restricted to public URLs and identifiers:
     - `API_BASE_URL` (default: `https://mylaws-bd.vercel.app`)
     - `FIREBASE_PROJECT_ID` (`mylaws-bd`)
     - Android Application ID (`bd.mylaws.frontend`)

2. **Server Backend (`reference/website`):**
   - All server-side secrets (Meta API key, Cloudflare API token, D1 database ID) reside in Vercel environment variables or local uncommitted `.env.local`.
   - Never expose `MODEL_API_KEY` or `CLOUDFLARE_API_TOKEN` to the browser or mobile client.

---

## 2. Environment Variables Reference

### Shared Backend (Next.js & Cloudflare D1)

| Variable | Environment | Description | Example / Notes |
| :--- | :--- | :--- | :--- |
| `MODEL_API_KEY` | Server only | Meta AI / LLM Inference API Key | Private, injected in Vercel secrets |
| `META_MODEL` | Server only | Model identifier | `muse-spark-1.3` / `llama-3.3-70b` |
| `CLOUDFLARE_ACCOUNT_ID` | Server only | Cloudflare Account ID | Injected in server environment |
| `CLOUDFLARE_API_TOKEN` | Server only | D1 REST API Token | Strictly secret |
| `CLOUDFLARE_D1_DATABASE_ID` | Server only | Cloudflare D1 Database ID | UUID |
| `DAILY_QUERY_LIMIT` | Server only | Quota limit per authenticated user | `30` (default) |
| `NEXT_PUBLIC_FIREBASE_PROJECT_ID` | Server & Client | Firebase Auth Project ID | `mylaws-bd` (public) |

### Flutter Client Configuration

Build arguments passed during compile time (non-sensitive only):

```bash
# Development flavor (pure synthetic fixtures)
flutter run --flavor dev -t lib/main_dev.dart

# Staging flavor (pointing to preview or staging URL)
flutter run --flavor staging -t lib/main_staging.dart --dart-define=API_BASE_URL=https://staging.mylaws.bd

# Release flavor (production shared backend)
flutter build apk --flavor release --release --dart-define=API_BASE_URL=https://mylaws-bd.vercel.app
```

---

## 3. Android Signing Configuration (Release Build)

For release APK builds:
1. Create a `key.properties` file in `android/` (**NEVER commit this file**; it is ignored by `.gitignore`):
   ```properties
   storePassword=YOUR_SECURE_STORE_PASSWORD
   keyPassword=YOUR_SECURE_KEY_PASSWORD
   keyAlias=mylaws_release
   storeFile=/path/to/keystore/upload-keystore.jks
   ```
2. When building in CI/CD, inject the keystore bytes as a base64 environment variable `ANDROID_KEYSTORE_BASE64` and decode it dynamically before running `flutter build apk`.

---

## 4. Privacy & Audit Logs

- `AppLogger.redact` automatically scrubs:
  - Bangladesh mobile numbers: `(?:\+8801\|01)\d{9}` -> `[REDACTED_PHONE]`
  - Email addresses: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}` -> `[REDACTED_EMAIL]`
  - Bearer tokens: `Bearer\s+[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\...` -> `Bearer [REDACTED_TOKEN]`
- Server routes reject logging raw narrative text to Cloudflare or Vercel log streams.
