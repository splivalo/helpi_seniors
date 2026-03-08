# Helpi Senior — System Architecture

> Version: 0.6.0 | Date: 2026-03-08

---

## 1. System Overview (High-Level)

```
┌─────────────┐        ┌──────────────┐        ┌──────────────────┐
│  Helpi       │  REST  │   Backend    │  SQL   │    PostgreSQL    │
│  Senior App  │◄─────►│  (Supabase/  │◄─────►│    Database       │
│  (Flutter)   │  +WS   │   Node.js)   │        │                  │
└──────┬──────┘        └──────┬───────┘        └──────────────────┘
       │                      │
       │                      ├──► Stripe API  (payments)
       │                      ├──► Firebase FCM (push notifications)
       │                      └──► Cloudinary   (profile images)
       │
       └──► Google Maps SDK (location/proximity)
```

### Three apps, one backend

| Application      | User    | Description                                    |
| ---------------- | ------- | ---------------------------------------------- |
| **helpi_senior** | Senior  | Orders services, admin assigns student         |
| helpi_student    | Student | Manages availability, receives assigned orders |
| helpi_admin      | Admin   | Assigns students, moderates, resolves disputes |

---

## 2. Logical Database Schema (ERD)

```
┌──────────────────────┐
│       users           │
├──────────────────────┤
│ id           UUID PK │
│ email        TEXT UQ  │
│ password_hash TEXT    │
│ role         ENUM     │  ← 'senior' | 'student' | 'admin'
│ first_name   TEXT     │
│ last_name    TEXT     │
│ phone        TEXT     │
│ avatar_url   TEXT     │
│ latitude     DECIMAL  │
│ longitude    DECIMAL  │
│ address      TEXT     │
│ is_active    BOOL     │
│ created_at   TIMESTAMP│
│ updated_at   TIMESTAMP│
└──────────┬───────────┘
           │
           │ 1:1
           ▼
┌──────────────────────────┐
│   student_profiles        │
├──────────────────────────┤
│ id             UUID PK   │
│ user_id        UUID FK   │  → users.id
│ bio            TEXT       │  ← short description ("Med student, love helping…")
│ experience     TEXT       │
│ avg_rating     DECIMAL    │  ← denormalized average (via trigger or CRON)
│ total_reviews  INT        │
│ verified       BOOL       │  ← admin verified personal documents
│ stripe_account TEXT       │  ← Stripe Connect account ID
│ created_at     TIMESTAMP  │
│ updated_at     TIMESTAMP  │
└──────────┬───────────────┘
           │
           │ 1:N
           ▼
┌───────────────────────────────┐
│   student_services             │
├───────────────────────────────┤
│ id              UUID PK       │
│ student_id      UUID FK       │  → student_profiles.id
│ service_type    ENUM          │  ← 'shopping' | 'home_help' | 'companionship' | 'walk' | 'escort' | 'other'
│ hourly_rate     DECIMAL(10,2) │
│ description     TEXT          │
│ is_active       BOOL          │
│ created_at      TIMESTAMP     │
└───────────────────────────────┘

NOTE: In v1, all students do everything (no service_type filtering).
The table exists for future use when specialization may be needed.

┌───────────────────────────────┐
│   availability_slots           │
├───────────────────────────────┤
│ id              UUID PK       │
│ student_id      UUID FK       │  → student_profiles.id
│ day_of_week     INT           │  ← 1=Mon, 7=Sun (weekly recurrence)
│ start_time      TIME          │  ← e.g. 09:00
│ end_time        TIME          │  ← e.g. 13:00
│ valid_from      DATE          │  ← from when slot is valid
│ valid_until     DATE NULL     │  ← until when (NULL = indefinite)
│ is_available    BOOL          │
│ created_at      TIMESTAMP     │
└───────────────────────────────┘

┌──────────────────────────────────┐
│   availability_exceptions         │
├──────────────────────────────────┤
│ id              UUID PK          │
│ student_id      UUID FK          │  → student_profiles.id
│ exception_date  DATE             │  ← specific date of unavailability
│ reason          TEXT NULL        │
│ created_at      TIMESTAMP        │
└──────────────────────────────────┘

┌───────────────────────────────────┐
│   bookings                         │
├───────────────────────────────────┤
│ id               UUID PK          │
│ senior_id        UUID FK          │  → users.id (role='senior')
│ student_id       UUID FK          │  → student_profiles.id
│ service_type     ENUM             │
│ scheduled_date   DATE             │
│ scheduled_start  TIME             │
│ scheduled_end    TIME             │
│ status           ENUM             │  ← see ENUM table below
│ notes            TEXT NULL        │  ← senior instructions ("key under doormat")
│ address          TEXT             │  ← service location
│ latitude         DECIMAL          │
│ longitude        DECIMAL          │
│ total_price      DECIMAL(10,2)   │
│ created_at       TIMESTAMP        │
│ updated_at       TIMESTAMP        │
└───────────┬──────────────────────┘
            │
            │ 1:1
            ▼
┌───────────────────────────────────┐
│   payments                         │
├───────────────────────────────────┤
│ id                 UUID PK        │
│ booking_id         UUID FK UQ     │  → bookings.id
│ stripe_payment_id  TEXT           │  ← Stripe PaymentIntent ID
│ amount             DECIMAL(10,2)  │
│ currency           TEXT           │  ← 'EUR'
│ status             ENUM           │  ← 'pending' | 'succeeded' | 'failed' | 'refunded'
│ paid_at            TIMESTAMP NULL │
│ created_at         TIMESTAMP      │
└───────────────────────────────────┘

┌───────────────────────────────────┐
│   reviews                          │
├───────────────────────────────────┤
│ id               UUID PK          │
│ booking_id       UUID FK UQ       │  → bookings.id
│ senior_id        UUID FK          │  → users.id
│ student_id       UUID FK          │  → student_profiles.id
│ rating           INT CHECK(1..5)  │
│ comment          TEXT NULL        │
│ created_at       TIMESTAMP        │
└───────────────────────────────────┘

┌───────────────────────────────────┐
│   chat_rooms                       │
├───────────────────────────────────┤
│ id               UUID PK          │
│ booking_id       UUID FK NULL     │  → bookings.id (tied to order, or NULL for general chat)
│ senior_id        UUID FK          │  → users.id
│ admin_id         UUID FK          │  → users.id (role='admin')
│ student_id       UUID FK NULL     │  → student_profiles.id (optional - admin can include)
│ created_at       TIMESTAMP        │
└───────────┬──────────────────────┘
            │
            │ 1:N
            ▼
┌───────────────────────────────────┐
│   chat_messages                    │
├───────────────────────────────────┤
│ id               UUID PK          │
│ chat_room_id     UUID FK          │  → chat_rooms.id
│ sender_id        UUID FK          │  → users.id
│ message          TEXT             │
│ is_read          BOOL             │
│ created_at       TIMESTAMP        │
└───────────────────────────────────┘

┌───────────────────────────────────┐
│   notifications                    │
├───────────────────────────────────┤
│ id               UUID PK          │
│ user_id          UUID FK          │  → users.id
│ title            TEXT             │
│ body             TEXT             │
│ type             ENUM             │  ← 'booking_confirmed' | 'payment_received' | 'chat_message' | 'reminder'
│ is_read          BOOL             │
│ data_json        JSONB            │  ← deep-link metadata
│ created_at       TIMESTAMP        │
└───────────────────────────────────┘
```

### ENUM Values (reference)

| ENUM                   | Values                                                                                                         |
| ---------------------- | -------------------------------------------------------------------------------------------------------------- |
| `user_role`            | `senior`, `student`, `admin`                                                                                   |
| `service_type`         | `shopping`, `house_help`, `companionship`, `walking`, `escort`, `other`                                        |
| `booking_status`       | `pending`, `confirmed`, `in_progress`, `completed`, `cancelled`, `cancelled_by_student`, `skipped`, `replaced` |
| `job_status` (Flutter) | `completed`, `scheduled`, `cancelled` — per-session status in Flutter UI                                       |
| `payment_status`       | `pending`, `succeeded`, `failed`, `refunded`                                                                   |
| `notification_type`    | `booking_confirmed`, `payment_received`, `chat_message`, `reminder`                                            |

---

## 3. Flutter App — Layer Architecture

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── app.dart                 # MaterialApp, theme, routes
│   ├── main_shell.dart          # BottomNavigationBar shell (4 tabs)
│   └── theme.dart               # Senior-friendly theme (pastel overhaul)
│
├── core/
│   ├── constants/               # API URLs, keys
│   ├── errors/                  # Failure classes
│   ├── network/                 # Dio HTTP client, interceptors
│   ├── utils/                   # Helpers, formatters
│   └── l10n/
│       └── app_strings.dart     # Gemini Hybrid i18n (HR/EN, 200+ keys)
│
├── features/
│   ├── auth/
│   │   ├── data/                # AuthRemoteDataSource, AuthRepository impl
│   │   ├── domain/              # User entity, AuthRepository interface
│   │   └── presentation/
│   │       └── login_screen.dart    # Login/Register with social auth (SVG circles)
│   │
│   ├── order/                   # ★ Core feature — simplified order flow
│   │   └── presentation/
│   │       ├── order_screen.dart       # Landing ("Nova narudžba" CTA)
│   │       └── order_flow_screen.dart  # 3-step flow (Kada → Što → Pregled) ~1454 lines
│   │
│   ├── booking/
│   │   ├── data/
│   │   │   └── order_model.dart        # Order/Job/Review models + OrdersNotifier + mock data
│   │   └── presentation/
│   │       ├── orders_screen.dart      # "Moje narudžbe" (4 tabs: processing/active/completed/cancelled)
│   │       └── order_detail_screen.dart # Order detail + pricing + jobs section + per-job reviews
│   │
│   ├── payment/
│   │   ├── data/                # StripeService, PaymentRepository impl
│   │   ├── domain/              # Payment entity
│   │   └── presentation/        # PaymentSheet, PaymentCubit
│   │
│   ├── chat/
│   │   ├── data/                # ChatRemoteDataSource (WebSocket)
│   │   ├── domain/              # ChatRoom, Message entities
│   │   └── presentation/
│   │       ├── chat_list_screen.dart   # Chat list (teal/mint bubbles)
│   │       └── chat_room_screen.dart   # Chat room with messages
│   │
│   ├── reviews/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/        # ReviewForm, StarRating widget
│   │
│   └── profile/
│       └── presentation/
│           └── profile_screen.dart     # Senior profile, settings, logout
│
├── shared/
│   └── widgets/                 # BigButton, SeniorCard, LoadingOverlay
│
└── di/
    └── injection.dart           # GetIt / injectable setup
```

**Note:** Marketplace feature was removed (archived to branch `archive/marketplace-v1`).
Dead code (home_screen, marketplace_screen, student_detail_screen, student_card, booking_flow_screen) has been deleted.

### Key Packages (pubspec.yaml plan)

| Package                       | Purpose                     |
| ----------------------------- | --------------------------- |
| `flutter_bloc`                | State management (Cubit)    |
| `go_router`                   | Declarative routing         |
| `dio`                         | HTTP client                 |
| `flutter_stripe`              | Stripe Payment Sheet        |
| `google_maps_flutter`         | Location display            |
| `geolocator`                  | User location fetch         |
| `cached_network_image`        | Profile images with caching |
| `web_socket_channel`          | Real-time chat              |
| `flutter_local_notifications` | Push notifications          |
| `get_it` + `injectable`       | Dependency Injection        |
| `json_annotation`             | JSON serialization          |
| `intl`                        | Date/currency formatting    |

---

## 4. Senior-Friendly UX Principles

| Principle             | Implementation                                                                               |
| --------------------- | -------------------------------------------------------------------------------------------- |
| **Background**        | Warm off-white #F9F7F4                                                                       |
| **Colors**            | Primary/CTA: #EF5B5B (coral), Secondary/Interactive: #009D9D (teal)                          |
| **Color split**       | Coral = progress/action (steps, tabs, CTA). Teal = interactive/form (switch, chips, buttons) |
| **Chips selected**    | Pastel teal fill (#E0F5F5) + teal border + teal text                                         |
| **Chips unselected**  | White fill + grey border (#E0E0E0)                                                           |
| **Large buttons**     | Min. 56dp height, border-radius 16, bold labels 18sp+                                        |
| **borderRadius**      | Unified 16 everywhere                                                                        |
| **Cards**             | White background + grey border (#E0E0E0), no shadows                                         |
| **Minimal steps**     | Max 3 steps to confirmed order (Kada → Što → Pregled)                                        |
| **Font**              | Min. 16sp body, 24sp headings, `fontWeight: w600`                                            |
| **Icons + text**      | Every button has icon AND text, never icon alone                                             |
| **Feedback**          | Haptic feedback on every tap, SnackBar confirmations                                         |
| **Simple navigation** | BottomNavigationBar with 4 tabs                                                              |
| **Error states**      | Clear messages in Croatian (user language), no technical jargon                              |
| **No shadows**        | Chips, cards, date buttons — all flat, no boxShadow                                          |

### Bottom Navigation (4 tabs)

```
[ ➕ Naruči ]  [ 📋 Narudžbe ]  [ 💬 Poruke ]  [ 👤 Profil ]
```

### Order Flow (3 steps)

| Step | Screen     | Content                                                     |
| ---- | ---------- | ----------------------------------------------------------- |
| 1    | Kada?      | Booking mode (one-time/recurring), dates, day/time/duration |
| 2    | Što treba? | Service chips, free-text note, escort info                  |
| 3    | Pregled    | Full order summary, submit button                           |

### Booking Modes

| Mode          | Description                    | Behavior                          |
| ------------- | ------------------------------ | --------------------------------- |
| **One-time**  | Single session, single day     | Pick date + time + duration       |
| **Recurring** | Repeats weekly                 | Pick start date, add day entries  |
| + End date    | Optional: recurring until date | Switch toggle, DatePicker for end |

#### Day range validation

When recurring mode has an end date, the day picker only shows weekdays that
actually fall within the start–end range. If dates change and an existing day
entry no longer fits, it is automatically removed.

#### Chip-based selection

```
[Jednokratno] [Ponavljajuće]                   ← Mode (tab bar style, coral active)
[Pon] [Uto] [Sri] [Čet] [Pet] [Sub] [Ned]     ← Days (filtered by date range)
[08:00] [09:00] ... [19:00]                    ← Start hour (per-day)
[:00] [:15] [:30] [:45]                        ← Start minute (per-day, appears after hour)
[1 sat] [2 sata] [3 sata] [4 sata]            ← Duration (per-day, appears after minute)
```

- Chips: pastel teal (#E0F5F5) when selected, white when not
- Duration has no default — requires explicit click
- CTA only enabled when all required fields are filled
- **Progressive disclosure:** Each row only appears after the previous is selected
  - Date → Hour → Minute → Duration
- **One-time card:** Wrapped in white card container matching recurring day cards
  - Header: weekday name + X to cancel
  - Subtitle: formatted date

### Recurring Cancellation Flow (planned)

When student cancels a session (illness, exams...):

```
1. Student marks unavailability in their app
2. Backend sends push notification to senior
3. Senior sees options:
   [Skip this session]    — session is skipped, no charge
   [Find replacement]     — backend filters available students (same day/time/city)
   [Cancel everything]    — entire recurring booking cancelled
4. If "Find replacement" → mini-list of students, senior picks with one click
5. One-time booking with replacement, recurring with original stays unchanged
```

**v1:** Only "Skip" and "Cancel everything". Replacement in v1.5+.

### Travel Buffer Between Sessions

Students need time to travel between seniors. Backend enforces a **fixed 30-minute buffer** after each booking's `scheduled_end`. Example:

```
Student slot: 16:00–20:00
Senior A: 16:00–18:00  →  effectively occupied until 18:30
Senior B: earliest 18:30  →  can book 18:30–19:30 (1h) or 19:00–20:00 (1h)
```

**v1:** Fixed 30 min buffer (backend logic, invisible to senior).
**v1.5+:** Configurable per student (`student_profiles.travel_buffer_min INT DEFAULT 30`).

---

## 5. User Journey — From App Open to Confirmed Order

```
Step    Screen                   User Action                           Backend Event
──────  ───────────────────────  ────────────────────────────────────  ────────────────────────────
  1     Splash Screen            Auto-login check                      GET /auth/me
  2     Login / Register         Enter email + password                POST /auth/login
  3     "Naruči" Tab             See landing page with CTA             —
  4     Order Flow Step 1        Pick booking mode (one-time/recurring)—
                                 Pick date(s), days, time, duration
  5     Order Flow Step 2        Select services (chips)               —
                                 Optional: add note
  6     Order Flow Step 3        Review full order summary             —
                                 Tap "Naruči"                         POST /orders
  7     Order Confirmation       See "Narudžba zaprimljena! ✓"        → status: 'pending'
                                                                       → admin notified
  8     Admin Assignment         (Admin assigns student)               PATCH /orders/{id}/assign
                                                                       → push notification to senior
  9     Chat with Admin          Senior can message admin              POST /chat/messages
 10     (Service Day)            Push reminder 1h before               CRON → push notification
 11     Service Complete         Student marks "Done"                  PATCH /bookings/{id}/complete
 12     Review                   Senior rates (1-5 ⭐ + comment)       POST /reviews
```

**Key difference from v1:** Senior does NOT browse or select students.
Senior places an order → Admin assigns the best available student.

### Visual Flow (wireframe concept)

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   NARUČI (TAB)   │    │  STEP 1: KADA?   │    │ STEP 2: ŠTO?    │
│                  │    │                  │    │                  │
│     [➕ icon]     │    │  [Jednokr|Ponavl]│    │ [Kupovina]       │
│                  │    │                  │    │ [Pomoć u kući]   │
│  "Trebate li     │    │  📅 26.02.2026   │    │ [Društvo]        │
│   pomoć?"        │───►│                  │───►│ [Šetnja]         │
│                  │    │  [Pon] [Sri]     │    │ [Pratnja]        │
│  [NOVA NARUDŽBA] │    │  08:00 / 2 sata  │    │ [Ostalo]         │
│                  │    │                  │    │  📝 Napomena...   │
│                  │    │  [DALJE ►]       │    │  [DALJE ►]       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                              │
         │                                              ▼
┌─────────────────┐                           ┌─────────────────┐
│   POTVRDA ✓      │                           │  STEP 3: PREGLED │
│                  │                           │                  │
│  Narudžba        │                           │  Datum: 26.02.   │
│  zaprimljena!    │◄──────────────────────────│  Vrijeme: 08:00  │
│                  │                           │  Trajanje: 2h    │
│  Admin će vam    │                           │  Usluge: ...     │
│  javiti kad      │                           │                  │
│  nađe studenta.  │                           │  [NARUČI ►]      │
│                  │                           │                  │
│  [💬 PORUKE]     │                           └─────────────────┘
│  [🏠 POČETNA]    │
└─────────────────┘
```

---

## 6. Key API Endpoints (plan)

| Method | Endpoint                    | Description                   |
| ------ | --------------------------- | ----------------------------- |
| POST   | `/auth/register`            | Register senior               |
| POST   | `/auth/login`               | Login                         |
| GET    | `/auth/me`                  | Current user                  |
| POST   | `/orders`                   | Create order (senior submits) |
| GET    | `/orders`                   | List senior's orders          |
| GET    | `/orders/{id}`              | Order details                 |
| PATCH  | `/orders/{id}/assign`       | Admin assigns student         |
| PATCH  | `/orders/{id}/status`       | Change order status           |
| POST   | `/payments/create-intent`   | Create Stripe PaymentIntent   |
| POST   | `/payments/webhook`         | Stripe webhook handler        |
| GET    | `/chat/rooms`               | List chat rooms               |
| GET    | `/chat/rooms/{id}/messages` | Messages in room              |
| POST   | `/chat/rooms/{id}/messages` | Send message                  |
| POST   | `/reviews`                  | Leave review                  |
| GET    | `/notifications`            | List notifications            |

**Removed:** `/students`, `/students/{id}`, `/students/{id}/availability`, `/students/{id}/reviews` — senior no longer browses students.

---

## 7. Chat & Admin Mediation

```
Senior  ──────►  Admin  ──────►  Student
                  ▲
                  │
          Chat mediator
```

**Safety-first principle:**

- Every booking automatically creates a `chat_room` with `senior_id` + `admin_id`.
- Admin can optionally include the student in the room (`student_id` is filled).
- Senior never communicates directly with student without admin access.
- All messages are logged and visible to admin.

---

## 8. Stripe Integration Flow

```
1. Senior taps "Order"
2. Flutter → POST /payments/create-intent { booking_id, amount }
3. Backend creates Stripe PaymentIntent, returns client_secret
4. Flutter displays Stripe Payment Sheet (client_secret)
5. Senior fills in card, confirms
6. Stripe processes payment
7. Stripe sends webhook → POST /payments/webhook
8. Backend: payment.status = 'succeeded', booking.status = 'confirmed'
9. Backend sends push notification to student + senior
```

---

## 9. Student Assignment — Admin Logic (backend)

Senior does NOT select a student. Admin receives the order and assigns a student based on:

- Availability (day/time match)
- Location proximity
- Student workload balance
- Past ratings

This logic runs on the admin dashboard / backend, not in the senior app.

```
Senior places order → Backend creates order (status: 'pending')
                    → Admin gets notification
                    → Admin reviews available students
                    → Admin assigns student (PATCH /orders/{id}/assign)
                    → Senior gets push notification with student info
                    → Chat room created (senior + admin + student)
```
