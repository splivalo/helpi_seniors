# Helpi Senior Progress

> Last updated: 2026-02-28

---

## Overall progress: ~55%

### Completed

#### Phase 0 — Initialization

- [x] Flutter project initialized (helpi_senior)
- [x] ARCHITECTURE.md — full architecture, DB schema, User Journey, API endpoints
- [x] PROJECT_HISTORY.md — chronological decision log
- [x] PROGRESS.md — progress tracking
- [x] ROADMAP.md — future priorities
- [x] Documentation moved to `docs/` folder
- [x] DESIGN_SYSTEM.md — comprehensive visual reference (root)
- [x] PROJECT_CONTEXT.md — full project context for new chats (root)

#### Phase 1 — Foundation

- [x] 1.1 Folder structure (feature-first Clean Architecture)
- [x] 1.3 AppStrings i18n (Gemini Hybrid, HR + EN, 200+ keys)
- [x] 1.4 Senior-friendly theme (high contrast, 56dp buttons, 16sp+ font)
- [x] `flutter_localizations` SDK package integrated (HR locale for DatePicker)

#### Phase 2 — Auth (UI Prototype)

- [x] 2.1 Login/Register screen (email + password, senior-friendly)
- [x] Social login buttons (Google, Apple, Facebook — all SVG, circle style)
- [x] Language picker (HR/EN toggle)
- [x] Vertical centering with LayoutBuilder + ConstrainedBox

#### Phase 3 — Order Flow (UI Prototype)

- [x] 3.1 OrderScreen — landing page with "Nova narudžba" CTA
- [x] 3.2 OrderFlowScreen — full 3-step flow (~1454 lines)
  - [x] Step 1 "Kada?" — booking mode (one-time / recurring), date pickers, day/time/duration chips
  - [x] Step 2 "Što vam treba?" — service chips + free-text note + escort info card
  - [x] Step 3 "Pregled" — full order summary
- [x] 3.3 Booking modes: oneTime + recurring (with optional end date)
- [x] 3.4 Per-day configuration: each day entry has its own start time + duration
- [x] 3.5 Day range validation — day picker filters days that don't fall within start–end range
- [x] 3.6 Auto-cleanup of invalid day entries when dates change
- [x] 3.7 Progressive disclosure: Date → Hour → Minute → Duration (each step appears only after previous is selected)
- [x] 3.8 15-minute time precision: hour chips (08–19) + minute chips (:00, :15, :30, :45)
- [x] 3.9 One-time card container: matches recurring day card style (white bg, border, X to cancel, day name header + date subtitle)
- [x] 3.10 Hour/minute reset: changing hour resets minute selection

#### UI Design System (Pastel Overhaul)

- [x] Warm off-white background (#F9F7F4)
- [x] borderRadius = 16 everywhere
- [x] Color split: coral (#EF5B5B) for progress/action, teal (#009D9D) for interactive/form
- [x] Chip selected state: pastel teal fill (#E0F5F5) + teal border + teal text
- [x] Chip unselected: white fill + grey border (#E0E0E0)
- [x] Frequency mode: tab bar style (coral active underline, grey inactive)
- [x] Step indicator bars: coral
- [x] Switch: teal (active track, inactive thumb, outline)
- [x] CTA buttons (ElevatedButton): coral
- [x] Outlined buttons, FAB, text buttons: teal
- [x] Dodaj dan button: teal border/icon/text
- [x] Day cards & day picker: white bg + grey border (no pastel)
- [x] Date buttons: white bg + grey border, no shadow
- [x] White bottom nav with subtle shadow
- [x] No shadows on chips or cards

#### Remaining Screens

- [x] Chat list + chat room with messages (teal/mint bubbles)
- [x] Profile screen (lavender avatar, teal icons, settings, logout)
- [x] Orders screen ("Moje narudžbe" — 3 tabs: U obradi, Aktivne, Završene)
- [x] Order detail screen (tap-to-detail pattern + student review system)

#### Dead Code Cleanup

- [x] Marketplace code deleted (home_screen, marketplace_screen, student_detail_screen)
- [x] Old booking_flow_screen deleted
- [x] student_card widget deleted
- [x] All dead code safely removed (0 errors after deletion)

#### Git & Repo

- [x] Git repo renamed: `splivalo/helpi_seniors` (from helpi_students_2.0)
- [x] Separate repos: `helpi_seniors` (senior app) + `helpi_students` (student app)

### Next Steps

1. Git commit + push all current work (15-min intervals, card redesign)
2. Order confirmation screen (after "Naruči" submit)
3. APK rebuild with latest changes
4. GoRouter setup (1.5)
5. Backend integration (Supabase)

---

## Module Status

| Module              | Status                         | Progress |
| ------------------- | ------------------------------ | -------- |
| Architecture & Docs | Done                           | 100%     |
| Foundation          | Theme + i18n done              | 80%      |
| Auth (UI)           | Login/Register done            | 40%      |
| Order Flow (UI)     | 3-step flow + 15-min precision | 90%      |
| Orders (UI)         | 3 tabs + detail + reviews      | 50%      |
| Chat (UI prototype) | Screens done                   | 30%      |
| Profile (UI proto)  | Screen done                    | 25%      |
| Auth (backend)      | Waiting                        | 0%       |
| Booking (backend)   | Waiting                        | 0%       |
| Payment (Stripe)    | Waiting                        | 0%       |
| Chat (WebSocket)    | Waiting                        | 0%       |
