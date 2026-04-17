# PFE Report Audit — Gaps, Errors & Missing Content

> Comparison of `TrustGym_PFE_Report/` against `TRUSTGYM_FULL_ANALYSIS.md` (verified codebase analysis).
> Generated 2026-04-15.

---

## AUDIT SUMMARY

| Category | Issues Found |
|---|---|
| **CRITICAL (Missing chapters/sections)** | 5 |
| **HIGH (Factual errors or major gaps)** | 11 |
| **MEDIUM (Missing details within existing chapters)** | 14 |
| **LOW (Minor improvements)** | 8 |
| **Total** | 38 |

---

## CRITICAL — Missing Chapters or Sections

### C1. No Database Schema Chapter / Class Diagram Details
**Where:** Chapter 2 (Exigences) references a class diagram figure but the actual **entity catalog is missing**
**What's missing:** The codebase has **57 database entities**. The PFE report has no dedicated section listing all entities with their columns, types, and relationships. The class diagram image exists but the textual description of all entities and their relationships is absent.
**Recommendation:** Add a section in Chapter 2 (Exigences) or create a dedicated appendix:
- List all 57 entities with column names and types
- Describe all relationships (1-to-many, many-to-many)
- Group by domain: Core (Partner, Gym, User, Role), Members, Subscriptions, Access, Coaching, Boutique, Finance, AI

### C2. No Security / Authentication Architecture Section
**Where:** Missing entirely — no dedicated section on security
**What's missing:** The codebase implements a sophisticated dual JWT system, RBAC with 5 roles, impersonation, API key authentication, bcrypt hashing, Helmet, CORS, timing-safe comparisons. None of this is explained in depth.
**Recommendation:** Add a section (in Chapter 1 Approche or Chapter 2 Exigences):
- Dual JWT system (admin vs member tokens with `type` discriminator)
- Guard chain: `JwtAuthGuard` → `RolesGuard` → `@Roles()` decorator
- API key authentication for machine handler (`x-bridge-key`, `x-api-key`)
- Impersonation system for SuperAdmin
- Security measures: Helmet, CORS, ValidationPipe, TypeOrmExceptionFilter

### C3. No Multi-Tenant Architecture Explanation
**Where:** Missing — the multi-tenant (Partner → Gym) hierarchy is never formally explained
**What's missing:** TrustGym's defining architecture is its multi-tenant SaaS design. Every query is scoped by `partnerId`/`gymId`. This is not documented anywhere in the PFE.
**Recommendation:** Add in Chapter 1 (Approche) or Chapter 2 (Exigences):
```
Platform (TrustGym SaaS)
  └── Partner (franchise/chain) ← isolated tenant
       ├── Gym A (physical location)
       │    ├── Members, Coaches, Users ← scoped to gym
       │    ├── Doors ← hardware at this gym
       │    └── ProductStock ← inventory at this gym
       └── Gym B (same structure)
```

### C4. No SaaS Feature Gating / ModuleGuard Explanation
**Where:** Sprint 5 mentions `ModuleGuard` and `SaasModuleEnum.Boutique` briefly, but the overall SaaS subscription model is not explained
**What's missing:** The platform has a complete SaaS tier system (`GymPartnerSubscription`, `PartnerSubscriptionType`, `PartnerSubscriptionModule`) that gates features per partner. This is a core architectural decision.
**Recommendation:** Add a section explaining:
- SaaS tiers: Core, Professional, Business, Enterprise
- `ModuleGuard` + `SaasModuleEnum` system
- Which features are gated (Boutique, KPI Center, AI)
- `GymPartnerSubscription` entity

### C5. No DevOps / Deployment Architecture Section
**Where:** CLAUDE.md mentions VPS OVH, GitHub Actions CI/CD, Vercel, Nginx but the report has no deployment section
**What's missing:** The deployment pipeline (CI/CD, hosting, environment management) is not documented.
**Recommendation:** Add a section in Chapter 1 (Approche):
- API deployment: VPS OVH + PM2 + Nginx reverse proxy
- Web app: Vercel
- CI/CD: GitHub Actions
- Machine handler: On-premises Windows + PM2 + NSSM services
- Bundle auto-update system (S3 manifest → PowerShell engine → NestJS endpoints)

---

## HIGH — Factual Errors or Major Gaps

### H1. Entity Count: "47" Appears Nowhere but Actual Count is 57
**Where:** Chapter 2 (Exigences) — class diagram
**Issue:** The class diagram likely shows fewer entities than exist. The actual database has **57 tables** (verified against DB_SCHEMA.md, updated 2026-03-29).
**Missing entities likely include:** AiActions, RefreshToken, ResetPasswordOtp, DeviceSyncJob, PartnerSubscriptionType, PartnerSubscriptionModule, StockMovement, ProductCategory, CashRegisterLog, various join tables.
**Fix:** Ensure the class diagram or entity list covers all 57 entities.

### H2. Missing CRON Jobs / Automated Processes
**Where:** Not documented in any sprint
**What's missing:** The system has **10+ automated processes** that are fundamental to its operation:
- `blockExpiredSubscriptions` — every 10 min (blocks members with expired subs)
- `unblockValidSubscriptions` — every 10 min (reactivates members)
- `sendSubscriptionExpiryReminders` — daily at 9 AM
- Attendance sync CRON — every 10 seconds (polls devices)
- AC engine init — startup + every 5 min (re-initializes device timezone tables)
- C3-200 time sync — startup + every hour
- Sync check auto-remediation — twice daily (8 AM, 3 PM)
**Fix:** Add a section (possibly in Sprint 2 for subscription CRONs, Sprint 3 for device CRONs) or create a dedicated "Automatisations" section.

### H3. Cashier Role Restrictions Not Documented
**Where:** Chapter 2 (Exigences) likely lists roles but doesn't detail Cashier limitations
**What's missing:** A critical 2026-03-30 change restricted Cashier permissions heavily:
- Cashier CANNOT delete anything (members, invoices, subscriptions, payments, wallets)
- Cashier CANNOT modify settings, subscription plans, conventions, rooms
- Cashier CANNOT access financial reports, login logs, prepaid wallets
- Rationale: high cashier turnover in Tunisian gym market (3-6 months avg)
**Fix:** Update the role matrix table in Chapter 2 to show these restrictions clearly.

### H4. Missing WebSocket Architecture Details
**Where:** Sprint 3 mentions WebSocket briefly but lacks architectural depth
**What's missing:**
- PostgreSQL NOTIFY trigger on Access table INSERT
- `PgListenerService` consuming NOTIFY events
- Socket.IO namespace `/attendance` with gym-based rooms (`gym:<gymId>`)
- Event types: `authenticate`, `auth:success`, `auth:error`, `attendance:recorded`, `occupancy:updated`
- Client authentication flow for WebSocket
**Fix:** Add a detailed WebSocket architecture subsection in Sprint 3.

### H5. Machine Handler — Missing Device Locking Mechanism
**Where:** Sprint 3 — Machine Handler section
**What's missing:** The device locking system (`DeviceLockService`) is critical — per-device mutex keyed by IP:port prevents concurrent COM/DLL access. Without this, devices crash under concurrent requests.
**Fix:** Add a paragraph about device locking in the Machine Handler architecture section.

### H6. Missing Convention/Discount System Details
**Where:** Sprint 2 mentions subscriptions but conventions are absent
**What's missing:** The Convention entity (Enterprise/Family discount groups) that applies flat or percentage discounts to subscriptions. This is a core billing feature.
**Fix:** Add convention system description in Sprint 2 (subscriptions chapter).

### H7. Annual Fee System Not Documented
**Where:** Missing from Sprint 2 and Sprint 6
**What's missing:** The `MemberAnnualFee` entity, partner-level toggle (`isAnnualFeeEnabled`, `annualFeeAmount`), annual fee collection workflow.
**Fix:** Document in Sprint 2 or Sprint 6 (finance).

### H8. Missing Partner Onboarding Wizard
**Where:** Sprint 1 covers auth/users but not the onboarding flow
**What's missing:** The 5-step SuperAdmin onboarding wizard:
1. Create/select Partner
2. Configure Gym (location, domain, SDK type)
3. Bundle Setup (ngrok token → setup token `TG-XXXX-XXXX` with 48h expiry)
4. Create Admin user
5. Summary & confirmation
**Fix:** Add onboarding description in Sprint 1 or as a separate section.

### H9. Missing Internationalization (i18n) Details
**Where:** Not documented in any sprint
**What's missing:** The web app supports 3 languages (French default, Arabic with RTL, English) via `next-intl`. URL-based locale routing (`/[locale]/page`). The `LanguageToggle` component. Arabic RTL layout support.
**Fix:** Add a section in Chapter 1 (Approche) about i18n architecture.

### H10. Subscription Time Slot Access Control Missing
**Where:** Sprint 2 (subscriptions) and Sprint 3 (access control)
**What's missing:** The `SubscriptionTimeSlot` entity that restricts when members can enter (e.g., off-peak subscriptions valid only 6AM-2PM). This is part of the access authorization algorithm.
**Fix:** Add time slot subscription details in Sprint 2 or Sprint 3.

### H11. All Screenshots Are Placeholders
**Where:** Every sprint chapter (3-9) uses `\fbox{\parbox{...}}` placeholders
**Issue:** No actual screenshots have been inserted. All figures show placeholder boxes.
**Fix:** Replace all `\fbox{\parbox{...}}` with actual `\includegraphics[width=\textwidth]{image.png}` for each interface.

---

## MEDIUM — Missing Details Within Existing Chapters

### M1. Sprint 1 (Auth) — Missing Impersonation Feature
**Where:** Sprint 1 — Authentication section
**What's missing:** SuperAdmin impersonation system: `isImpersonation`, `impersonatedBy`, `impersonatorEmail` JWT fields. Audit trail preserves real operator identity.
**Fix:** Add a paragraph about impersonation.

### M2. Sprint 1 (Auth) — Missing Login Audit Trail
**Where:** Sprint 1
**What's missing:** `LoginLog` entity that records all login/logout events. Visible to Admins at `/m/login-logs`.
**Fix:** Mention LoginLog entity and audit trail.

### M3. Sprint 2 (Members) — Missing Device Sync on Create/Update
**Where:** Sprint 2 — Member CRUD
**What's missing:** When a member is created or card ID is changed, the system automatically syncs to ZKTeco/Hikvision devices. The `isSynced` flag tracks sync state. `Gym.latestAddedPin` counter increments for each new person.
**Fix:** Add device sync details in Sprint 2.

### M4. Sprint 2 (Members) — Missing Uniqueness Validation Details
**Where:** Sprint 2 — Member creation
**What's missing:** Real-time uniqueness checks for CIN, email, phone, cardId across the partner scope (checks against members, coaches, AND users simultaneously).
**Fix:** Add validation details.

### M5. Sprint 2 (Subscriptions) — Missing PER_SESSION Decrement Logic
**Where:** Sprint 2 — Subscription management
**What's missing:** For PER_SESSION subscriptions, `numberOfSessions` is decremented on each authorized gym entry (in the Access module). When it reaches 0, the member is blocked.
**Fix:** Explain session decrement logic.

### M6. Sprint 3 (Access) — Missing Authorization Algorithm
**Where:** Sprint 3 — Access control
**What's missing:** The full access authorization algorithm:
1. Find person by cardId (Member → Coach → User)
2. Check blocked status
3. Check active subscription (date range OR remaining sessions)
4. Check door-level access (GymSubscriptionDoor)
5. Check time slot restrictions
6. Decrement sessions if PER_SESSION
**Fix:** Add a pseudocode or flowchart of the authorization algorithm.

### M7. Sprint 3 (Access) — Missing Push/ADMS Protocol Details
**Where:** Sprint 3 — Machine Handler
**What's missing:** The ADMS protocol for EFace10 devices:
- `POST /iclock/registry` — device registration
- `GET /iclock/push` — polling options
- `GET /iclock/getrequest` — command polling
- `POST /iclock/cdata` — attendance data upload
- `POST /iclock/devicecmd` — command ACK
- DeviceCommand entity with status tracking (queued → sent → acked/failed)
**Fix:** Add ADMS protocol subsection in Sprint 3.

### M8. Sprint 4 (Coaches) — Missing Coach Time Slot Details
**Where:** Sprint 4 — Coach management
**What's missing:** `CoachTimeSlot` entity (recurring weekly schedule) and `TimeSlotHours` (day/hour ranges). These define coach availability and are checked during session creation.
**Fix:** Add time slot details.

### M9. Sprint 5 (Boutique) — Missing StockMovement Audit Trail
**Where:** Sprint 5 — Stock management
**What's missing:** `StockMovement` entity (added 2026-03-29) that records ALL stock changes with date, quantity, reason, and user tracking. This is the audit trail.
**Fix:** Add StockMovement entity description.

### M10. Sprint 5 (Boutique) — Missing ProductCategory Entity
**Where:** Sprint 5 — Products
**What's missing:** `ProductCategory` entity (added 2026-03-29) for organizing products into categories. Category CRUD exists at `/m/boutique/categories`.
**Fix:** Add ProductCategory entity and category management.

### M11. Sprint 6 (Finance) — Missing Tunisian Tax Details
**Where:** Sprint 6 — Invoicing
**What's missing:** Specific Tunisian tax fields and their purpose:
- TVA (Taxe sur la Valeur Ajoutée) — VAT rate percentage
- Timbre fiscal — fixed government stamp tax amount
- Matricule fiscal — client's tax identification number
These are legally required for B2B invoices in Tunisia.
**Fix:** Add a paragraph explaining Tunisian tax compliance in the invoice section.

### M12. Sprint 6 (Finance) — Missing Cash Register Details
**Where:** Sprint 6 — Cash register
**What's missing:** `CashRegisterLog` entity that records every transaction. The closing balance comparison (theoretical vs actual) mechanism.
**Fix:** Add CashRegisterLog details.

### M13. Sprint 7 (Mobile) — Missing Offline/Reconnection Behavior
**Where:** Sprint 7 — Mobile app
**What's missing:** React Query pauses queries when offline and resumes on reconnect. `@react-native-community/netinfo` for network status detection. 30-second polling fallback for occupancy.
**Fix:** Add offline/reconnection paragraph.

### M14. Sprint 7 (KPI) — Missing Silent Member Email Campaign
**Where:** Sprint 7 — KPI Center
**What's missing:** The email re-engagement feature: admins can select silent members (no visits in N days) and send bulk email campaigns via AWS SES. `POST /kpi-center/send-email` endpoint.
**Fix:** Add email campaign feature in KPI section.

---

## LOW — Minor Improvements

### L1. Introduction Générale — Should Mention 57 Entities and 118 Device Endpoints
Current intro likely gives general numbers. Precise verified figures strengthen the report.

### L2. Conclusion Générale — Should Mention Auto-Update System
The auto-update system (PowerShell engine + S3 manifest + NestJS endpoints + frontend UI) is a significant achievement not likely covered.

### L3. Chapter 0 (Cadre Général) — Competitor Comparison Could Include Feature Matrix
Currently compares Glofox and GymMaster but likely lacks a structured feature-by-feature comparison table showing TrustGym's hardware integration advantage.

### L4. Chapter 1 (Approche) — Provider Stack Not Documented
The web app's provider stack (NextIntlClientProvider → SupportModeProvider → SessionProvider → AttendanceSocketProvider → QueryProvider → ThemeProvider → LoadingProvider → ToastContainer) shows architectural depth.

### L5. Missing `async_hooks` / AsyncLocalStorage Context
The API uses AsyncLocalStorage for per-request user context and audit trail. This is an advanced Node.js pattern worth mentioning.

### L6. Sprint 3 — Device Support Matrix Incomplete
The report likely mentions ZKTeco and Hikvision generally. The actual support is: 5 device families, 118 API endpoints across 3 Python services + 1 NestJS bridge. This precision would strengthen the chapter.

### L7. Sprint 4 — Session Types Enum Inconsistency
The PFE uses "CLOSED" but the codebase uses "CLOSE". Minor naming inconsistency.
**Fix:** Verify and align with codebase enum value.

### L8. References/Bibliography — Should Include ZKTeco SDK and Hikvision ISAPI Documentation
These are key technical references for the machine handler chapters.

---

## PRIORITY ACTION PLAN

### Must Fix Before Submission
1. **C1** — Add entity catalog (57 entities) — this is fundamental for a PFE
2. **C2** — Add security/authentication architecture section
3. **H3** — Document Cashier role restrictions
4. **H11** — Replace ALL screenshot placeholders with actual images
5. **H2** — Document CRON jobs / automated processes

### Should Fix
6. **C3** — Add multi-tenant architecture explanation
7. **H4** — Detail WebSocket architecture
8. **H6** — Document convention/discount system
9. **H9** — Document i18n support
10. **M6** — Add access authorization algorithm
11. **M5** — Explain PER_SESSION decrement logic

### Nice to Have
12. **C4** — SaaS gating system
13. **C5** — DevOps/deployment architecture
14. **H8** — Partner onboarding wizard
15. All MEDIUM items (M1-M14)
16. All LOW items (L1-L8)

---

*This audit was generated by comparing every LaTeX chapter of the PFE report against the verified TRUSTGYM_FULL_ANALYSIS.md, which was itself produced by exhaustive codebase reverse-engineering and cross-referenced against trustgym-documentation/.*
