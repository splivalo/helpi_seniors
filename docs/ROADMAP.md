# Helpi Senior - Roadmap

> WARNING: It is STRICTLY FORBIDDEN to start any task from the Roadmap without explicit user confirmation.
> Every step requires explicit approval from the product owner.

> Last updated: 2026-02-25

---

## Phase 1 - Foundation (infrastructure)

- [x] 1.1 Reorganize `lib/` folder structure (feature-first Clean Arch)
- [ ] 1.2 Add packages to `pubspec.yaml` (bloc, go_router, dio, etc.)
- [x] 1.3 `AppStrings` i18n (Gemini Hybrid pattern, HR + EN, 140+ keys)
- [x] 1.4 Senior-friendly theme (high contrast, large fonts, borderRadius 12)
- [x] 1.4b `flutter_localizations` SDK package (HR locale)
- [ ] 1.5 GoRouter setup with placeholder screens
- [ ] 1.6 DI setup (GetIt + injectable)
- [ ] 1.7 Dio HTTP client with interceptors

## Phase 2 - Auth

- [ ] 2.1 Login screen (email + password, senior-friendly)
- [ ] 2.2 Registration screen
- [ ] 2.3 Auth Cubit + repository
- [ ] 2.4 Token storage (flutter_secure_storage)
- [ ] 2.5 Auto-login on splash

## Phase 3 - Marketplace

- [ ] 3.1 Student list screen (cards with photo, name, rating, price)
- [ ] 3.2 Filter Bottom Sheet (date, proximity, availability)
- [ ] 3.3 Student detail screen (bio, reviews, availability)
- [ ] 3.4 Marketplace Cubit + repository
- [ ] 3.5 Backend integration

## Phase 4 - Booking & Payment

- [ ] 4.1 Slot Picker (calendar + time slots)
- [ ] 4.2 Order review screen
- [ ] 4.3 Stripe Payment Sheet integration
- [ ] 4.4 Booking Cubit + repository
- [ ] 4.5 Payment Cubit + Stripe service
- [ ] 4.6 Order confirmation screen
- [ ] 4.7 "My orders" screen (session list with statuses)

## Phase 5 - Chat

- [ ] 5.1 Chat list screen
- [ ] 5.2 Chat room screen (messages)
- [ ] 5.3 WebSocket integration
- [ ] 5.4 Chat Cubit + repository
- [ ] 5.5 Admin-mediated chat model

## Phase 6 - Reviews & Profile

- [ ] 6.1 Review form (stars + comment)
- [ ] 6.2 Senior profile screen
- [ ] 6.3 Edit profile
- [ ] 6.4 Notifications screen

## Phase 7 - Recurring Booking Management

- [ ] 7.1 Push notification when student cancels a session
- [ ] 7.2 Senior options: Skip session / Cancel all
- [ ] 7.3 "My orders" with recurring view (session list + per-date statuses)
- [ ] 7.4 Backend: `booking_status` extension (`skipped`, `cancelled_by_student`)
- [ ] 7.5 Travel buffer: fixed 30 min between sessions (backend logic, invisible to senior)

## Phase 7.5 - Replacement Student (v1.5+)

- [ ] 7.5.1 Backend endpoint: `GET /students/available?date=X&start=Y&duration=Z&city=W`
- [ ] 7.5.2 Mini-list of replacement students (filtered by day/time/city, NO service type filter since all students do everything)
- [ ] 7.5.3 Senior picks replacement with one click -> one-time booking
- [ ] 7.5.4 Original recurring stays unchanged, only that date gets status `replaced`
- [ ] 7.5.5 UI in "My orders": swap icon for replaced sessions

## Phase 7.6 - Configurable Travel Buffer (v1.5+)

- [ ] 7.6.1 Student app: setting "Time between sessions" (15/30/45/60 min, default 30)
- [ ] 7.6.2 Backend uses per-student buffer instead of fixed 30 min
- [ ] 7.6.3 DB: `student_profiles.travel_buffer_min INT DEFAULT 30`

## Phase 8 - Polish & Launch

- [ ] 8.1 Push notifications (Firebase FCM)
- [ ] 8.2 Error handling & offline mode
- [ ] 8.3 Performance optimization
- [ ] 8.4 Accessibility audit
- [ ] 8.5 Beta testing
- [ ] 8.6 Play Store / App Store deployment
