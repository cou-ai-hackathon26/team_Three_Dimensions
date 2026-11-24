# MyLaws — 03: Shared Contract (proposed v1)

Prepared 2 November 2026. Status: a proposed starting contract, not an inspected one. The website's real responses have not been checked against it. Prompt 02, checkpoint A, must reconcile this file with the actual repository, then publish the final `contract/openapi.yaml` and JSON Schemas. Until then, both agents use this file as the single shared reference so the UI and the service do not drift apart.

Rules for changing it: additive changes only after checkpoint A. Any breaking change bumps `schemaVersion`. The website must keep working.

Conventions:
- IDs are ULIDs or UUIDv7 strings. Timestamps are ISO 8601 UTC. Text is UTF-8.
- Language codes: `bn`, `en`. Field names are camelCase in JSON.
- All example text is synthetic. Nothing below is legal content.

---

## 1. Endpoints (inspect what already exists, then adapt)

| Method and path | Purpose | Auth |
| :-- | :-- | :-- |
| `POST /api/v1/answer` | One conversational turn | Firebase ID token |
| `GET /api/v1/status` | Capability and last live success, no Meta call | none or token |
| `GET /api/v1/manifest` | Signed release manifest for packs | none |
| `GET /api/v1/sources/{sourceId}` | One source record and passage | none or token |
| `GET /api/v1/offices` | Verified offices by territory and service | none or token |
| `POST /api/v1/drafts/prepare` | Draft eligibility and minimized wording help | token |
| `GET /api/v1/user/quota` | Remaining quota and reset time | token |
| `GET /api/v1/user/history` | Cloud history list, only if the user opted in | token |
| `PUT /api/v1/user/history/{caseId}` | Save one case to cloud history, explicit action | token |
| `DELETE /api/v1/user/history` | Delete cloud history (scoped) | token |
| `DELETE /api/v1/user/account` | Delete account and associated data | token, recent sign-in |

Existing routes (`/api/answer`, `/api/user/sync`, `/api/user/history`, `/api/sources`, `/api/offices`, `/api/drafts/prepare`, `/api/manifest`, `/api/status`) stay working. `/api/v1/*` is a compatible adapter.

Every response carries `X-Request-Id`. Every request sends `X-Client-Version` and `X-Schema-Version`.

---

## 2. Shared types

```ts
type Lang = "bn" | "en";

type ProcessingEngine =
  | "online_meta"
  | "online_guided_fallback"
  | "offline_model"
  | "offline_guided"
  | "demo_fixture";

type Outcome =
  | "answered"
  | "clarification_needed"
  | "insufficient_sources"
  | "unsupported_scope"
  | "emergency_referral";

type Intent =
  | "new_issue" | "clarification_answer" | "follow_up_explain"
  | "correction" | "add_fact" | "draft_request" | "thanks"
  | "language_change" | "other";

type FactStatus =
  | "user_stated" | "user_confirmed" | "inferred"
  | "corrected" | "unknown" | "declined";

interface Fact {
  fieldId: string;               // canonical, see section 3
  value: string | number | boolean | null;   // normalized value (Arabic digits, ISO date)
  valueType: "text" | "amount_bdt" | "integer" | "date" | "choice" | "bool";
  originalText?: string;         // exactly what the person wrote
  status: FactStatus;
  uncertainty?: "approximate" | "unsure";
  originTurnId: string;
  introducedInRevision: number;
  correctsRevision?: number;     // set when status = "corrected"
}
```

---

## 3. Canonical field IDs (starter registry)

Extend from the website's real fields. IDs are stable and never reused for a different meaning.

| fieldId | valueType | Meaning |
| :-- | :-- | :-- |
| `issue.category` | choice | labour, rent, cheque, police, consumer, etc. (from coverage manifest) |
| `issue.scopeId` | text | issue within a case (related issues can share a case) |
| `incident.date` | date | when it happened |
| `incident.district` | text | district of the incident |
| `incident.upazila` | text | upazila or thana area |
| `incident.place` | text | place of occurrence |
| `employment.type` | choice | permanent, contract, daily rated, other, unknown |
| `employment.sector` | choice | private, public service, EPZ, other, unknown |
| `employment.workplaceDistrict` | text | workplace district |
| `wage.monthlyAmount` | amount_bdt | agreed monthly pay |
| `wage.unpaidAmount` | amount_bdt | amount owed |
| `wage.unpaidMonths` | integer | months unpaid |
| `wage.lastPaidDate` | date | last payment |
| `party.employerName` | text | employer or other party (local-only when possible) |
| `applicant.name` | text | draft only, local |
| `applicant.phone` | text | draft only, local |
| `applicant.address` | text | draft only, local |
| `draft.requestedAssistance` | text | what the person wants from the office |

`applicant.*` fields stay on the device unless the person explicitly allows otherwise. They are not sent for routine explanation requests.

---

## 4. `POST /api/v1/answer`

### 4.1 Request

```ts
interface AnswerRequest {
  schemaVersion: "1.0";
  requestId: string;             // new per attempt
  idempotencyKey: string;        // same across retries of one turn
  caseId: string;
  turnId: string;
  parentRevision: number;        // case revision the client last saw; 0 for new case
  answerLanguage: Lang;
  processing: { preference: "online"; cloudConsent: true };  // server rejects if consent absent
  message: { text: string; clientLanguageHint?: Lang };
  facts: Fact[];                 // current structured facts known to the client
  clarificationAnswers: {
    clarificationId: string;
    fieldId: string;
    value: Fact["value"] | null;
    status: "answered" | "unknown" | "declined";
    originalText?: string;
  }[];
  recentExchanges: { role: "user" | "assistant"; text: string; turnId: string }[]; // bounded
  client: { appVersion: string; platform: "android" | "web"; packVersion?: string };
}
```

Server limits (returned by `/status` as `limits`, never hardcoded in the app): max message characters, max facts, max exchanges, max payload bytes.

### 4.2 Response

```ts
interface AnswerResponse {
  schemaVersion: "1.0";
  requestId: string;
  caseId: string;
  turnId: string;
  revision: number;              // new case revision
  outcome: Outcome;
  intent: Intent;                // as interpreted by the service
  language: Lang;
  provenance: {
    engine: ProcessingEngine;
    model?: string;              // configured model name, only for online_meta
    sourceSnapshotVersion: string;
    rulesVersion: string;
    policyVersion: string;
    templatesVersion?: string;
  };

  reply: { text: string; claims: Claim[] };           // concise conversational text
  understanding?: { text: string; claims: Claim[] };
  explanation?: { summary?: string; claims: Claim[] };
  checklist?: ChecklistStep[];
  limitations?: Limitation[];
  pendingClarifications: Clarification[];
  draftOffers: DraftOffer[];

  caseState: {
    revision: number;
    facts: Fact[];
    supersededComponents: {
      componentType: "reply" | "understanding" | "explanation" | "checklist_step" | "limitation" | "draft_offer";
      componentId: string;
      supersededByRevision: number;
      reason: "fact_corrected" | "source_changed" | "scope_changed";
    }[];
  };

  evidence: EvidenceItem[];      // resolved by the service from trusted records
  quota: { limit: number; remaining: number; resetsAt: string; timezone: string } | null;
  referral?: EmergencyReferral;  // present when outcome = "emergency_referral"
}

interface Claim {
  id: string;
  text: string;
  kind: "legal" | "procedural" | "general";
  evidenceRefs: { evidenceId: string }[];   // required and non-empty for "legal" and "procedural"
}

interface EvidenceItem {
  evidenceId: string;
  sourceId: string;
  sourceRevision: string;
  actTitle: { bn?: string; en?: string };
  section?: string;
  officialUrl?: string;
  passageOriginal: string;       // exact stored text
  passageSpan?: { start: number; end: number };
  translation?: string;          // clearly separate from the original
  legalStatus: "in_force" | "amended" | "repealed" | "unknown";
  effectiveDate: string | null;  // null stays null, never a placeholder
  retrievedAt: string;
  checkedAt: string | null;
  reviewStatus: "machine_checked" | "native_reviewed" | "professionally_reviewed";
}

interface ChecklistStep {
  stepId: string;                // stable across revisions
  title: string;
  detail?: string;
  requiredDocuments: string[];
  helpfulRecords: string[];
  office?: OfficeRef;
  claims: Claim[];
  needsRecheck?: boolean;
}

interface Limitation {
  id: string;
  text: string;
  claims: Claim[];
}

interface OfficeRef {
  officeId?: string;
  name?: string;
  address?: string;
  phone?: string;
  coverage: "verified" | "unresolved";
  coverageNote?: string;
  sourceId?: string;
  checkedAt?: string;
}

interface Clarification {
  clarificationId: string;
  fieldId: string;
  prompt: string;
  whyItMatters: string;
  inputType: "single_choice" | "multi_choice" | "text" | "date" | "amount" | "place";
  options?: { value: string; label: string }[];
  allowUnknown: boolean;
  allowDecline: boolean;
}

interface DraftOffer {
  templateId: "gd_application" | "dife_complaint" | "dncrp_complaint";
  templateRevision: string;
  title: string;
  eligible: true;                // ineligible offers are never sent
  missingFields: string[];       // fieldIds still needed
  recipient: { state: "verified" | "unresolved"; name?: string };
}

interface EmergencyReferral {
  text: string;
  contacts: { label: string; phone?: string; sourceId: string; checkedAt: string }[];
}
```

Invariants the service must guarantee and the app may rely on:
1. Every `legal` or `procedural` claim has at least one `evidenceRef`, and every ref resolves to an item in `evidence`.
2. Unknown source IDs never appear. Quotations in `passageOriginal` come from stored records only.
3. `outcome = "answered"` is never produced by a transport failure or a provider failure.
4. `draftOffers` contains only eligible offers.
5. `provenance.engine` is the engine that actually produced the content.

### 4.3 Error body (HTTP 4xx and 5xx)

```ts
interface ErrorBody {
  schemaVersion: "1.0";
  requestId: string;
  code:
    | "unauthenticated" | "token_expired" | "cloud_consent_required"
    | "quota_exceeded" | "rate_limited"
    | "invalid_request" | "payload_too_large" | "unsupported_schema_version"
    | "stale_revision" | "duplicate_in_progress"
    | "provider_unavailable" | "provider_quota" | "timeout"
    | "persistence_failed" | "service_unavailable";
  message: { bn: string; en: string };       // safe, no internals
  retry: { retryable: boolean; afterSeconds?: number };
  quota?: AnswerResponse["quota"];
}
```

Mapping to HTTP: 401 `unauthenticated`/`token_expired`, 403 `cloud_consent_required`, 409 `stale_revision`/`duplicate_in_progress`, 413 `payload_too_large`, 422 `invalid_request`, 426 `unsupported_schema_version`, 429 `quota_exceeded`/`rate_limited`, 502/503/504 provider and service errors. Insufficient sources and unsupported scope are not errors: they are HTTP 200 with the matching `outcome`.

Idempotency: a repeat of the same `idempotencyKey` returns the stored result without a second provider call or quota charge. If the first attempt is still running, return `duplicate_in_progress` with `retry.afterSeconds`.

---

## 5. Draft preparation

`POST /api/v1/drafts/prepare` takes `{ templateId, templateRevision, caseId, revision, minimizedFacts }` and returns eligibility, the list of missing fields, recipient state, and optional neutral wording suggestions for non-identity text. It never receives `applicant.*` unless the person allowed it. The document itself is rendered locally from the versioned template.

```ts
interface DraftDocumentModel {
  draftId: string;
  templateId: DraftOffer["templateId"];
  templateRevision: string;
  caseId: string;
  basedOnRevision: number;
  fields: {
    fieldId: string;
    value: string | null;
    origin: "user_confirmed" | "prefilled_unconfirmed" | "missing";
    originalValue?: string;      // preserved when the user edits a prefilled value
  }[];
  recipient: { name: string | null; state: "verified" | "unresolved" };
  reviewed: boolean;             // reset by any material edit
  status: "draft" | "needs_review" | "ready" | "exported" | "needs_recheck";
  versions: { versionId: string; savedAt: string; exportedAs?: "pdf" | "text" }[];
}
```

---

## 6. Release manifest

```ts
interface ReleaseManifest {
  manifestVersion: number;       // monotonic, used for revocation
  generatedAt: string;
  keyId: string;                 // which trusted public key signed it
  release: { releaseId: string; version: string; componentIds: string[] };
  components: {
    id: string;
    type: "legal_text" | "procedure_directory" | "guidance_rules" | "templates"
        | "search_index" | "query_encoder" | "model" | "tokenizer";
    version: string;
    bytes: number;
    sha256: string;
    url: string;
    schemaVersion: string;
    minAppVersion: string;
    requires?: { componentId: string; versionRange: string }[];
    coverage?: { categories: string[]; actCount?: number; provisionCount?: number };
    license?: { name: string; attribution?: string; url?: string };
  }[];
  signature: { alg: "Ed25519"; value: string };   // over the JCS-canonicalized manifest without this field
}
```

---

## 7. Status

`GET /api/v1/status` returns configuration flags, `lastLiveSuccess` per dependency (auth, D1, Meta) with timestamps, current capability (`onlineAssistant: "available" | "degraded" | "unavailable"`), `limits`, `sourceSnapshotVersion`, `rulesVersion`, and the current quota policy (limit, timezone). It must not call Meta to answer.

---

## 8. Synthetic fixtures (starting set)

Store each as a separate file in `contract/fixtures/`. Text below is placeholder content.

### 8.1 Clarification needed

```json
{
  "schemaVersion": "1.0",
  "requestId": "req_fixture_001",
  "caseId": "case_fixture_001",
  "turnId": "turn_fixture_001",
  "revision": 1,
  "outcome": "clarification_needed",
  "intent": "new_issue",
  "language": "bn",
  "provenance": {
    "engine": "demo_fixture",
    "sourceSnapshotVersion": "synthetic-0",
    "rulesVersion": "synthetic-0",
    "policyVersion": "synthetic-0"
  },
  "reply": { "text": "[SYNTHETIC SAMPLE: not legal content] আরও একটি তথ্য দরকার।", "claims": [
    { "id": "c1", "text": "[SYNTHETIC] general acknowledgement", "kind": "general", "evidenceRefs": [] }
  ]},
  "pendingClarifications": [{
    "clarificationId": "clar_fixture_001",
    "fieldId": "employment.type",
    "prompt": "[SYNTHETIC] আপনার চাকরির ধরন কী?",
    "whyItMatters": "[SYNTHETIC] ধরন অনুযায়ী পরের ধাপ আলাদা হতে পারে।",
    "inputType": "single_choice",
    "options": [
      { "value": "permanent", "label": "স্থায়ী" },
      { "value": "contract", "label": "চুক্তিভিত্তিক" },
      { "value": "daily_rated", "label": "দৈনিক মজুরি" }
    ],
    "allowUnknown": true,
    "allowDecline": false
  }],
  "draftOffers": [],
  "caseState": { "revision": 1, "facts": [], "supersededComponents": [] },
  "evidence": [],
  "quota": null
}
```

### 8.2 Correction with superseded component (shape only)

```json
{
  "outcome": "answered",
  "intent": "correction",
  "revision": 3,
  "caseState": {
    "revision": 3,
    "facts": [{
      "fieldId": "wage.unpaidAmount",
      "value": 12000,
      "valueType": "amount_bdt",
      "originalText": "১২ হাজার",
      "status": "corrected",
      "originTurnId": "turn_fixture_003",
      "introducedInRevision": 3,
      "correctsRevision": 2
    }],
    "supersededComponents": [{
      "componentType": "explanation",
      "componentId": "exp_rev2",
      "supersededByRevision": 3,
      "reason": "fact_corrected"
    }]
  }
}
```

### 8.3 Error: quota exceeded

```json
{
  "schemaVersion": "1.0",
  "requestId": "req_fixture_429",
  "code": "quota_exceeded",
  "message": {
    "bn": "আজকের অনলাইন প্রশ্নের সীমা শেষ হয়েছে।",
    "en": "Today's online question limit is reached."
  },
  "retry": { "retryable": false },
  "quota": { "limit": 0, "remaining": 0, "resetsAt": "2026-11-03T18:00:00Z", "timezone": "Asia/Dhaka" }
}
```

The numbers above are fixture values. Real limits and reset times come from the service.

Also create fixtures for: insufficient sources, unsupported scope, emergency referral (synthetic contacts), each remaining error code, a draft document model, and a signed manifest (test key only).
