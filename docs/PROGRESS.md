# Helpi Senior  Progress

> Last updated: 2026-02-26

---

## Overall progress: ~30%

### Completed

#### Phase 0  Initialization
- [x] Flutter project initialized (helpi_senior)
- [x] ARCHITECTURE.md  full architecture, DB schema, User Journey, API endpoints
- [x] PROJECT_HISTORY.md  chronological decision log
- [x] PROGRESS.md  progress tracking
- [x] ROADMAP.md  future priorities
- [x] Documentation moved to `docs/` folder

#### Phase 1  Foundation
- [x] 1.1 Folder structure (feature-first Clean Architecture)
- [x] 1.3 AppStrings i18n (Gemini Hybrid, HR + EN, 150+ keys)
- [x] 1.4 Senior-friendly theme (high contrast, 56dp buttons, 16sp+ font)
- [x] `flutter_localizations` SDK package integrated (HR locale for DatePicker)

#### UI Prototype v1  Marketplace (ARCHIVED)
- [x] Full marketplace with student profiles, filters, booking sheet, calendar
- [x] 3 booking modes, per-day config, recurring support
- [x] **Archived to branch `archive/marketplace-v1`**
- [x] **Decision: marketplace removed in favor of simplified order flow**

#### UI Prototype v2  Simplified Order Flow (IN PROGRESS)
- [x] "Naruči" (Order) tab replaces Marketplace as first tab
- [x] Empty OrderScreen placeholder created
- [ ] Order flow design & implementation (TBD)

#### Remaining Screens (kept from v1)
- [x] Chat list + chat room with messages
- [x] Profile screen (senior profile, settings, logout)
- [x] Orders screen (narudžbe tab)

#### UI Polish
- [x] Unified borderRadius = 12 across entire app
- [x] Selected chips: teal #009D9D
- [x] Dark bottom nav bar (#1E1E1E)
- [x] SafeArea on all standalone screens
- [x] Bottom sheet safe area fix

### Next Steps

1. **Design simplified order flow** (user picks service, date/time, done)
2. Remove dead marketplace code from lib/ (home_screen, marketplace_screen, student_detail, student_card)
3. GoRouter setup (1.5)
4. Auth flow (login/register screens)
5. Backend integration (Supabase)

---

## Module Status

| Module             | Status                           | Progress |
| ------------------ | -------------------------------- | -------- |
| Architecture & Docs| Done                             | 100%     |
| Foundation         | In progress                      | 60%      |
| Order Flow (v2)    | Placeholder only                 | 5%       |
| Marketplace (v1)   | **Archived** (archive/marketplace-v1) | N/A |
| Auth               | Waiting                          | 0%       |
| Booking (prod)     | Waiting for backend              | 0%       |
| Payment (prod)     | Waiting for Stripe               | 0%       |
| Chat (prod)        | Waiting for WebSocket            | 0%       |
| Profile (prod)     | Waiting for backend              | 0%       |
