# Helpi Senior - Roadmap

> WARNING: It is STRICTLY FORBIDDEN to start any task from the Roadmap without explicit user confirmation.
> Every step requires explicit approval from the product owner.

> Last updated: 2026-03-02

---

## Phase 1 - Foundation (infrastructure)

- [x] 1.1 Reorganize `lib/` folder structure (feature-first Clean Arch)
- [ ] 1.2 Add packages to `pubspec.yaml` (bloc, go_router, dio, etc.)
- [x] 1.3 `AppStrings` i18n (Gemini Hybrid pattern, HR + EN, 200+ keys)
- [x] 1.4 Senior-friendly theme (pastel overhaul, borderRadius 16, coral/teal split)
- [x] 1.4b `flutter_localizations` SDK package (HR locale)
- [ ] 1.5 GoRouter setup with placeholder screens
- [ ] 1.6 DI setup (GetIt + injectable)
- [ ] 1.7 Dio HTTP client with interceptors

## Phase 2 - Auth

- [x] 2.1 Login screen (email + password, senior-friendly, social SVG circles)
- [x] 2.2 Registration screen (toggle on same screen)
- [ ] 2.3 Auth Cubit + repository
- [ ] 2.4 Token storage (flutter_secure_storage)
- [ ] 2.5 Auto-login on splash

## Phase 3 - Order Flow

- [x] 3.1 OrderScreen — landing page with "Nova narudžba" CTA
- [x] 3.2 OrderFlowScreen — 3-step flow (Kada → Što → Pregled)
- [x] 3.3 Booking modes (one-time + recurring with optional end date)
- [x] 3.4 Per-day configuration (time + duration per day entry)
- [x] 3.5 Day range validation (filter picker + auto-cleanup + safety net)
- [x] 3.5b Progressive disclosure (Date → Hour → Minute → Duration)
- [x] 3.5c 15-minute time precision (hour + minute chips)
- [x] 3.5d One-time card redesign (matching recurring day card style)
- [x] 3.5e "+Dodaj dan" progressive disclosure (visible only after all fields filled)
- [x] 3.5f Auto-scroll on duration selection (reveals "+Dodaj dan" button)
- [ ] 3.6 Order confirmation screen (success after submit)
- [ ] 3.7 Order Cubit + repository
- [ ] 3.8 Backend integration (POST /orders)

## Phase 4 - Orders Management

- [x] 4.1 "Moje narudžbe" screen (order list with 3 tabs: processing/active/completed)
- [x] 4.2 Order detail screen (tap-to-detail, expand/collapse)
- [x] 4.3 Pricing display (14€/h weekday, 16€/h Sunday, weekly total)
- [x] 4.4 JobModel + JobStatus (completed, upcoming, cancelled)
- [x] 4.5 "Termini" section: collapsible job list with per-job cards
- [x] 4.6 Per-job actions: cancel upcoming, rate completed (stars + comment)
- [x] 4.7 Inline review display on job cards
- [x] 4.8 Removed order-level Students section (reviews now at job level)
- [x] 4.9 Color system overhaul: green (#4CAF50) for active/completed, blue (#1976D2) for processing/upcoming
- [x] 4.10 Ocijeni button: teal outlined (borderRadius 8) + Otkaži: coral outlined (borderRadius 8)
- [x] 4.11 One-time review inside summary card (grey title + student name + small Ocijeni button)
- [x] 4.12 Termini section hidden for processing and one-time orders
- [x] 4.13 "Ponovi narudžbu" with DatePicker/DateRangePicker → processing status
- [x] 4.14 addProcessingOrder() (no student/job assignment)
- [x] 4.15 Tab auto-switch to "U obradi" after repeat
- [x] 4.16 3 mock completed orders seeded (one-time, recurring, recurring-with-end)
- [x] 4.17 Frequency labels: "Ponavljajuće", "Do DD.MM.YYYY", "Jednom"
- [x] 4.18 Service chips pill shape (borderRadius 24) in Pregled step
- [ ] 4.19 Order status updates (push notifications)
- [ ] 4.20 Orders Cubit + repository

## Phase 5 - Payment

- [ ] 5.1 Stripe Payment Sheet integration
- [ ] 5.2 Payment Cubit + Stripe service
- [ ] 5.3 Payment confirmation flow

## Phase 6 - Chat

- [ ] 6.1 Chat list screen (UI done, needs backend)
- [ ] 6.2 Chat room screen (UI done, needs backend)
- [ ] 6.3 WebSocket integration
- [ ] 6.4 Chat Cubit + repository
- [ ] 6.5 Admin-mediated chat model

## Phase 7 - Reviews & Profile

- [ ] 7.1 Review form (stars + comment)
- [ ] 7.2 Senior profile screen (UI done, needs backend)
- [ ] 7.3 Edit profile
- [ ] 7.4 Notifications screen

## Phase 8 - Recurring Booking Management

- [ ] 8.1 Push notification when student cancels a session
- [ ] 8.2 Senior options: Skip session / Cancel all
- [ ] 8.3 "Moje narudžbe" with recurring view (session list + per-date statuses)
- [ ] 8.4 Backend: `booking_status` extension (`skipped`, `cancelled_by_student`)
- [ ] 8.5 Travel buffer: fixed 30 min between sessions (backend logic)

## Phase 8.5 - Replacement Student (v1.5+)

- [ ] 8.5.1 Backend endpoint: `GET /students/available?date=X&start=Y&duration=Z&city=W`
- [ ] 8.5.2 Mini-list of replacement students (filtered by day/time/city)
- [ ] 8.5.3 Senior picks replacement with one click → one-time booking
- [ ] 8.5.4 Original recurring stays unchanged, only that date gets status `replaced`
- [ ] 8.5.5 UI in "Moje narudžbe": swap icon for replaced sessions

## Phase 8.6 - Configurable Travel Buffer (v1.5+)

- [ ] 8.6.1 Student app: setting "Time between sessions" (15/30/45/60 min, default 30)
- [ ] 8.6.2 Backend uses per-student buffer instead of fixed 30 min
- [ ] 8.6.3 DB: `student_profiles.travel_buffer_min INT DEFAULT 30`

## Phase 9 - Polish & Launch

- [ ] 9.1 Push notifications (Firebase FCM)
- [ ] 9.2 Error handling & offline mode
- [ ] 9.3 Performance optimization
- [ ] 9.4 Accessibility audit
- [ ] 9.5 Beta testing
- [ ] 9.6 Play Store / App Store deployment

## Phase 10 - Admin App

- [ ] 10.1 Flutter project setup (helpi_admin)
- [ ] 10.2 Responsive layout (desktop sidebar + mobile bottom nav)
- [ ] 10.3 Admin login screen
- [ ] 10.4 Dashboard — sve narudžbe s filterima (processing/active/completed)
- [ ] 10.5 Order detail — dodjela studenta narudžbi
- [ ] 10.6 Student management — lista studenata, dostupnost, ocjene
- [ ] 10.7 Senior management — lista seniora, narudžbe
- [ ] 10.8 Chat moderacija — pregled svih chat soba
- [ ] 10.9 Financije — Stripe plaćanja, pregled zarade
- [ ] 10.10 Push notifikacije za nove narudžbe
