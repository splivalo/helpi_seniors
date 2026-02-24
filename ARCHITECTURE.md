# Helpi Senior — Arhitektura sustava

> Verzija: 0.1.0 | Datum: 2026-02-24

---

## 1. Pregled sustava (High-Level)

```
┌─────────────┐        ┌──────────────┐        ┌──────────────────┐
│  Helpi       │  REST  │   Backend    │  SQL   │    PostgreSQL    │
│  Senior App  │◄─────►│  (Supabase/  │◄─────►│    Database       │
│  (Flutter)   │  +WS   │   Node.js)   │        │                  │
└──────┬──────┘        └──────┬───────┘        └──────────────────┘
       │                      │
       │                      ├──► Stripe API  (plaćanje)
       │                      ├──► Firebase FCM (push notifikacije)
       │                      └──► Cloudinary   (slike profila)
       │
       └──► Google Maps SDK (lokacija/blizina)
```

### Tri aplikacije, jedan backend

| Aplikacija       | Korisnik | Opis                                    |
| ---------------- | -------- | --------------------------------------- |
| **helpi_senior** | Senior   | Pregledava studente, naručuje usluge    |
| helpi_student    | Student  | Upravlja raspoloživošću, prima narudžbe |
| helpi_admin      | Admin    | Moderira, koordinira, rješava sporove   |

---

## 2. Logička shema baze podataka (ERD)

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
│ bio            TEXT       │  ← kratki opis ("Studentica medicine, volim pomagati…")
│ experience     TEXT       │
│ avg_rating     DECIMAL    │  ← denormalizirani prosjek (triggerom ili CRON-om)
│ total_reviews  INT        │
│ verified       BOOL       │  ← admin verificirao osobne dokumente
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

┌───────────────────────────────┐
│   availability_slots           │
├───────────────────────────────┤
│ id              UUID PK       │
│ student_id      UUID FK       │  → student_profiles.id
│ day_of_week     INT           │  ← 1=Pon, 7=Ned  (tjedna recurrence)
│ start_time      TIME          │  ← npr. 09:00
│ end_time        TIME          │  ← npr. 13:00
│ valid_from      DATE          │  ← od kad slot vrijedi
│ valid_until     DATE NULL     │  ← do kad (NULL = neograničeno)
│ is_available    BOOL          │
│ created_at      TIMESTAMP     │
└───────────────────────────────┘

┌──────────────────────────────────┐
│   availability_exceptions         │
├──────────────────────────────────┤
│ id              UUID PK          │
│ student_id      UUID FK          │  → student_profiles.id
│ exception_date  DATE             │  ← konkretan datum nedostupnosti
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
│ status           ENUM             │  ← 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled'
│ notes            TEXT NULL        │  ← senior instrukcije ("ključ pod otirač")
│ address          TEXT             │  ← lokacija usluge
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
│ booking_id       UUID FK NULL     │  → bookings.id (vezan uz narudžbu, ili NULL za opći chat)
│ senior_id        UUID FK          │  → users.id
│ admin_id         UUID FK          │  → users.id (role='admin')
│ student_id       UUID FK NULL     │  → student_profiles.id (opcionalno - admin može uključiti)
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

### ENUM vrijednosti (referenca)

| ENUM                | Vrijednosti                                                             |
| ------------------- | ----------------------------------------------------------------------- |
| `user_role`         | `senior`, `student`, `admin`                                            |
| `service_type`      | `grocery_shopping`, `tech_help`, `cleaning`, `companionship`, `errands` |
| `booking_status`    | `pending`, `confirmed`, `in_progress`, `completed`, `cancelled`         |
| `payment_status`    | `pending`, `succeeded`, `failed`, `refunded`                            |
| `notification_type` | `booking_confirmed`, `payment_received`, `chat_message`, `reminder`     |

---

## 3. Flutter App — Arhitektura slojeva

```
lib/
├── main.dart                    # Entry point, DI setup
├── app/
│   ├── app.dart                 # MaterialApp, tema, rute
│   ├── router.dart              # GoRouter definicija
│   └── theme.dart               # Senior-friendly tema (visoki kontrast)
│
├── core/
│   ├── constants/               # API URL-ovi, ključevi
│   ├── errors/                  # Failure klase
│   ├── network/                 # Dio HTTP klijent, interceptori
│   ├── utils/                   # Helperi, formateri
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

### Ključni paketi (pubspec.yaml plan)

| Paket                         | Svrha                        |
| ----------------------------- | ---------------------------- |
| `flutter_bloc`                | State management (Cubit)     |
| `go_router`                   | Deklarativno rutiranje       |
| `dio`                         | HTTP klijent                 |
| `flutter_stripe`              | Stripe Payment Sheet         |
| `google_maps_flutter`         | Prikaz lokacije              |
| `geolocator`                  | Dohvat korisnikove lokacije  |
| `cached_network_image`        | Profilne slike s cachiranjem |
| `web_socket_channel`          | Real-time chat               |
| `flutter_local_notifications` | Push notifikacije            |
| `get_it` + `injectable`       | Dependency Injection         |
| `json_annotation`             | JSON serijalizacija          |
| `intl`                        | Formatiranje datuma/valuta   |

---

## 4. Senior-Friendly UX Principi

| Princip                    | Implementacija                                                 |
| -------------------------- | -------------------------------------------------------------- |
| **Visoki kontrast**        | Tamni tekst na bijeloj pozadini, akcent boja: #1565C0 (plava)  |
| **Veliki gumbi**           | Min. 56dp visina, border-radius 16, bold labele 18sp+          |
| **Minimalan broj koraka**  | Max 3 koraka do potvrđene narudžbe (odabir → termin → potvrda) |
| **Font**                   | Min. 16sp za body, 24sp za naslove, `fontWeight: w600`         |
| **Ikone + tekst**          | Svaki gumb ima ikonu I tekst, nikad samo ikonu                 |
| **Feedback**               | Haptic feedback na svaki tap, SnackBar potvrde                 |
| **Jednostavna navigacija** | BottomNavigationBar s max 4 taba                               |
| **Error states**           | Jasne poruke na hrvatskom, bez tehničkog žargona               |

### Bottom Navigation (4 taba)

```
[ 🏠 Početna ]  [ 🔍 Studenti ]  [ 💬 Poruke ]  [ 👤 Profil ]
```

---

## 5. User Journey — Od otvaranja do potvrđene narudžbe

```
Korak   Ekran                    Akcija korisnika                      Backend događaj
──────  ───────────────────────  ────────────────────────────────────   ────────────────────────────
  1     Splash Screen            Auto-login check                      GET /auth/me
  2     Login / Registracija     Upis email + lozinka                  POST /auth/login
  3     Početni ekran (Home)     Vidi preporučene studente             GET /students?sort=rating&limit=5
  4     Tab "Studenti"           Otvara marketplace listu              GET /students?page=1
  5     Filter Sheet             Odabir filtera:
        (Bottom Sheet)           - Vrsta usluge (chip select)
                                 - Datum (DatePicker)
                                 - Blizina (slider 1-20km)             GET /students?service=tech_help
                                                                         &date=2026-03-01
                                                                         &lat=45.81&lng=15.98
                                                                         &radius=10
  6     Rezultati                Vidi filtrirane studente
                                 (slika, ime, rating, cijena/h)
  7     Profil studenta          Tap na karticu → detalji:             GET /students/{id}
                                 bio, recenzije, dostupni slotovi      GET /students/{id}/availability
                                                                       GET /students/{id}/reviews
  8     Odabir termina           Tap na slobodan slot u kalendaru      -
  9     Potvrda narudžbe         Pregled: student, usluga, termin,     POST /bookings
                                 cijena, adresa. Tap "Naruči"          → status: 'pending'
 10     Stripe Payment Sheet     Upis kartice / Apple Pay              POST /payments/create-intent
                                                                       → Stripe PaymentIntent
 11     Uspješna naplata         Vidi "Narudžba potvrđena! ✓"          Webhook: payment.succeeded
                                                                       → booking.status = 'confirmed'
                                                                       → push notifikacija studentu
                                                                       → auto-kreiraj chat_room s adminom
 12     Chat s adminom           Može poslati poruku/instrukcije       POST /chat/messages
 13     (Dan usluge)             Push reminder 1h prije                CRON → push notifikacija
 14     Završetak usluge         Student označi "Završeno"             PATCH /bookings/{id}/complete
 15     Ocjenjivanje             Senior ocjenjuje (1-5 ⭐ + komentar)  POST /reviews
```

### Vizualni tok (wireframe koncept)

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MARKETPLACE    │    │  PROFIL STUDENTA │    │  ODABERI TERMIN  │
│                  │    │                  │    │                  │
│ ┌──────────────┐ │    │  [Slika]         │    │  Ožujak 2026     │
│ │ [Foto] Ana M.│ │    │  Ana Marković    │    │  ┌──┬──┬──┬──┐  │
│ │ ⭐ 4.8  15€/h│ │───►│  ⭐ 4.8 (23)     │    │  │Po│Ut│Sr│Če│  │
│ │ Pomoć s      │ │    │                  │───►│  ├──┼──┼──┼──┤  │
│ │ tehnologijom │ │    │  "Studentica     │    │  │  │✓ │  │✓ │  │
│ └──────────────┘ │    │   medicine..."   │    │  └──┴──┴──┴──┘  │
│                  │    │                  │    │                  │
│ ┌──────────────┐ │    │  Dostupnost:     │    │  09:00 - 13:00  │
│ │ [Foto] Ivan K│ │    │  Pon, Sri, Pet   │    │                  │
│ │ ⭐ 4.5  12€/h│ │    │  09:00-13:00     │    │ [NASTAVI ►]     │
│ └──────────────┘ │    │                  │    │                  │
│                  │    │ [ODABERI TERMIN]  │    └─────────────────┘
│ [🔽 FILTRIRAJ]   │    │                  │              │
└─────────────────┘    └─────────────────┘              │
                                                         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   POTVRDA ✓      │    │  STRIPE SHEET    │    │  PREGLED         │
│                  │    │                  │    │  NARUDŽBE        │
│  Narudžba        │    │  Kartica:        │    │                  │
│  potvrđena!      │◄───│  **** 4242       │◄───│  Ana Marković    │
│                  │    │                  │    │  Pomoć s tech.   │
│  Ana M. dolazi   │    │  [PLATI 15€]     │    │  01.03. 09-13h   │
│  01.03. u 09:00  │    │                  │    │  15.00 €         │
│                  │    └─────────────────┘    │                  │
│  [💬 PORUKE]     │                           │  [NARUČI 15€ ►]  │
│  [🏠 POČETNA]    │                           └─────────────────┘
└─────────────────┘
```

---

## 6. Ključni API Endpointi (plan)

| Metoda | Endpoint                      | Opis                         |
| ------ | ----------------------------- | ---------------------------- |
| POST   | `/auth/register`              | Registracija seniora         |
| POST   | `/auth/login`                 | Prijava                      |
| GET    | `/auth/me`                    | Trenutni korisnik            |
| GET    | `/students`                   | Lista studenata (s filtrima) |
| GET    | `/students/{id}`              | Detalji studenta             |
| GET    | `/students/{id}/availability` | Dostupni slotovi             |
| GET    | `/students/{id}/reviews`      | Recenzije za studenta        |
| POST   | `/bookings`                   | Kreiraj narudžbu             |
| PATCH  | `/bookings/{id}/status`       | Promijeni status narudžbe    |
| POST   | `/payments/create-intent`     | Kreiraj Stripe PaymentIntent |
| POST   | `/payments/webhook`           | Stripe webhook handler       |
| GET    | `/chat/rooms`                 | Lista chat soba              |
| GET    | `/chat/rooms/{id}/messages`   | Poruke u sobi                |
| POST   | `/chat/rooms/{id}/messages`   | Pošalji poruku               |
| POST   | `/reviews`                    | Ostavi recenziju             |
| GET    | `/notifications`              | Lista notifikacija           |

---

## 7. Chat & Admin posredovanje

```
Senior  ──────►  Admin  ──────►  Student
                  ▲
                  │
          Chat posrednik
```

**Princip "zlu ne trebalo":**

- Svaki booking automatski kreira `chat_room` s `senior_id` + `admin_id`.
- Admin može opcijski uključiti studenta u sobu (`student_id` se popuni).
- Senior nikad ne komunicira direktno sa studentom bez adminovog pristupa.
- Sve poruke su logirane i vidljive adminu.

---

## 8. Stripe integracija tok

```
1. Senior tap "Naruči"
2. Flutter → POST /payments/create-intent { booking_id, amount }
3. Backend kreira Stripe PaymentIntent, vraća client_secret
4. Flutter prikazuje Stripe Payment Sheet (client_secret)
5. Senior popunjava karticu, potvrdi
6. Stripe procesira naplatu
7. Stripe šalje webhook → POST /payments/webhook
8. Backend: payment.status = 'succeeded', booking.status = 'confirmed'
9. Backend šalje push notifikaciju studentu + senioru
```

---

## 9. Filtriranje studenata — logika

```sql
-- Primjer query-a za filtrirane studente
SELECT u.id, u.first_name, u.last_name, u.avatar_url,
       sp.bio, sp.avg_rating, ss.hourly_rate,
       -- Haversine formula za udaljenost
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
  AND ss.service_type = :service_type          -- filtar: vrsta usluge
  AND ss.is_active = TRUE
  AND avs.day_of_week = EXTRACT(DOW FROM :requested_date::DATE)
  AND avs.start_time <= :requested_start
  AND avs.end_time >= :requested_end
  AND avs.is_available = TRUE
  AND (avs.valid_from <= :requested_date)
  AND (avs.valid_until IS NULL OR avs.valid_until >= :requested_date)
  AND ae.id IS NULL                            -- nema exception za taj datum
HAVING distance_km <= :max_radius_km           -- filtar: lokacija
ORDER BY sp.avg_rating DESC, distance_km ASC;
```
