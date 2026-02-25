# Helpi Senior — System Architecture

> Version: 0.2.0 | Date: 2026-02-25

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

| Application      | User    | Description                               |
| ---------------- | ------- | ----------------------------------------- |
| **helpi_senior** | Senior  | Browses students, orders services         |
| helpi_student    | Student | Manages availability, receives orders     |
| helpi_admin      | Admin   | Moderates, coordinates, resolves disputes |

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
│ service_type    ENUM          │  ← 'grocery_shopping' | 'tech_help' | 'cleaning' | 'companionship' | 'errands'
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

| ENUM                | Values                                                                                                         |
| ------------------- | -------------------------------------------------------------------------------------------------------------- |
| `user_role`         | `senior`, `student`, `admin`                                                                                   |
| `service_type`      | `grocery_shopping`, `tech_help`, `cleaning`, `companionship`, `errands`                                        |
| `booking_status`    | `pending`, `confirmed`, `in_progress`, `completed`, `cancelled`, `cancelled_by_student`, `skipped`, `replaced` |
| `payment_status`    | `pending`, `succeeded`, `failed`, `refunded`                                                                   |
| `notification_type` | `booking_confirmed`, `payment_received`, `chat_message`, `reminder`                                            |

---

## 3. Flutter App — Layer Architecture

```
lib/
├── main.dart                    # Entry point, DI setup
├── app/
│   ├── app.dart                 # MaterialApp, theme, routes
│   ├── router.dart              # GoRouter definition
│   └── theme.dart               # Senior-friendly theme (high contrast)
│
├── core/
│   ├── constants/               # API URLs, keys
│   ├── errors/                  # Failure classes
│   ├── network/                 # Dio HTTP client, interceptors
│   ├── utils/                   # Helpers, formatters
│   └── l10n/
│       └── app_strings.dart     # Gemini Hybrid i18n (HR/EN)
│
├── features/
│   ├── auth/
│   │   ├── data/                # AuthRemoteDataSource, AuthRepository impl
│   │   ├── domain/              # User entity, AuthRepository interface
│   │   └── presentation/        # LoginScreen, RegisterScreen, AuthCubit
│   │
│   ├── marketplace/
│   │   ├── data/                # StudentRemoteDataSource, repo impl
│   │   ├── domain/              # Student entity, filters VO
│   │   └── presentation/        # StudentListScreen, StudentCard, FilterSheet, MarketplaceCubit
│   │
│   ├── booking/
│   │   ├── data/                # BookingRemoteDataSource, repo impl
│   │   ├── domain/              # Booking entity, repo interface
│   │   └── presentation/        # BookingFlowScreen, SlotPicker, ConfirmationScreen, BookingCubit
│   │
│   ├── payment/
│   │   ├── data/                # StripeService, PaymentRepository impl
│   │   ├── domain/              # Payment entity
│   │   └── presentation/        # PaymentSheet, PaymentCubit
│   │
│   ├── chat/
│   │   ├── data/                # ChatRemoteDataSource (WebSocket)
│   │   ├── domain/              # ChatRoom, Message entities
│   │   └── presentation/        # ChatScreen, ChatBubble, ChatCubit
│   │
│   ├── reviews/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/        # ReviewForm, StarRating widget
│   │
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/        # ProfileScreen, EditProfileScreen
│
├── shared/
│   └── widgets/                 # BigButton, SeniorCard, RatingStars, LoadingOverlay
│
└── di/
    └── injection.dart           # GetIt / injectable setup
```

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

| Principle             | Implementation                                                      |
| --------------------- | ------------------------------------------------------------------- |
| **High contrast**     | Dark text on white background                                       |
| **Colors**            | Primary: #EF5B5B (coral), Secondary/Accent: #009D9D (teal)          |
| **Chips**             | Selected = teal #009D9D, unselected = white with grey border        |
| **Large buttons**     | Min. 56dp height, border-radius 12, bold labels 18sp+               |
| **borderRadius**      | Unified 12 everywhere. Exceptions: chat input (24), accent bars (2) |
| **Minimal steps**     | Max 3 steps to confirmed order (select → time → confirm)            |
| **Font**              | Min. 16sp body, 24sp headings, `fontWeight: w600`                   |
| **Icons + text**      | Every button has icon AND text, never icon alone                    |
| **Feedback**          | Haptic feedback on every tap, SnackBar confirmations                |
| **Simple navigation** | BottomNavigationBar with max 4 tabs                                 |
| **Error states**      | Clear messages in Croatian (user language), no technical jargon     |
| **Calendar**          | Read-only (info only), colors: teal=free, amber=partial, red=booked |

### Bottom Navigation (4 tabs)

```
[ 🏠 Home ]  [ 🔍 Students ]  [ 💬 Messages ]  [ 👤 Profile ]
```

### Booking Modes

| Mode           | Description                         | Behavior                              |
| -------------- | ----------------------------------- | ------------------------------------- |
| **One-time**   | Single session, single day          | Standard reservation                  |
| **Continuous** | Repeats weekly, auto-renews monthly | Runs until end of month, auto-extends |
| **Until date** | Repeats weekly until fixed date     | DatePicker for end date, stops auto   |

#### Chip-based selection (booking sheet)

```
[One-time] [Continuous] [Until date]          ← Mode
[Mon] [Wed] [Thu] [Fri]                        ← Days (multi-select)
[16:00] [17:00] [18:00] [19:00]               ← Start time (per-day)
[1 hr] [2 hrs] [3 hrs] [4 hrs]               ← Duration (per-day)
```

- Chips: teal when selected, white when not
- Duration has no default — requires explicit click
- Summary + CTA only visible when both start AND duration are selected

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
  3     Home Screen              See recommended students              GET /students?sort=rating&limit=5
  4     "Students" Tab           Open marketplace list                 GET /students?page=1
  5     Filter Sheet             Select filters:
        (Bottom Sheet)           - Date (DatePicker)
                                 - Proximity (slider 1-20km)           GET /students?date=2026-03-01
                                                                         &lat=45.81&lng=15.98
                                                                         &radius=10
  6     Results                  See filtered students
                                 (photo, name, rating, price/h)
  7     Student Profile          Tap card → details:                   GET /students/{id}
                                 bio, reviews, available slots         GET /students/{id}/availability
                                                                       GET /students/{id}/reviews
  8     Select Time              Tap "Book now" → booking sheet        -
  9     Order Confirmation       Review: student, service, time,       POST /bookings
                                 price, address. Tap "Order"           → status: 'pending'
 10     Stripe Payment Sheet     Enter card / Apple Pay                POST /payments/create-intent
                                                                       → Stripe PaymentIntent
 11     Payment Success          See "Order confirmed! ✓"              Webhook: payment.succeeded
                                                                       → booking.status = 'confirmed'
                                                                       → push notification to student
                                                                       → auto-create chat_room with admin
 12     Chat with Admin          Can send messages/instructions        POST /chat/messages
 13     (Service Day)            Push reminder 1h before               CRON → push notification
 14     Service Complete         Student marks "Done"                  PATCH /bookings/{id}/complete
 15     Review                   Senior rates (1-5 ⭐ + comment)       POST /reviews
```

### Visual Flow (wireframe concept)

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MARKETPLACE    │    │ STUDENT PROFILE  │    │  SELECT TIME     │
│                  │    │                  │    │                  │
│ ┌──────────────┐ │    │  [Photo]         │    │  March 2026      │
│ │ [Pic] Ana M. │ │    │  Ana Markovic    │    │  ┌──┬──┬──┬──┐  │
│ │ ⭐ 4.8  15€/h│ │───►│  ⭐ 4.8 (23)     │    │  │Mo│Tu│We│Th│  │
│ │ Tech help    │ │    │                  │───►│  ├──┼──┼──┼──┤  │
│ │              │ │    │  "Med student    │    │  │  │✓ │  │✓ │  │
│ └──────────────┘ │    │   love helping…" │    │  └──┴──┴──┴──┘  │
│                  │    │                  │    │                  │
│ ┌──────────────┐ │    │  Availability:   │    │  09:00 - 13:00  │
│ │ [Pic] Ivan K.│ │    │  Mon, Wed, Fri   │    │                  │
│ │ ⭐ 4.5  12€/h│ │    │  09:00-13:00     │    │ [CONTINUE ►]    │
│ └──────────────┘ │    │                  │    │                  │
│                  │    │ [SELECT TIME]    │    └─────────────────┘
│ [🔽 FILTER]      │    │                  │              │
└─────────────────┘    └─────────────────┘              │
                                                         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CONFIRMED ✓    │    │  STRIPE SHEET    │    │  ORDER REVIEW    │
│                  │    │                  │    │                  │
│  Order           │    │  Card:           │    │                  │
│  confirmed!      │◄───│  **** 4242       │◄───│  Ana Markovic    │
│                  │    │                  │    │  Tech help       │
│  Ana M. arrives  │    │  [PAY €15]       │    │  01.03. 09-13h   │
│  01.03. at 09:00 │    │                  │    │  €15.00          │
│                  │    └─────────────────┘    │                  │
│  [💬 MESSAGES]   │                           │  [ORDER €15 ►]   │
│  [🏠 HOME]       │                           └─────────────────┘
└─────────────────┘
```

---

## 6. Key API Endpoints (plan)

| Method | Endpoint                      | Description                 |
| ------ | ----------------------------- | --------------------------- |
| POST   | `/auth/register`              | Register senior             |
| POST   | `/auth/login`                 | Login                       |
| GET    | `/auth/me`                    | Current user                |
| GET    | `/students`                   | Student list (with filters) |
| GET    | `/students/{id}`              | Student details             |
| GET    | `/students/{id}/availability` | Available slots             |
| GET    | `/students/{id}/reviews`      | Reviews for student         |
| POST   | `/bookings`                   | Create booking              |
| PATCH  | `/bookings/{id}/status`       | Change booking status       |
| POST   | `/payments/create-intent`     | Create Stripe PaymentIntent |
| POST   | `/payments/webhook`           | Stripe webhook handler      |
| GET    | `/chat/rooms`                 | List chat rooms             |
| GET    | `/chat/rooms/{id}/messages`   | Messages in room            |
| POST   | `/chat/rooms/{id}/messages`   | Send message                |
| POST   | `/reviews`                    | Leave review                |
| GET    | `/notifications`              | List notifications          |

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

## 9. Student Filtering — Logic

```sql
-- Example query for filtered students
SELECT u.id, u.first_name, u.last_name, u.avatar_url,
       sp.bio, sp.avg_rating, ss.hourly_rate,
       -- Haversine formula for distance
       (6371 * acos(cos(radians(:lat)) * cos(radians(u.latitude))
        * cos(radians(u.longitude) - radians(:lng))
        + sin(radians(:lat)) * sin(radians(u.latitude)))) AS distance_km
FROM users u
JOIN student_profiles sp ON sp.user_id = u.id
JOIN student_services ss ON ss.student_id = sp.id
JOIN availability_slots avs ON avs.student_id = sp.id
LEFT JOIN availability_exceptions ae
  ON ae.student_id = sp.id AND ae.exception_date = :requested_date
WHERE u.role = 'student'
  AND u.is_active = TRUE
  AND sp.verified = TRUE
  AND ss.is_active = TRUE
  AND avs.day_of_week = EXTRACT(DOW FROM :requested_date::DATE)
  AND avs.start_time <= :requested_start
  AND avs.end_time >= :requested_end
  AND avs.is_available = TRUE
  AND (avs.valid_from <= :requested_date)
  AND (avs.valid_until IS NULL OR avs.valid_until >= :requested_date)
  AND ae.id IS NULL                            -- no exception for that date
HAVING distance_km <= :max_radius_km           -- filter: location
ORDER BY sp.avg_rating DESC, distance_km ASC;
```

Note: `service_type` filter removed from v1 query since all students do everything.
