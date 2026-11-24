import type { AndroidReleaseManifest, PackState } from '@/types/contracts';

export const legalPackManifest: PackState = {
  id: 'bd-release-2026-11-01.1',
  modelVersion: 'deterministic-statutory-v2',
  legalVersion: '2026.11.01-fundamental-rights-whistleblower-complete',
  indexVersion: 'fts-bm25-v2',
  templateVersion: 'templates-v2',
  status: 'ready',
  compatible: true,
  coverage: [
    '1,046 statutory provisions across 7 core categories from 49 Bangladesh statutes',
    'Labour Act 2006, Labour Rules 2015 & RMG Minimum Wages (Wages, retrenchment, maternity, working hours)',
    'The Penal Code 1860, CrPC 1898, Police Act 1861, Arms Act 1878 & Narcotics 2018 (Crimes, GD, arrest, bail)',
    'Cyber Protection Act 2026, Pornography Control Act 2012, Copyright Act 2023 & BTRC Directives (Cyber extortion, piracy, telecom)',
    'Consumers’ Right Protection Act 2009, Food Safety Act 2013, BSTI Act 2018, Drugs Control 1982 & E-commerce Guidelines 2021',
    'Land Crime Act 2023, SRA 1877, Rent Control 1991, Real Estate Act 2010, Acquisition 2017 & Partition Act 1893',
    'Family Courts Act 2023, MFLO 1961, Domestic Violence Act 2010, Dowry 2018, Parents Care 2013, Children Act 2013, Succession 1925 & Special Marriage 1872',
    'Constitution of Bangladesh 1972 (Fundamental Rights), Legal Aid Act 2000, Whistleblower Protection Act 2011 & Supreme Court BLAST Guidelines'
  ],
  sizeBytes: 2500000,
  freeBytesRequired: 5000000,
  completedBytes: 2500000,
  error: null,
};

export const androidReleaseManifest: AndroidReleaseManifest = {
  version: '1.0.0',
  versionCode: 1,
  releaseDate: '2026-11-24',
  status: 'available',
  apkUrl: '/downloads/MyLaws-Production-Release.apk',
  fileSizeBytes: 77519992, // 73.9 MB (~74 MB)
  sha256Checksum: '5eff20c8eda2132a50294bf883bf9061527121669c24725734dc952e842f65d5',
  minimumAndroidVersion: 'Android 8.0 (API level 26)',
  recommendedRam: 'Ultra-lightweight: Runs smoothly on low-end devices with minimal RAM (1 GB / 2 GB), as well as standard 4 GB devices',
  testedDevices: [
    'Pixel 6 / 7 / 8 / 9 (Android 14 & 15) - Full Flutter 3.27+ engine & Noto Bengali typography verified',
    'Samsung Galaxy A14 / A04 & Budget Entry Devices (1 GB / 2 GB / 4 GB RAM) - Tested UI & PDF generation',
    'Xiaomi Redmi Go & Entry-Level Smartphones (1 GB / 2 GB RAM) - Tested low-memory FTS search',
    'Android Studio Emulator (API 26 to API 35, x86_64)',
  ],
  changeLog: [
    'Official Production Release v1.0.0 with Flutter 3.27+ engine & Riverpod state architecture',
    'Action Checklist: Dynamic state persistence with undo capability and evidence preservation tips',
    'Offline Corpus: 1,046 statutory provisions across 49 Bangladesh Acts pre-indexed with SQLite FTS5',
    'Draft Studio: 10 standardized statutory legal templates (Police GD, DIFE, Domestic Violence, Family Court, Land Crime, SRA 9, Mutation, NI Act 138, Bail)',
    'Ultra-low RAM optimization: Memory footprint tuned for smooth operation on 1 GB / 2 GB budget smartphones',
    'Dual-Engine Architecture: 100% offline local privacy mode + high-speed cloud edge sync',
    'Multi-page print-ready A4 PDF rendering with embedded Bengali font support',
  ],
};
