# TrustGym — Complete Project Analysis & Cahier de Charge

> Cross-referenced against `trustgym-documentation/` (57 files). All facts verified against both codebase and documentation.

---

## 1. PROJECT UNDERSTANDING

### 1.1 Purpose

TrustGym is a **multi-tenant SaaS platform for gym and fitness center management**. It provides an end-to-end solution covering member lifecycle management, subscription billing, physical access control (RFID doors/turnstiles), coach scheduling, boutique/POS inventory, financial reporting, and real-time occupancy analytics.

### 1.2 Problem It Solves

Gym operators face fragmented tooling: separate systems for membership, payments, door access, coaching, and retail. TrustGym unifies these into a single platform with:

- **Physical-digital integration**: RFID badge readers (ZKTeco, Hikvision) connected directly to the membership database — no manual syncing
- **Real-time occupancy**: Members see live gym crowding on their phone; managers see attendance KPIs
- **Multi-site management**: Franchise owners (Partners) manage multiple gyms from one dashboard
- **Tunisian market compliance**: TVA, timbre fiscal, matricule fiscal baked into invoicing
- **Member self-service**: Mobile app for session booking, subscription status, and occupancy checks

### 1.4 Current Business Status

- **Pre-revenue**: 5 live gyms in Tunisia (all currently free)
- **Estimated rebuild cost**: $200K–$350K (149,300 LoC across 4 repos)
- **Most valuable component**: Machine Handler ($60K–$90K rebuild cost, 10-14 months)
- **Revenue unlock**: BIZ-001 (subscription gating) is the single highest-ROI priority — entities exist, enforcement not yet active
- **Path to $500K–$800K valuation**: Enforce SaaS gating → 20+ paying gyms → Ship member app → Integrate payments

### 1.3 Target Users & Stakeholders

| Stakeholder | Role | Interaction |
|---|---|---|
| **Partner (Franchise Owner)** | Top-level tenant; owns 1+ gyms | Manages global settings, subscription plans, suppliers, tax info via SuperAdmin or Admin |
| **Gym Admin** | Day-to-day gym operator | Full dashboard access: members, payments, coaches, boutique, analytics, settings |
| **Cashier** | Front-desk staff | Limited dashboard: member check-in, payments, boutique sales; no settings or reports |
| **SuperAdmin** | Platform operator (TrustGym team) | System-wide: partner onboarding, door management, device sync, bundle updates |
| **Member** | Gym customer | Mobile app: view sessions, book reservations, check occupancy, manage profile |

---

## 2. FEATURE EXTRACTION (By Module)

### 2.1 Authentication & Authorization

| Feature | Description | Users |
|---|---|---|
| Admin/Staff Login | Email + password credentials via NextAuth (web) | Admin, Cashier, SuperAdmin |
| Member Login | Email + password via mobile app JWT | Member |
| Member Registration | Multi-step: email check → identity confirm → OTP email verification → password set | Member |
| Dual JWT System | Separate token types — admin tokens (no `type` field) rejected by member guard and vice versa | All |
| Role-Based Access Control | 5 roles (SuperAdmin, Admin, Cashier, Coach, Member) with decorator-based route protection | All |
| Impersonation | SuperAdmin can impersonate other users; audit trail preserves real operator identity | SuperAdmin |
| Login Audit Trail | All login/logout events logged with timestamps | Admin (view), All (tracked) |

### 2.2 Member Management

| Feature | Description |
|---|---|
| Member CRUD | Create, read, update, delete members with full profile (name, CIN, email, phone, DOB, address, city, gender) |
| RFID Card Assignment | Assign/change badge card IDs; auto-syncs to ZKTeco/Hikvision devices |
| Uniqueness Validation | Real-time check of CIN, email, phone, cardId uniqueness across partner scope |
| Member Blocking/Unblocking | Automatic blocking when subscriptions expire; manual block/unblock with reason |
| Subscription Assignment | Assign subscription plans to members with start/end dates, payment installments |
| Session-Based Subscriptions | Per-session plans that decrement on each gym visit |
| Profile Photo | S3-hosted member images |
| Device Sync | Push member card/PIN data to on-premises access devices |
| Member Status Dashboard | Active vs. blocked member counts with charts |

### 2.3 Subscription & Billing

| Feature | Description |
|---|---|
| Subscription Plan Templates | Reusable plans: name, price, duration (months) or session count, linked to specific doors |
| Member Subscription Instances | Individual assignment with concrete dates, payment schedule, convention discount |
| Payment Installments | Split subscription cost into 2-3 payments (Cash, Check, Bank Transfer) with due dates |
| Payment Tracking | Dashboard with total revenue, today's due payments, unpaid amounts |
| Annual Fees (Insurance) | Partner-level toggle for annual registration fee; tracked separately per member |
| Convention Discounts | Enterprise or Family discount groups: flat amount or percentage off subscription price |
| Time Slot Restrictions | Off-peak subscriptions valid only during specified hours/days |
| Auto-Block/Unblock CRON | Automatic member blocking on subscription expiry; reactivation when valid subscription detected |

### 2.4 Access Control (Doors & Hardware)

| Feature | Description |
|---|---|
| Door Management | CRUD for physical access points: IP, port, password, SDK type, direction (In/Out/InOut) |
| Multi-SDK Support | ZKTeco C3-200 (Pull), EFace10 (Push/ADMS), SCR100 (Standalone), Hikvision DS-K1T804AEF |
| Real-Time Access Logging | Every badge swipe creates an Access record (date, time, member, door, authorized, entry/exit) |
| Subscription-Door Linking | Specific subscription plans grant access to specific doors only |
| Time Slot Access | Configurable weekly schedules restricting when members can enter |
| Live Occupancy | Real-time count of members currently inside gym (last event = ENTRY within time window) |
| Manual Access Entry | Override form for lost badges or system failures |
| Access History | Paginated, filterable log of all badge scans with edit/delete capability |
| Device Command Queue | Push-mode devices (EFace10) poll for commands; queued in `device_commands` table |

### 2.5 Coach & Session Management

| Feature | Description |
|---|---|
| Coach CRUD | Manage coaches: name, profession, hourly fee, card ID, availability schedule |
| Discipline Management | Training types (CrossFit, Boxing, Yoga, etc.) with images |
| Session Scheduling | Calendar-based scheduling with drag-and-drop; assign coach, discipline, gym, time |
| Session Types | OPEN (walk-in), CLOSE (invite-only), RESERVATION (limited slots) |
| Member Booking | Members reserve slots; tracked via SessionInvitation |
| QR Code Check-in | Contactless session access via QR scan (SessionQRCode) |
| Coach Payment Tracking | Hourly rate × duration = session compensation; paid/unpaid status |
| Coach Time Slots | Weekly availability schedule per coach |

### 2.6 Boutique / POS (Point of Sale)

| Feature | Description |
|---|---|
| Product Catalog | Products with name, price, image, category |
| Category Management | Organize products into categories |
| Stock Entry | Record inventory arrivals from supplier purchases |
| Stock Levels | Real-time inventory per gym location |
| Stock Exit | Record stock usage/disposal |
| Inter-Gym Transfer | Move inventory between gym locations |
| Member Sales (POS) | Point-of-sale transactions: member + product + quantity + payment method |
| Stock Movement Audit | Full history of all inventory changes |
| Sales Report | Revenue, P&L, product performance analytics (Admin only) |

### 2.7 Wallet (Prepaid Accounts)

| Feature | Description |
|---|---|
| Digital Wallet | Per-member prepaid balance for in-gym purchases |
| Top-Up | Credit wallet via cash/card (creates positive WalletEntry) |
| Purchase Deduction | Boutique purchases debit wallet (creates negative WalletEntry) |
| Transaction History | Full ledger of wallet credits/debits |

### 2.8 Financial / Invoicing

| Feature | Description |
|---|---|
| Invoice Generation | Create invoices with client info, line items, tax calculation |
| Tunisian Tax Compliance | TVA (VAT), timbre fiscal (stamp tax), matricule fiscal (tax ID) |
| PDF Generation | Invoices rendered as PDF, stored on S3 |
| Cash Register | POS cash drawer tracking with transaction log |

### 2.9 Supplier Management

| Feature | Description |
|---|---|
| Supplier CRUD | Manage vendors: name, phone, email, address, image |
| Purchase Orders | Record inventory purchases from suppliers |

### 2.10 KPI & Analytics Dashboard

| Feature | Description |
|---|---|
| Average Visits/Week | Mean visits per member per week |
| Average Session Duration | Mean time between entry and exit per visit |
| Silent Member Detection | Members with no check-ins in N days (configurable) |
| Peak Hours | Attendance histogram by hour or time period |
| Email Re-engagement | Bulk email campaigns to silent members (AWS SES) |
| Real-Time Occupancy | Live member count via WebSocket |

### 2.11 AI Assistant

| Feature | Description |
|---|---|
| RAG Chatbot | Documentation-based Q&A powered by OpenAI embeddings + pgvector |
| Doc Ingestion | Ingest docs into vector chunks for retrieval |
| Chat Log | Conversation history stored for admin review |

### 2.12 Platform Administration (SuperAdmin)

| Feature | Description |
|---|---|
| Partner Onboarding | Multi-step wizard for new franchise/gym setup |
| Partner Management | CRUD for tenants with tax info, gym count, annual fee config |
| Platform User Management | Create/manage Admin, Cashier, SuperAdmin accounts across partners |
| Door Management | System-wide door/device configuration |
| Device Sync | Push member/coach/user data to on-premises devices |
| Bundle Management | Track and update on-premises machine handler versions per gym |
| Software Updates | System-wide update deployment |
| SaaS Subscription Management | Partner subscription tiers and feature modules |

### 2.13 Mobile App (Member-Facing)

| Feature | Description |
|---|---|
| Dashboard | Live occupancy, gym status, quick links |
| Session Browsing | View available sessions by date |
| Session Booking | Reserve slots in RESERVATION-type sessions |
| My Reservations | View booked sessions |
| Analytics | Peak hour charts, traffic patterns |
| Profile | View/edit personal info, sign out |
| Real-Time Occupancy | Socket.IO updates on member count changes |
| Multi-Step Registration | Email → verify → password flow |

### 2.14 Internationalization

| Feature | Description |
|---|---|
| Multi-Language | French (default), Arabic, English |
| RTL Support | Arabic triggers right-to-left layout |
| Locale Routing | URL-based locale: `/fr/dashboard`, `/ar/dashboard` |

---

## 3. USER ROLES & PERMISSIONS

### 3.1 Role Matrix

| Capability | SuperAdmin | Admin | Cashier | Member (Mobile) |
|---|:---:|:---:|:---:|:---:|
| **Platform Management** |
| Partner CRUD | Yes | - | - | - |
| Door Management | Yes | - | - | - |
| Device Sync | Yes | - | - | - |
| Bundle Updates | Yes | - | - | - |
| Platform Users | Yes | - | - | - |
| **Gym Operations** |
| Dashboard & KPIs | - | Yes | Yes | - |
| Member CRUD | - | Yes | Yes | - |
| Block/Unblock Members | - | Yes | Yes | - |
| Subscription Assignment | - | Yes | Yes | - |
| Payment Collection | - | Yes | Yes | - |
| Coach Management | - | Yes | Yes | - |
| Session Scheduling | - | Yes | Yes | - |
| Access History | - | Yes | Yes | - |
| Login Logs | - | Yes | - | - |
| **Boutique** |
| Product CRUD | - | Yes | Yes | - |
| Sales (POS) | - | Yes | Yes | - |
| Stock Management | - | Yes | Yes | - |
| Sales Report | - | Yes | - | - |
| **Finance** |
| Invoice Management | - | Yes | Yes | - |
| Prepaid Wallets | - | Yes | - | - |
| **Settings** |
| General Info | - | Yes | - | - |
| Subscription Plans | - | Yes | - | - |
| Conventions | - | Yes | - | - |
| Rooms/Facilities | - | Yes | - | - |
| **Mobile App** |
| View Occupancy | - | - | - | Yes |
| Book Sessions | - | - | - | Yes |
| View Profile | - | - | - | Yes |
| View Analytics | - | - | - | Yes |

### 3.2 Role Interactions

```
SuperAdmin ──manages──> Partners ──owns──> Gyms
                                              │
                                    ┌─────────┴─────────┐
                                    │                     │
                                  Admin              Cashier
                                    │                     │
                              (full access)        (limited access)
                                    │                     │
                                    └─────────┬───────────┘
                                              │
                                         manages
                                              │
                                    ┌─────────┴─────────┐
                                    │                     │
                                 Members              Coaches
                                    │                     │
                              (mobile app)         (sessions, access)
```

---

## 4. USE CASES & USER JOURNEYS

### 4.1 SuperAdmin Use Cases

**UC-SA-01: Onboard New Partner**
1. SuperAdmin navigates to `/sa/partners`
2. Clicks "Add Partner"
3. Fills onboarding wizard: partner name, tax ID, TVA rate, timbre, address, gym count
4. Optionally enables annual fee with amount
5. System creates Partner entity
6. SuperAdmin creates Admin user for the partner via `/sa/users`
7. Admin receives credentials and can log in

**UC-SA-02: Configure Door Hardware**
1. SuperAdmin navigates to `/sa/doors`
2. Adds door: name, IP, port, password, SDK type, direction (In/Out/InOut), serial number
3. Associates door with gym
4. Triggers device sync to push existing members to new device
5. Door becomes active for access control

**UC-SA-03: Deploy Bundle Update**
1. SuperAdmin navigates to `/sa/bundles`
2. Views per-gym bundle versions and heartbeat status
3. Initiates update for target gyms
4. Machine handler auto-update service downloads and applies new version
5. Gym heartbeat confirms successful update

### 4.2 Admin Use Cases

**UC-AD-01: Register New Member**
1. Admin navigates to `/m/members`
2. Clicks "Add Member"
3. Fills form: name, CIN, email, phone, DOB, gender, address, card ID
4. System validates uniqueness (CIN, email, phone, cardId within partner scope)
5. Member created; device sync pushes card/PIN to door devices
6. Admin assigns subscription plan with start date, payment schedule

**UC-AD-02: Assign Subscription with Convention Discount**
1. Admin opens member profile
2. Clicks "Add Subscription"
3. Selects subscription plan (e.g., "3 Months All Access")
4. Selects convention (e.g., "Corporate - Company X" with 20% discount)
5. System calculates discounted price
6. Admin splits into 2 payment installments (check + cash)
7. System creates MemberGymSubscription + 2 Payment records

**UC-AD-03: Monitor Dashboard KPIs**
1. Admin navigates to `/m/dashboard`
2. Views: active/blocked member charts, avg visits/week, avg session duration
3. Reviews peak hours chart (selects date, hourly vs. periods view)
4. Scrolls to silent members table
5. Selects inactive members (no visits in 30 days)
6. Sends re-engagement email campaign via dialog

**UC-AD-04: Schedule Coaching Session**
1. Admin navigates to `/m/coaches/planning`
2. Uses calendar drag-and-drop to create session
3. Selects coach, discipline, date/time, type (OPEN/CLOSE/RESERVATION), max slots
4. System creates Session entity
5. For RESERVATION type, members can book via mobile app
6. Coach payment calculated: hourlyFee × duration

**UC-AD-05: Process Boutique Sale**
1. Admin/Cashier navigates to `/m/boutique/vente`
2. Selects member, product, quantity
3. Chooses payment method (Cash, Card, Wallet)
4. If wallet: system deducts from member's prepaid balance
5. System decrements ProductStock for that gym
6. MemberPurchase record created

**UC-AD-06: Generate Invoice**
1. Admin navigates to `/m/finance/cree-facture`
2. Fills client info: name, fiscal number, address
3. Adds line items (subscriptions, products, services)
4. System calculates subtotal + TVA + timbre fiscal
5. Invoice generated as PDF, stored on S3
6. Can be emailed to client

### 4.3 Cashier Use Cases

**UC-CA-01: Check In Member**
1. Member arrives at front desk
2. Cashier views live access notifications (real-time WebSocket feed)
3. If badge scan fails, cashier uses manual access entry form
4. System records access event

**UC-CA-02: Collect Payment**
1. Cashier navigates to `/m/members/echeances`
2. Filters by due date or member
3. Selects payment, marks as paid (amount, payment method)
4. Updates Payment record; if all payments paid, subscription marked as fully paid

### 4.4 Member (Mobile App) Use Cases

**UC-ME-01: Register on Mobile App**
1. Member opens app, taps "Sign Up"
2. Enters email → system checks if email exists
3. Enters personal info
4. Receives OTP email for verification
5. Enters OTP code
6. Sets password
7. Account created, JWT token stored, redirected to dashboard

**UC-ME-02: Check Gym Occupancy**
1. Member opens app dashboard
2. Sees real-time occupancy count (e.g., "23 members currently in gym")
3. Occupancy updates in real-time via Socket.IO
4. Also polls every 30 seconds as fallback

**UC-ME-03: Book a Session**
1. Member taps "Sessions" tab
2. Browses available sessions by date (calendar strip)
3. Selects a RESERVATION session with available slots
4. Taps "Reserve" → system creates SessionInvitation
5. Receives confirmation; reservation appears in "My Reservations"
6. On session day, presents QR code at gym for check-in

**UC-ME-04: View Analytics**
1. Member taps "Analytics" tab
2. Views peak hour charts showing busiest times
3. Uses data to plan visits at less crowded hours

### 4.5 Access Control Flow (Automated)

**UC-HW-01: Badge Swipe → Entry Authorization**
1. Member swipes RFID card at door reader
2. Device records event (card number, PIN, timestamp, door ID)
3. Machine handler CRON (every 10s) polls device for new events
4. System resolves card → Member entity
5. Checks: member not blocked, active subscription, subscription covers this door, within allowed time slot
6. If PER_SESSION subscription: decrements remaining sessions
7. Creates Access record (ENTRY, authorized=true)
8. PostgreSQL NOTIFY trigger fires
9. PgListenerService enriches event
10. WebSocket broadcasts `attendance:recorded` to admin dashboard
11. WebSocket broadcasts `occupancy:updated` to mobile app

---

## 5. TECHNICAL ARCHITECTURE

### 5.1 System Architecture

```
                            ┌──────────────────────────┐
                            │     SuperAdmin / Admin    │
                            │   trustgym-app (Next.js)  │
                            │   Port: 3000              │
                            └───────────┬──────────────┘
                                        │ HTTPS
                                        │
                            ┌───────────▼──────────────┐
                            │    trustgym-api (NestJS)  │
                            │    Port: 3002             │
                            │    PostgreSQL 16          │
                            │    Socket.IO /attendance  │
                            └───┬───────────────────┬──┘
                                │                   │
                    ┌───────────▼───┐       ┌───────▼─────────────┐
                    │  Mobile App   │       │  Machine Handler     │
                    │  (Expo/RN)    │       │  NestJS Bridge :8080 │
                    │  Socket.IO    │       │  + Python APIs       │
                    └───────────────┘       │  :8000 :8001 :8002   │
                                            └───────┬─────────────┘
                                                    │
                                            ┌───────▼─────────────┐
                                            │  Physical Devices    │
                                            │  ZKTeco C3-200       │
                                            │  ZKTeco EFace10      │
                                            │  ZKTeco SCR100       │
                                            │  Hikvision DS-K1T804 │
                                            └──────────────────────┘
```

### 5.2 Technology Stack

| Layer | Technology |
|---|---|
| **Backend API** | NestJS 10, TypeORM, PostgreSQL 16, pgvector, Socket.IO |
| **Web Dashboard** | Next.js 15, React 19, TanStack Query 5, NextAuth, Tailwind CSS, Chart.js |
| **Mobile App** | React Native 0.81, Expo SDK 54, Expo Router, TanStack Query 5, NativeWind 4 |
| **Hardware Bridge** | NestJS 11 + Python FastAPI (3 services), PM2 process manager |
| **Cloud Services** | AWS S3 (images, invoices), AWS SES (email), ngrok (tunneling) |
| **Database** | PostgreSQL 16 with pgvector extension |
| **Languages** | TypeScript (all JS projects), Python (device APIs) |
| **Package Manager** | Yarn |

### 5.3 Data Flow

```
Member Badge Swipe
    → Physical Device (ZKTeco/Hikvision)
    → Python API (device-specific SDK)
    → NestJS Bridge (attendance CRON, 10s interval)
    → PostgreSQL (Access table INSERT)
    → PG NOTIFY trigger
    → trustgym-api PgListenerService
    → Socket.IO broadcast
    → Web Dashboard (admin sees notification)
    → Mobile App (member sees updated occupancy)
```

### 5.4 Multi-Tenant Architecture

```
Platform (TrustGym SaaS)
  └── Partner (franchise/chain)         ← isolated tenant
       ├── Gym A                        ← physical location
       │    ├── Members, Coaches, Users ← scoped to gym
       │    ├── Doors                   ← hardware at this gym
       │    ├── ProductStock            ← inventory at this gym
       │    └── AccessLogs              ← events at this gym
       ├── Gym B
       │    └── (same structure)
       ├── Suppliers                    ← shared across gyms
       ├── Subscription Templates       ← shared across gyms
       └── Conventions                  ← shared across gyms
```

All queries are scoped by `partnerId` and optionally `gymId` to ensure tenant isolation.

---

## 6. DATABASE ANALYSIS

### 6.1 Entity Relationship Diagram (Text)

```
Partner (1) ──── (*) Gym
Partner (1) ──── (*) User
Partner (1) ──── (*) Supplier
Partner (1) ──── (*) Convention
Partner (1) ──── (*) GymPartnerSubscription

Gym (1) ──── (*) Door
Gym (1) ──── (*) Member
Gym (1) ──── (*) Coach
Gym (1) ──── (*) ProductStock
Gym (1) ──── (*) Invoice
Gym (*) ──── (*) GymSubscription  [many-to-many]

Door (1) ──── (*) Access
Door (1) ──── (*) GymSubscriptionDoor

Member (1) ──── (*) MemberGymSubscription
Member (1) ──── (*) Access
Member (1) ──── (1) Wallet
Member (1) ──── (*) WalletEntry
Member (1) ──── (*) MemberPurchase
Member (1) ──── (*) MemberAnnualFee
Member (1) ──── (*) SessionInvitation

MemberGymSubscription (1) ──── (*) Payment
MemberGymSubscription (*) ──── (1) GymSubscription
MemberGymSubscription (*) ──── (1) Convention

GymSubscription (1) ──── (*) GymSubscriptionDoor
GymSubscription (1) ──── (*) SubscriptionTimeSlot

Coach (1) ──── (*) Session
Coach (1) ──── (*) Access
Coach (*) ──── (1) CoachTimeSlot

Session (*) ──── (1) Discipline
Session (1) ──── (1) SessionPayment
Session (1) ──── (*) SessionInvitation

SessionInvitation (1) ──── (1) SessionQRCode

Wallet (1) ──── (*) WalletEntry

Product (1) ──── (*) ProductStock
Product (1) ──── (*) MemberPurchase
Product (1) ──── (*) SupplierPurchase
Product (*) ──── (1) ProductCategory

Supplier (1) ──── (*) SupplierPurchase

Invoice (1) ──── (*) InvoiceLine

User (*) ──── (1) Role
```

### 6.2 Entity Catalog (57 entities — verified against DB_SCHEMA.md, updated 2026-03-29)

| # | Entity | Purpose |
|---|---|---|
| 1 | Partner | Top-level tenant (franchise owner); holds tax config, annual fee settings |
| 2 | Gym | Physical gym location; stores logo, bridge API key, device SDK type, heartbeat |
| 3 | User | Dashboard users (Admin, Cashier, SuperAdmin); has card ID and PIN for door access |
| 4 | Role | RBAC roles: SuperAdmin, Admin, Cashier, Coach, Member |
| 5 | Member | Gym customer; identified by RFID card and PIN; has app password for mobile |
| 6 | Coach | Personal trainer; hourly fee, schedule, access card |
| 7 | Door | Physical access device; IP/port/password, SDK type, direction |
| 8 | Access | Badge event log: date, time, card, authorization status, entry/exit direction |
| 9 | GymSubscription | Subscription plan template: price, duration or session count |
| 10 | MemberGymSubscription | Individual subscription instance: member + plan + dates + payments |
| 11 | Payment | Payment installment: amount, type (Cash/Check/Bank), due date, paid status |
| 12 | GymSubscriptionDoor | Maps subscription plans to accessible doors |
| 13 | SubscriptionTimeSlot | Time-based access restrictions for subscriptions |
| 14 | Convention | Discount group (Enterprise/Family): flat or percentage discount |
| 15 | MemberAnnualFee | Annual registration/insurance fee per member |
| 16 | Wallet | Digital prepaid balance per member |
| 17 | WalletEntry | Individual wallet transaction (credit/debit) |
| 18 | Product | Boutique product: name, price, image, category |
| 19 | ProductCategory | Product classification |
| 20 | ProductStock | Inventory level per product per gym |
| 21 | MemberPurchase | POS transaction: member buys product |
| 22 | Supplier | Product vendor |
| 23 | SupplierPurchase | Inventory purchase order from supplier |
| 24 | StockTransfer | Inter-gym inventory movement |
| 25 | StockMovement | Audit trail of all stock changes |
| 26 | Discipline | Training activity type (CrossFit, Boxing, etc.) |
| 27 | Session | Scheduled coaching session: date, time, coach, discipline, type |
| 28 | SessionPayment | Coach compensation for a session |
| 29 | SessionInvitation | Member booking for a session |
| 30 | SessionQRCode | QR token for contactless session check-in |
| 31 | CoachTimeSlot | Coach weekly availability schedule |
| 32 | TimeSlotHours | Specific day/hour ranges |
| 33 | PartnerTimeSlot | Partner-level time configurations |
| 34 | Invoice | Financial invoice with Tunisian tax fields |
| 35 | InvoiceLine | Individual line item on invoice |
| 36 | CashRegister | POS cash drawer balance per gym |
| 37 | CashRegisterLog | Cash register transaction history |
| 38 | LoginLog | Admin/staff login attempt audit trail |
| 39 | DeviceCommand | Queued commands for push-mode devices |
| 40 | GymPartnerSubscription | SaaS platform subscription per partner |
| 41 | MemberImage | S3 reference for member photo |
| 42 | CoachImage | S3 reference for coach photo |
| 43 | DisciplineImage | S3 reference for discipline image |
| 44 | ProductImage | S3 reference for product image |
| 45 | SupplierImage | S3 reference for supplier image |
| 46 | AIChatLog | AI conversation history |
| 47 | DocChunk | Vector-embedded document chunks for RAG |
| 48 | AiActions | AI action tracking |
| 49 | RefreshToken | Token refresh tracking for auth |
| 50 | ResetPasswordOtp | OTP codes for password reset flow |
| 51 | PartnerSubscriptionType | SaaS subscription tier definitions (Core, Professional, Business, Enterprise) |
| 52 | PartnerSubscriptionModule | Feature modules within subscription tiers |
| 53 | AccessMemberMember | Join table for member-to-member access relationships |
| 54 | DeviceSyncJob | Device sync job tracking (status, logs, results) |
| 55-57 | Various join tables | Many-to-many relationship tables |

---

## 7. BUSINESS LOGIC & RULES

### 7.1 Core Business Rules

| Rule | Description |
|---|---|
| **Subscription Expiry → Block** | Members are automatically blocked when ALL active subscriptions expire (CRON job) |
| **Valid Subscription → Unblock** | Members are automatically unblocked when a valid subscription is detected (CRON job) |
| **Session Decrement** | PER_SESSION subscriptions decrement `numberOfSessions` on each authorized gym entry |
| **Door-Level Access** | A subscription only grants access to doors linked via GymSubscriptionDoor |
| **Time Slot Enforcement** | Access denied if badge swipe occurs outside subscription's allowed time slots |
| **Card Uniqueness** | Card ID must be unique per gym (enforced by DB constraint) |
| **CIN/Email/Phone Uniqueness** | Unique within partner scope (checked across members, coaches, users) |
| **Convention Discount** | Applied at subscription assignment: flat amount or percentage off plan price |
| **Annual Fee Independence** | Annual fees tracked separately from subscriptions; partner-level toggle |
| **Coach Payment Calculation** | SessionPayment = Coach.hourlyFee × session duration in hours |
| **Wallet Balance** | Denormalized in Wallet.amount; actual balance = sum of all WalletEntries |
| **Invoice Immutability** | Client/gym info snapshotted at creation time (not live references) |
| **Tunisian Tax** | Invoices include TVA (VAT rate), timbre fiscal (fixed stamp), matricule fiscal (client tax ID) |
| **Device PIN Counter** | Gym.latestAddedPin incremented for each new person synced to devices |
| **Device Sync Flag** | Member/Coach/User.isSynced tracks whether entity has been pushed to devices |

### 7.2 Access Authorization Algorithm

```
function authorizeAccess(cardId, doorId):
  1. Find person by cardId (Member → Coach → User)
  2. If not found → DENY (isAuthorized = false)
  3. If Member:
     a. Check Member.isBlocked → DENY if blocked
     b. Find active MemberGymSubscriptions (valid date range OR remaining sessions > 0)
     c. If no active subscription → DENY
     d. Check GymSubscriptionDoor: does subscription cover this door? → DENY if not
     e. Check SubscriptionTimeSlot: is current time within allowed window? → DENY if not
     f. If PER_SESSION: decrement numberOfSessions
  4. If Coach or User: typically always authorized
  5. Create Access record with isAuthorized, accessType (ENTRY/EXIT)
  6. Emit WebSocket events
```

### 7.3 Automations

| Automation | Trigger | Action |
|---|---|---|
| Block Expired Members | CRON / Manual SuperAdmin trigger | Set Member.isBlocked = true when all subscriptions expired |
| Unblock Valid Members | CRON / Manual SuperAdmin trigger | Set Member.isBlocked = false when valid subscription found |
| Attendance Sync | CRON every 10 seconds | Poll devices for new badge events, create Access records |
| Device User Sync | On member/coach/user create/update/delete | Push card/PIN data to ZKTeco/Hikvision devices |
| WebSocket Broadcast | On Access INSERT (PG NOTIFY) | Broadcast attendance:recorded and occupancy:updated events |
| Email OTP | On member registration | Send verification code via AWS SES |
| Session Invitation Email | On session booking | Send confirmation email to member |
| Subscription Expiry Reminders | Daily at 9 AM | Email members 3 days before subscription expires |
| AC Engine Init | Startup + every 5 min | Re-initializes timezone tables on STANDALONE devices after power cycles |
| C3-200 Time Sync | Startup + every hour | Syncs device clock to server time to prevent timestamp drift |
| Sync Check Auto-Remediation | Twice daily (8 AM, 3 PM) | Detects and auto-fixes device/DB desync (auth leaks, lockouts); sends email report |

---

## 8. SECURITY & AUTHENTICATION

### 8.1 Authentication Mechanisms

| Mechanism | Channel | Details |
|---|---|---|
| JWT (Admin) | Web Dashboard | Email + bcrypt password → JWT token (24h expiry) via NextAuth CredentialsProvider |
| JWT (Member) | Mobile App | Email + bcrypt password → JWT token with `type: 'member'` discriminator |
| API Key | Machine Handler | `x-bridge-key` header with timing-safe comparison (BridgeApiKeyGuard) |
| API Key | Python APIs | `x-api-key` header for inter-service communication |
| Local Strategy | Login endpoint | Passport LocalStrategy validates email + bcrypt hash |

### 8.2 Authorization Architecture

- **Guard Chain**: `@UseGuards(JwtAuthGuard, RolesGuard)` on protected routes
- **Role Decorator**: `@Roles(RoleEnum.Admin, RoleEnum.SuperAdmin)` for route-level RBAC
- **Token Discrimination**: Admin tokens have no `type` field; member tokens have `type: 'member'`. Each guard rejects the other's tokens
- **AsyncLocalStorage**: User context stored per-request for audit trail
- **Impersonation**: SuperAdmin can impersonate with preserved audit trail via `impersonatorEmail`

### 8.3 Security Measures

| Measure | Implementation |
|---|---|
| Helmet | HTTP security headers (main.ts) |
| CORS | Configurable origin (FRONTEND_URL or wildcard) |
| Validation Pipe | Global class-validator with auto-transform |
| TypeORM Exception Filter | Sanitized DB error responses |
| bcrypt | Password hashing for all user types |
| Device Locking | Per-device mutex prevents concurrent hardware access |
| Timing-Safe Comparison | API key validation resistant to timing attacks |
| Soft Delete | Member deletion appends ID to cardId (frees card without data loss) |

### 8.4 Potential Risks (Observations)

| Risk | Status | Details |
|---|---|---|
| Shared JWT Secret | OPEN | Admin and member tokens use same `JWT_SECRET`; discrimination relies only on `type` field presence |
| CORS Wildcard Fallback | OPEN | Falls back to `*` if FRONTEND_URL not set |
| No Rate Limiting | OPEN | No visible rate limiting on login endpoints |
| Device Credentials in DB | OPEN | Door IP/port/password stored in database; `password` field not marked `select: false` |
| Bridge API Key in Gym Entity | MITIGATED | `bridgeApiKey` marked `select: false` but stored alongside other gym data |
| Plain-text DB credentials on handler | OPEN (SEC-2) | Machine handler stores DB connection string in .env; needs encryption or proxy |
| ngrok tokens in plain text | OPEN (SEC-3) | Needs DPAPI encryption on Windows |
| Email credentials exposed on handler | OPEN (SEC-4) | Should move to cloud-side email delivery |
| Hardcoded maintenance key | OPEN (SEC-5) | Needs per-gym unique maintenance keys |
| Services run as LocalSystem | OPEN (SEC-6) | Needs dedicated service account with minimal privileges |

**Resolved security issues (2026-Q1):**
- SEC-1: Python API authentication — RESOLVED (x-api-key + CORS hardening)
- SEC-8: Wallet controller had zero authentication — RESOLVED (added JWT + roles guards)
- SEC-9: Cashier over-permissioned — RESOLVED (DELETE restrictions, middleware; motivated by high cashier turnover in Tunisian gym culture)

---

## 9. CAHIER DE CHARGE (Formal Specification)

### 9.1 Project Overview

**Project Name**: TrustGym
**Type**: Multi-tenant SaaS Platform
**Domain**: Gym & Fitness Center Management
**Target Market**: Tunisia (primary), expandable to MENA region
**Architecture**: Modular monolith (API) + SPA (Web) + Mobile App + Edge Hardware Bridge

### 9.2 Functional Requirements

#### FR-01: Member Lifecycle Management
- FR-01.1: Create members with personal info, CIN, contact, RFID card
- FR-01.2: Validate uniqueness of CIN, email, phone, cardId within partner
- FR-01.3: Update member profile with automatic device sync
- FR-01.4: Block/unblock members manually or automatically based on subscription status
- FR-01.5: Delete members with card ID release
- FR-01.6: Paginated member listing with filters (gym, subscription, convention, status)

#### FR-02: Subscription Management
- FR-02.1: Define subscription plan templates (time-based or session-based)
- FR-02.2: Assign subscriptions to members with date ranges
- FR-02.3: Link subscriptions to specific doors
- FR-02.4: Apply convention discounts (flat or percentage)
- FR-02.5: Split payments into installments (Cash, Check, Bank Transfer)
- FR-02.6: Track payment status and due dates
- FR-02.7: Automatically block members on subscription expiry
- FR-02.8: Support time-slot-restricted subscriptions (off-peak pricing)

#### FR-03: Physical Access Control
- FR-03.1: Support 4 device SDKs (C3-200, EFace10, SCR100, Hikvision)
- FR-03.2: Authorize access based on subscription, door, time slot, and block status
- FR-03.3: Log all access events with full metadata
- FR-03.4: Provide real-time occupancy via WebSocket
- FR-03.5: Sync member/coach/user data to on-premises devices
- FR-03.6: Support bidirectional door types (In, Out, InOut)
- FR-03.7: Provide manual access entry for overrides

#### FR-04: Coach & Session Management
- FR-04.1: CRUD for coaches with hourly fee and availability schedule
- FR-04.2: Manage disciplines/training types
- FR-04.3: Calendar-based session scheduling with drag-and-drop
- FR-04.4: Support 3 session types (Open, Close, Reservation)
- FR-04.5: Member session booking with slot limits
- FR-04.6: QR code check-in for sessions
- FR-04.7: Coach payment tracking (hourly rate × duration)

#### FR-05: Boutique & Inventory
- FR-05.1: Product catalog with categories and images
- FR-05.2: Multi-gym stock tracking
- FR-05.3: Stock entry from supplier purchases
- FR-05.4: Inter-gym stock transfers
- FR-05.5: POS sales transactions (Cash, Card, Wallet)
- FR-05.6: Stock movement audit trail
- FR-05.7: Sales and P&L reporting

#### FR-06: Financial Management
- FR-06.1: Invoice generation with Tunisian tax compliance (TVA, timbre, matricule fiscal)
- FR-06.2: PDF invoice generation and S3 storage
- FR-06.3: Digital wallet system (top-up, purchase deduction)
- FR-06.4: Cash register tracking
- FR-06.5: Annual fee collection

#### FR-07: Analytics & KPIs
- FR-07.1: Average visits per member per week
- FR-07.2: Average session duration
- FR-07.3: Silent member detection (configurable inactivity period)
- FR-07.4: Peak hour analysis (hourly and period views)
- FR-07.5: Email re-engagement campaigns for inactive members

#### FR-08: Mobile App (Member-Facing)
- FR-08.1: Multi-step registration with email OTP verification
- FR-08.2: Live gym occupancy display
- FR-08.3: Session browsing and reservation
- FR-08.4: Peak hour analytics
- FR-08.5: Profile management

#### FR-09: Platform Administration
- FR-09.1: Multi-tenant partner management
- FR-09.2: Partner onboarding wizard
- FR-09.3: Platform user management across tenants
- FR-09.4: Device/door management and sync
- FR-09.5: On-premises bundle deployment and updates
- FR-09.6: SaaS subscription tier management

#### FR-10: AI Assistant
- FR-10.1: RAG-based chatbot for documentation queries
- FR-10.2: Document ingestion with vector embeddings (pgvector)

### 9.3 Non-Functional Requirements

| Category | Requirement |
|---|---|
| **Performance** | Access authorization < 200ms; WebSocket event delivery < 1s; Dashboard load < 3s |
| **Scalability** | Multi-tenant isolation supports 100+ partners with independent gyms |
| **Availability** | On-premises handler operates independently during cloud outage (access events queued) |
| **Security** | JWT authentication, bcrypt password hashing, API key authentication for machine-to-machine, Helmet HTTP headers |
| **Internationalization** | French (default), Arabic (RTL), English; locale-based routing |
| **Compatibility** | Web: Modern browsers (Chrome, Firefox, Safari, Edge); Mobile: iOS 14+, Android 10+ |
| **Data Retention** | Full access log history; invoice immutability; stock movement audit trail |
| **Real-Time** | Socket.IO for live occupancy and access notifications; 10s polling for device attendance |
| **Compliance** | Tunisian tax regulations: TVA, timbre fiscal, matricule fiscal |

### 9.4 System Constraints

| Constraint | Details |
|---|---|
| On-premises hardware requirement | ZKTeco/Hikvision devices require Windows host with machine handler |
| Database | PostgreSQL 16 required (pgvector extension for AI features) |
| Cloud dependency | AWS S3 for file storage, AWS SES for email delivery |
| Network | Machine handler requires stable LAN connection to devices; ngrok for remote management |
| SDK variety | 4 different device SDKs with distinct protocols (Pull, Push/ADMS, Standalone, ISAPI) |

### 9.5 Future Scalability Considerations

| Area | Opportunity |
|---|---|
| **Microservices** | Access control, billing, and boutique modules could be extracted into independent services |
| **Message Queue** | Replace PG NOTIFY with RabbitMQ/Kafka for higher throughput event processing |
| **Mobile Expansion** | Add features: workout tracking, nutrition, social features, in-app payments |
| **Payment Gateway** | Integrate Stripe/Flouci for online subscription payments |
| **Biometric Auth** | Fingerprint/face recognition via device SDKs (partial support exists) |
| **Multi-Region** | Expand beyond Tunisia: configurable tax systems, currency, compliance rules |
| **API Gateway** | Add rate limiting, request throttling, and API versioning |
| **Reporting Engine** | Advanced BI dashboards with custom report builder |
| **White-Label** | Partner-branded mobile apps and web dashboards |

---

## 10. INVESTOR-READY DESCRIPTION

### 10.1 Executive Summary

**TrustGym** is a vertically-integrated SaaS platform that digitizes every aspect of gym operations — from the moment a member swipes their badge at the door to the point-of-sale transaction at the protein bar. Unlike horizontal fitness management tools that require 5-6 separate integrations, TrustGym provides a single platform covering membership, billing, physical access control, coaching, retail, and analytics.

### 10.2 Value Proposition

1. **Physical-Digital Bridge**: The only gym management platform in the Tunisian market with native hardware integration for ZKTeco and Hikvision access control devices. No middleware, no third-party connectors — badge swipe to dashboard notification in under 2 seconds.

2. **Real-Time Intelligence**: Live occupancy tracking, peak hour analysis, and silent member detection give gym operators data-driven tools to optimize capacity and reduce churn.

3. **Multi-Tenant by Design**: Built from day one for franchise operations. A single partner can manage multiple gyms, share subscription templates, and view consolidated analytics across locations.

4. **Compliance Built-In**: Tunisian tax requirements (TVA, timbre fiscal, matricule fiscal) are native to the invoicing system, not bolted on.

5. **Member Self-Service**: Mobile app reduces front-desk workload by enabling members to check occupancy, book sessions, and manage their profiles independently.

### 10.3 Market Opportunity

- Tunisia has 500–1,000 gyms and fitness centers with growing digitization demand
- Most operators use paper logs, spreadsheets, or disconnected point solutions
- Physical access control is universally needed but poorly integrated with membership systems
- Franchise model (CrossFit, boutique chains) is growing, requiring multi-site management
- Expansion path: Tunisia → Morocco, Algeria → Saudi Arabia, Egypt (Maghreb + MENA)
- Vertical expansion potential: coworking spaces, pools, wellness centers

### 10.4 Monetization Strategies

| Strategy | Description |
|---|---|
| **SaaS Subscription** | Tiered plans per partner/gym (already implemented: Core, Professional, Business, Enterprise via GymPartnerSubscription) |
| **Per-Gym Pricing** | Monthly fee per gym location, scaling with partner growth |
| **Hardware Margin** | Bundle ZKTeco/Hikvision devices with installation and support |
| **Transaction Fees** | Percentage on digital payment processing (future: Stripe/Flouci integration) |
| **White-Label** | Premium tier for branded mobile apps and custom dashboards |
| **Add-On Modules** | AI assistant, advanced analytics, multi-location reporting as premium features |

### 10.5 Competitive Advantages

| Advantage | Detail |
|---|---|
| **Hardware Integration Moat** | Deep SDK integration with ZKTeco and Hikvision creates switching costs and technical barrier to entry |
| **Full-Stack Ownership** | API, web app, mobile app, and hardware bridge all developed in-house; no dependency on third-party platforms |
| **Real-Time Architecture** | WebSocket-based event system enables instant notifications and live dashboards |
| **Multi-Tenant from Birth** | No retrofitting needed for franchise scaling; tenant isolation built into every query |
| **Local Compliance** | Tunisian tax and fiscal regulations native to the platform |
| **Modern Tech Stack** | NestJS, Next.js 15, React Native/Expo, PostgreSQL, TypeScript — attracts developer talent and enables rapid iteration |

### 10.6 Business Priorities (from BUSINESS_TODO.md)

**P0 — Revenue Critical:**
| Priority | Description | Status | Impact |
|---|---|---|---|
| BIZ-001 | Enforce SaaS subscription gating | Entities exist, enforcement missing | Transforms from free tool to SaaS business |
| BIZ-002 | Launch member mobile app | Backend complete, RN frontend in progress | Drives member retention and gym differentiation |
| BIZ-003 | Online payment integration (Flouci/Konnect) | Not started | Enables self-service subscription payments |

**P1 — Growth Enablers:** Productize onboarding, define pricing strategy, complete finance module, marketing website
**P2 — Competitive Advantages:** Starter free tier, cloud-only option, advanced analytics, retention automation
**P3 — Future Expansion:** Multi-country, API platform, vertical expansion

**Fundraising guidance (from VALUATION_ANALYSIS.md):** Raise $150K–$300K at $600K–$1M pre-money valuation. Stop building features; start charging money.

### 10.7 Technical Differentiators

- **57 database entities** covering the complete gym domain model
- **40+ API modules** with clean separation of concerns
- **5 hardware device families, 118 API endpoints** (ZKTeco C3-200, SC105, SCR100, EFace10 + Hikvision)
- **Real-time event pipeline**: Device → Python SDK → NestJS Bridge → PostgreSQL NOTIFY → WebSocket → Client
- **Dual JWT authentication** with role-based access across web and mobile
- **AI-ready infrastructure** with pgvector embeddings for documentation RAG
- **149,300 lines of code** across 4 repositories
- **Auto-update system**: PowerShell engine + S3 manifest + NestJS endpoints + frontend UI for remote bundle management
- **Auto-remediation**: Twice-daily CRON detects and fixes device/DB desync without human intervention

---

*This document was generated through exhaustive reverse-engineering of the TrustGym codebase across all 4 sub-projects and cross-referenced against 57 files in trustgym-documentation/. All features, entities, and business rules are derived from actual code and documentation analysis, not assumptions.*
