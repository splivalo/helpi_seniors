# Helpi Senior Project History

> Chronological log of key decisions and changes

---

## 2026-02-24 Project Initialization

### Decision: Architecture design and DB schema

- **Context:** Start of Helpi Senior mobile app development connecting seniors with students for everyday help.
- **Decision:** Defined complete logical DB schema (11 tables), layered Flutter architecture (Clean Architecture + feature-first), and user journey.
- **Rationale:** Solid foundation before writing any production code. Seniors are target users -> UX principles defined from start (high contrast, large buttons, max 3 steps).
- **Stack:** Flutter + Bloc/Cubit, Supabase/Node.js backend, PostgreSQL, Stripe, Firebase FCM.
- **Chat model:** Senior <-> Admin <-> Student (admin as intermediary for safety).
- **Status:** ARCHITECTURE.md created.

---

## 2026-02-24 UI Prototype v1 (Marketplace)

### Decision: Build marketplace with student browsing

- **Context:** Initial approach — seniors browse student profiles, select one, book directly.
- **Result:** 9 screens, 4 tabs, 3 booking modes, per-day config, custom time picker.
- **Status:** ARCHIVED to branch `archive/marketplace-v1`.

---

## 2026-02-25 Documentation restructured

### Decision: All MD files moved to `docs/` folder

- **Context:** MD files cluttering root folder.
- **Decision:** Created `docs/` folder, moved PROGRESS/HISTORY/ARCHITECTURE/ROADMAP there. README stays in root.
- **Status:** Implemented.

---

## 2026-02-26 MAJOR PIVOT: Marketplace removed, simplified order flow

### Decision: Remove student marketplace, adopt admin-assigned model

- **Context:** Marketplace (browse students, view profiles, pick slots) was too complex for seniors. Key insights:
  - First-time users don't know any students — browsing profiles creates false expectations.
  - Seniors want to **order help**, not **shop for a person**.
  - A simpler flow ("I need X on Y date") with admin assigning the best student is much more senior-friendly.
- **Decision:**
  - Marketplace code **archived** to branch `archive/marketplace-v1`.
  - First tab changed from "Studenti" to "Naruči" (Order).
  - New OrderScreen + OrderFlowScreen created.
  - Admin dashboard handles student assignment.
- **Impact:** Major UX simplification.
- **Status:** Implemented.

---

## 2026-02-26 Full 3-step Order Flow implemented

### Decision: Complete order flow with validation

- **OrderFlowScreen** — ~1226 lines, 3 steps:
  - **Step 1 "Kada?"**: Booking mode (one-time / recurring), date pickers, day/time/duration chips per day entry.
  - **Step 2 "Što vam treba?"**: Service type chips (kuhanje, čišćenje, kupovina, društvo, pratnja, tehnika, vrtlarstvo), free-text note, escort/overtime info cards.
  - **Step 3 "Pregled"**: Full order summary with all details.
- **Booking modes**: `oneTime` (single date + time) and `recurring` (weekly, with optional end date via Switch toggle).
- **Per-day config**: Each day entry has its own from-hour and duration.
- **Chip-based UI**: Everything is chip selection — no dropdowns.
- **Status:** Implemented.

---

## 2026-02-26 Pastel design overhaul

### Decision: New color system and visual identity

- **Context:** Original design was too harsh (dark nav, high-contrast teal chips).
- **New design system:**
  - Background: warm off-white `#F9F7F4`
  - borderRadius: 16 everywhere (up from 12)
  - Color split: coral `#EF5B5B` for progress/action, teal `#009D9D` for interactive/form
  - Chips selected: pastel teal fill `#E0F5F5` + teal border + teal text
  - Cards: white bg + grey border `#E0E0E0` (no pastel backgrounds)
  - No shadows on chips, cards, or date buttons
  - CTA buttons: coral
  - Switch, outlined buttons, FAB: teal
  - Bottom nav: white with subtle shadow
  - Step indicator bars: coral
  - Frequency tabs: tab bar style (coral active underline)
- **Status:** Implemented.

---

## 2026-02-26 Day range validation (bug fix)

### Decision: Filter day picker by date range

- **Context:** Bug discovered: when recurring mode has end date (e.g. 26.02-28.02), user could select Ponedjeljak (Monday) which doesn't exist in that period. App would show "Prva usluga: 02.03.2026" — AFTER the end date.
- **Fix (3-layer defense):**
  1. **Day picker filtering** — only shows weekdays that actually fall within start-end range.
  2. **Auto-cleanup** — when dates change, removes existing day entries that no longer fit.
  3. **Validation safety net** — Dalje button stays disabled if any day entry is out of range.
- **New helper:** `_isDayInRange(int weekday)` — checks if first occurrence falls before end date.
- **Status:** Implemented. 0 errors.

---

## 2026-02-26 Dead code cleanup

### Decision: Delete all marketplace/student code from lib/

- **Context:** Old marketplace code (archived to branch) was still sitting in lib/ as dead files.
- **Deleted files:**
  - `lib/features/marketplace/` — entire folder (home_screen, marketplace_screen, student_detail_screen + empty data/domain dirs)
  - `lib/features/booking/presentation/booking_flow_screen.dart` — old booking flow from marketplace
  - `lib/shared/widgets/student_card.dart` — only used by deleted marketplace code
- **Verification:** `flutter analyze` → 0 errors after deletion.
- **Status:** Implemented.
