# Helpi Senior Progress

> Last updated: 2026-03-03

---

## Overall progress: ~75%

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
- [x] 3.2 OrderFlowScreen — full 3-step flow (~1672 lines)
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
- [x] 3.11 "+ Dodaj dan" progressive disclosure: button only appears when ALL existing day entries have hour, minute, and duration filled
- [x] 3.12 Auto-scroll on duration selection: screen scrolls to bottom when duration chip is selected, revealing "+ Dodaj dan" button

#### Phase 4 — Orders Management (UI Prototype)

- [x] 4.1 Orders screen ("Moje narudžbe" — 3 tabs: U obradi, Aktivne, Završene)
- [x] 4.2 Order detail screen (tap-to-detail pattern)
- [x] 4.3 Pricing on order detail: 14€/h weekdays, 16€/h Sunday, per-day and weekly total
- [x] 4.4 JobModel + JobStatus enum (completed, upcoming, cancelled)
- [x] 4.5 Job generation: `addOrder()` generates concrete job dates from day entries
- [x] 4.6 "Termini" section: collapse/expand with chevron, default collapsed
- [x] 4.7 Job cards: date, time, duration, price, student name, status icon + badge
- [x] 4.8 Cancel individual job: confirmation dialog for upcoming jobs
- [x] 4.9 Rate per job: bottom sheet review (stars + comment) per completed job
- [x] 4.10 Inline review display: stars + comment shown on job card after rating
- [x] 4.11 Removed order-level Students section (reviews moved to job level)
- [x] 4.12 Compact format: 3-letter day abbreviations (Pet, Pon) + Xh format throughout

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
- [x] Job status colors: completed=teal, upcoming=#F57C00, cancelled=coral
- [x] Unified grey borders (#E0E0E0) on all job cards
- [x] White job card background, cancelled=#FAFAFA
- [x] Inline review card background: #F5F5F5

#### Session 2 — Color System Overhaul + Repeat Order + Mock Data (2026-03-02)

- [x] Color system overhaul: teal→green (#4CAF50) for active/completed, orange→blue (#1976D2) for processing/upcoming
- [x] Order status chips: Processing=blue, Active=green, Completed=green
- [x] Job status badges: Completed=green, Upcoming=blue, Cancelled=coral
- [x] Ocijeni button changed: coral ElevatedButton → teal OutlinedButton (borderRadius 8)
- [x] Otkaži button changed: coral OutlinedButton (borderRadius 8)
- [x] Service chips in Pregled step: pill shape (borderRadius 24)
- [x] One-time completed review inside summary card (grey title + student name + small Ocijeni button)
- [x] Termini section hidden for processing and one-time orders
- [x] completeOrder syncs job status for one-time orders
- [x] 3 mock completed orders seeded (one-time, recurring, recurring-with-end)
- [x] "Ponovi narudžbu" with DatePicker (one-time/recurring) and DateRangePicker (recurring-with-end)
- [x] Repeated orders go to processing status (no student, no jobs generated)
- [x] Auto-switch to "U obradi" tab after repeating order
- [x] Frequency labels: "Ponavljajuće", "Do DD.MM.YYYY" (shortened from "Ponavljajuće do...")
- [x] addProcessingOrder() method (no student/job assignment)
- [x] All MD documentation files updated for admin app handoff

#### Session 3 — DRY Refactor (Audit + Wire-Up)

- [x] Full codebase audit: SENIOR_AUDIT.md (39 problems found)
- [x] DRY refactor plan: SENIOR_DRY_PLAN.md (8 steps)
- [x] AppColors (colors.dart) — centralized 15+ color constants
- [x] AppPricing (pricing.dart) — hourlyRate/sundayRate/priceForDay/formatPrice
- [x] AppFormatters (formatters.dart) — date/dayFullName/dayMediumName/dayShortName/firstOccurrence
- [x] Shared widgets: StatusChip, JobStatusBadge, SummaryRow, SelectableChip, InfoCard, StarRating, TabBarSelector, HelpiFormFields (HelpiSectionHeader, HelpiTextField, HelpiGenderPicker, HelpiDatePicker)
- [x] AppStrings: added langHr, langEn, appVersion keys (HR+EN)
- [x] theme.dart: replaced private color constants with AppColors
- [x] orders_screen.dart: wired TabBarSelector, StatusChip, SummaryRow, AppColors
- [x] order_detail_screen.dart: wired StatusChip, JobStatusBadge, SummaryRow, StarRating, AppFormatters, AppPricing, AppColors
- [x] order_flow_screen.dart: wired SelectableChip, SummaryRow, InfoCard, TabBarSelector, AppFormatters, AppPricing, AppColors; removed 8 dead methods, 6 private constants
- [x] login_screen.dart: wired HelpiFormFields (HelpiTextField, HelpiGenderPicker, HelpiDatePicker, HelpiSectionHeader), AppColors, AppStrings.langHr/langEn; removed 4 dead helper methods + 2 private color constants
- [x] profile_screen.dart: wired HelpiFormFields, AppColors, AppStrings.langHr/langEn/appVersion; removed 4 dead helper methods
- [x] flutter analyze: 0 errors maintained throughout all changes

#### Dead Code Cleanup

- [x] Marketplace code deleted (home_screen, marketplace_screen, student_detail_screen)
- [x] Old booking_flow_screen deleted
- [x] student_card widget deleted
- [x] All dead code safely removed (0 errors after deletion)

#### Git & Repo

- [x] Git repo renamed: `splivalo/helpi_seniors` (from helpi_students_2.0)
- [x] Separate repos: `helpi_seniors` (senior app) + `helpi_students` (student app)

### Next Steps

1. Git commit + push DRY refactor (session 3)
2. Order confirmation screen (after "Naruči" submit)
3. APK rebuild with latest changes
4. GoRouter setup (1.5)
5. Backend integration (Supabase)
6. Admin app development (desktop + mobile responsive)

---

## Module Status

| Module              | Status                                                             | Progress |
| ------------------- | ------------------------------------------------------------------ | -------- |
| Architecture & Docs | Done, updated for session 2                                        | 100%     |
| Foundation          | Theme + i18n done                                                  | 80%      |
| Auth (UI)           | Login/Register done                                                | 40%      |
| Order Flow (UI)     | 3-step flow + progressive disclosure + auto-scroll                 | 95%      |
| Orders (UI)         | 3 tabs + detail + pricing + jobs + reviews + repeat order + colors | 90%      |
| Chat (UI prototype) | Screens done                                                       | 30%      |
| Profile (UI proto)  | Screen done                                                        | 25%      |
| Auth (backend)      | Waiting                                                            | 0%       |
| Booking (backend)   | Waiting                                                            | 0%       |
| Payment (Stripe)    | Waiting                                                            | 0%       |
| Chat (WebSocket)    | Waiting                                                            | 0%       |
| Admin App           | Planned                                                            | 0%       |
