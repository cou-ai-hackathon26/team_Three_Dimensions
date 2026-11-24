# MyLaws — Offline & Target Device Performance Report

**Date:** 2 November 2026  
**Specification:** `docs/handoff/04_ACCEPTANCE_AND_TEST_PLAN.md`, Section 6  
**Target Hardware Baseline:** 4 GB RAM Android Smartphone (ARM64-v8a)  

---

## 1. Performance Budget Definition

Before running device benchmarks, the following performance ceilings are enforced:

| Metric | Budget Ceiling | Notes |
| :--- | :--- | :--- |
| **App Cold Start Time** | < 1,800 ms | Time to interactive Home screen |
| **Base App Memory (Idle)** | < 120 MB RSS | Drift DB open, Riverpod state active |
| **Peak Memory during Pack Query** | < 180 MB RSS | FTS5 full-text search across 255 provisions |
| **Peak Memory during Local Inference** | < 2,400 MB RSS | Optional 1B GGUF model (when enabled) |
| **Time to First Validated Token** | < 2,500 ms | Local prompt eval & retrieval |
| **PDF Generation Latency** | < 600 ms | Multi-page A4 PDF rendering with Bengali glyphs |
| **Storage Footprint (App + Core Pack)** | < 85 MB | App APK (~35 MB) + SQLite pack (~35.4 MB) |
| **Thermal Delta after 10 turns** | < +5.0 °C | Prevents thermal throttling |

---

## 2. Device Test Matrix

| Device Model | Chipset | RAM | OS Version | Status | Evidence / Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Pixel 8 (AVD)** | Google Tensor G3 (Emulated) | 4 GB | Android 14 (API 34) | Configured | Configured in Android SDK emulator pool |
| **Target 4GB Reference Phone** | MediaTek Helio G85 / Snapdragon 680 | 4 GB | Android 12 / 13 | Awaiting device run | Physical hardware pass queued |

---

## 3. ABI & Native Compatibility Audit

1. **64-bit Architecture (`arm64-v8a`):**
   - Both Flutter runtime and SQLite native libraries (`sqlite3_flutter_libs`) compile with 64-bit ABI.
2. **16 KB Memory Page-Size Compatibility:**
   - Android 15 / targetSdk 35 requires all native shared libraries (`.so`) to be 16 KB page-size aligned.
   - Verified that `sqlite3_flutter_libs: ^0.5.24` ships with 16 KB page-aligned shared libraries for Android 15 compliance.
3. **32-bit Fallback:**
   - On 32-bit-only legacy devices (`armeabi-v7a`), the experimental local LLM tier is disabled honestly, and the guided offline SQLite tier remains active.

---

## 4. Current Hardware Verification Status

> **Status Notice per AGENTS.md:**  
> A feature is marked "Verified" only when executed on target hardware or with live calls. In accordance with this rule, physical device thermal and battery measurements are marked **Limited / Awaiting physical device run** pending execution on the user's connected physical phone.
