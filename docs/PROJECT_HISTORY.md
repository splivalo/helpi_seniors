# Helpi Senior  Project History

> Chronological log of key decisions and changes

---

## 2026-02-24  Project Initialization

### Decision: Architecture design and DB schema

- **Context:** Start of Helpi Senior mobile app development  connecting seniors with students for everyday help.
- **Decision:** Defined complete logical DB schema (11 tables), layered Flutter architecture (Clean Architecture + feature-first), and 15-step User Journey.
- **Key tables:** `users`, `student_profiles`, `student_services`, `availability_slots`, `availability_exceptions`, `bookings`, `payments`, `reviews`, `chat_rooms`, `chat_messages`, `notifications`.
- **Rationale:** Solid foundation before writing any production code. Seniors are target users -> UX principles defined from start (high contrast, large buttons, max 3 steps).
- **Stack:** Flutter + Bloc/Cubit, Supabase/Node.js backend, PostgreSQL, Stripe, Firebase FCM.
- **Chat model:** Senior <-> Admin <-> Student (admin as intermediary for safety).
- **Status:** ARCHITECTURE.md created.

---

## 2026-02-24  UI Prototype v1

### Decision: Complete UI prototype with mock data

- **Context:** Need for visual UX validation before backend development.
- **Result:** 9 screens, 4 tabs, 3-step booking flow, custom time picker, mock data for 5 students.
- **Screens:** Home, Marketplace (with filters), Student Detail (profile + calendar), Booking Flow (3 steps), Chat list + room, Profile.
- **Key UX decision:** Everything must be maximally simple for seniors  minimal steps, large buttons, clear colors.
- **Status:** All prototype screens complete.

---

## 2026-02-24  Categories removed

### Decision: All students do everything

- **Context:** Initially students had service categories (SVG icons). Decided all students are generalists.
- **Rationale:** Simplifies UX  senior doesn't need to choose a category, just a student. Backend doesn't need to filter by `service_type`.
- **Impact:** Category chip system removed, `service_type` filter becomes irrelevant for v1.
- **Status:** Implemented.

---

## 2026-02-24/25  Booking Sheet complete redesign

### Decision: 3 booking modes + per-day configuration

- **Context:** Initial booking was one-time only. Added recurring support.
- **3 modes:** One-time, Continuous (auto-renew monthly), Until date (fixed end).
- **Per-day:** Each selected day has its own start time + duration. Flat section design with inline date preview.
- **Chip-based selection:** Days, Start time, Duration  ALL chip interface, no dropdowns or pickers.
- **Pricing:** Per-day display in summary card. CTA "Next" without price.
- **Billing info:** "Card charged 30 min before each visit."
- **DatePicker:** HR localization (`flutter_localizations` SDK package).
- **Duration fix:** Duration chip has no default (requires explicit click).
- **Status:** Implemented.

---

## 2026-02-25  Calendar made read-only

### Decision: Calendar only displays info, not interactive

- **Context:** Calendar on student detail screen had tap-to-select functionality. But day selection happens in the booking sheet.
- **Decision:** Calendar is pure info  shows free/partial/booked per date. No selection.
- **Rationale:** Dual UX (calendar + booking sheet) is confusing for seniors.
- **"Book now" button:** Always visible below legend, not dependent on date selection.
- **Status:** Implemented.

---

## 2026-02-25  Unified borderRadius = 12

### Decision: All rounded corners set to 12

- **Context:** Mix of borderRadius values (8, 10, 12, 16) across the app  inconsistent.
- **Decision:** Everything set to 12. Exceptions: chat input bubble (24), tiny accent bars (2).
- **Files:** theme.dart, student_card.dart, home_screen.dart, student_detail_screen.dart, booking_flow_screen.dart, chat_list_screen.dart, profile_screen.dart.
- **Status:** Implemented.

---

## 2026-02-25  Chip color: coral -> teal

### Decision: Selected chips in teal (#009D9D) instead of coral (#EF5B5B)

- **Context:** When all chips (mode, day, time, duration) are coral, the screen "screams"  too much red.
- **Decision:** Selected chips use teal (secondary color). Coral stays for branding (app bar, logo).
- **Impact:** Single change in `_chip()` method  all chips automatically switched to teal.
- **Visual effect:** Much calmer look, chips visually "lead" toward the teal CTA button.
- **Status:** Implemented.

---

## 2026-02-25  Documentation restructured

### Decision: All MD files moved to `docs/` folder

- **Context:** PROGRESS.md, PROJECT_HISTORY.md, ARCHITECTURE.md, ROADMAP.md were in root folder  cluttering the structure.
- **Decision:** Created `docs/` folder and moved all project MDs there. README.md stays in root.
- **Status:** Implemented.

---

## 2026-02-25  All documentation translated to English

### Decision: MD files written in English

- **Context:** Developer(s) joining the project will be non-Croatian speakers.
- **Decision:** All documentation in `docs/` translated from Croatian to English.
- **Status:** Implemented.
