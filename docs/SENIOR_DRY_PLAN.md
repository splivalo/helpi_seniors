# SENIOR APP — DRY Refaktor Plan

> Generated: 2026-03-06  
> Referenca: `docs/SENIOR_AUDIT.md`  
> Status: **ČEKA POTVRDU** — ne implementirati bez izričite potvrde

---

## Prioriteti

| Prioritet | Opis                                             | Impact  |
| --------- | ------------------------------------------------ | ------- |
| 🔴 P0     | Shared widgets (eliminiraju najviše duplikacije) | Visok   |
| 🟠 P1     | Utility/formatteri (date, price, day names)      | Visok   |
| 🟡 P2     | Konstante (boje, pricing, dimenzije)             | Srednji |
| 🟢 P3     | Razbijanje velikih fajlova                       | Srednji |
| 🔵 P4     | Hardkodirani stringovi → AppStrings              | Nizak   |

---

## KORAK 1 — `lib/core/constants/` (P2)

### 1a. `lib/core/constants/colors.dart`

Izložiti boje iz theme-a kao public konstante + dodati utility boje.

```dart
class AppColors {
  AppColors._();

  // Primary palette (mirrors HelpiTheme)
  static const Color coral = Color(0xFFEF5B5B);
  static const Color teal = Color(0xFF009D9D);

  // Semantic
  static const Color error = Color(0xFFC62828);
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF1976D2);

  // Neutrals
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
  static const Color inactive = Color(0xFF9E9E9E);
  static const Color background = Color(0xFFF9F7F4);

  // Status backgrounds
  static const Color statusGreenBg = Color(0xFFE8F5E9);
  static const Color statusBlueBg = Color(0xFFE8F1FB);
  static const Color statusRedBg = Color(0xFFFFEBEE);

  // Chip / selection
  static const Color selectedChipBg = Color(0xFFE0F5F5);
}
```

**Rezultat:** Zamjena ~70+ inline `Color(0xFF...)` referenci s `AppColors.x`.

### 1b. `lib/core/constants/pricing.dart`

```dart
class AppPricing {
  AppPricing._();

  static const int hourlyRate = 14;   // €/h standard
  static const int sundayRate = 16;   // €/h Sunday

  static int priceForDay(int weekday, int hours) {
    final rate = weekday == DateTime.sunday ? sundayRate : hourlyRate;
    return rate * hours;
  }

  static String formatPrice(int euros) => '$euros,00 €';
}
```

**Rezultat:** Eliminira dupliciran `_priceForDay()` i `_formatPrice()` iz 2 fajla.

---

## KORAK 2 — `lib/core/utils/formatters.dart` (P1)

```dart
class AppFormatters {
  AppFormatters._();

  /// "DD.MM.YYYY."
  static String date(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  /// DateTime.weekday (1-7) → full name via AppStrings
  static String dayFullName(int weekday) { /* switch 1-7 */ }

  /// DateTime.weekday → 3-letter: "Pon", "Uto" ...
  static String dayMediumName(int weekday) { /* switch 1-7 */ }

  /// DateTime.weekday → 2-letter: "Po", "Ut" ...
  static String dayShortName(int weekday) { /* switch 1-7 */ }

  /// First occurrence of [weekday] on or after [from].
  static DateTime firstOccurrence(int weekday, DateTime from) {
    final diff = (weekday - from.weekday + 7) % 7;
    return from.add(Duration(days: diff == 0 ? 0 : diff));
  }
}
```

**Rezultat:** Eliminira 5 dupliciranih metoda (`_formatDate`, `_dayFullName`, `_dayMediumName`, `_dayShortName`, `_firstOccurrence`) iz 3 fajla.

---

## KORAK 3 — `lib/shared/widgets/` (P0)

### 3a. `status_chip.dart` — OrderStatus chip

```dart
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final OrderStatus status;
  // ...
}
```

**Zamjenjuje:** identičan `_statusChip()` iz `orders_screen.dart` i `order_detail_screen.dart`.

### 3b. `job_status_badge.dart` — JobStatus badge

```dart
class JobStatusBadge extends StatelessWidget {
  const JobStatusBadge({super.key, required this.status});
  final JobStatus status;
  // ...
}
```

**Zamjenjuje:** `_jobStatusBadge()` iz `order_detail_screen.dart`.

### 3c. `summary_row.dart` — Label-Value row

```dart
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });
  // ...
}
```

**Zamjenjuje:** `_summaryRow()` iz `order_flow_screen.dart` i `order_detail_screen.dart`, te `_cardSummaryRow()` iz `orders_screen.dart`.

### 3d. `selectable_chip.dart` — Soft selection chip

```dart
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  // ...
}
```

**Zamjenjuje:** `_buildChip()` iz `order_flow_screen.dart`. Može se koristiti za tab bars, day picker, time/duration chipove.

### 3e. `info_card.dart` — Informacijska kartica

```dart
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.text, this.color});
  final String text;
  final Color? color;
  // ...
}
```

**Zamjenjuje:** dupliciran escort info card i overtime disclaimer card iz `order_flow_screen.dart`.

### 3f. `star_rating.dart` — Zvjezdice za ocjenu

```dart
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.onTap,
  });
  final int rating;
  final double size;
  final ValueChanged<int>? onTap; // null = display-only
  // ...
}
```

**Zamjenjuje:** 3 varijante `List.generate(5, ...)` zvjezdica iz `order_detail_screen.dart`.

### 3g. `form_field_builder.dart` — Zajednički form widgeti

```dart
class HelpiTextField extends StatelessWidget { ... }
class HelpiGenderPicker extends StatelessWidget { ... }
class HelpiDatePicker extends StatelessWidget { ... }
class HelpiSectionHeader extends StatelessWidget { ... }
```

**Zamjenjuje:** duplicirane `_buildField()`, `_buildGenderPicker()`, `_buildDatePicker()`, `_sectionHeader()` iz `login_screen.dart` i `profile_screen.dart`.

---

## KORAK 4 — `lib/shared/widgets/tab_bar_selector.dart` (P0)

```dart
class TabBarSelector extends StatelessWidget {
  const TabBarSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  // Coral underline style
}
```

**Zamjenjuje:** dupliciran custom tab bar iz `orders_screen.dart` i `_buildFrequencyChips()` iz `order_flow_screen.dart`.

---

## KORAK 5 — Hardkodirani stringovi → AppStrings (P4)

| String           | Ključ        | HR             | EN             |
| ---------------- | ------------ | -------------- | -------------- |
| `'Hrvatski'`     | `langHr`     | `Hrvatski`     | `Croatian`     |
| `'English'`      | `langEn`     | `English`      | `English`      |
| `'Helpi v1.0.0'` | `appVersion` | `Helpi v1.0.0` | `Helpi v1.0.0` |

---

## KORAK 6 — Razbijanje `order_flow_screen.dart` (P3)

Trenutno: **~1,672 linija** u jednom fajlu.

Predložena struktura:

```
lib/features/order/presentation/
├── order_screen.dart              (ostaje — mali, ~60 linija)
├── order_flow_screen.dart         (reduciran na ~400 linija — scaffold + state)
└── widgets/
    ├── step_indicator.dart         (~30 linija)
    ├── step1_when.dart             (~300 linija — one-time & recurring content)
    ├── step2_services.dart         (~100 linija — service chips + note)
    ├── step3_summary.dart          (~250 linija — summary + payment + disclaimer)
    ├── time_chips.dart             (~80 linija — hour/minute/duration grids)
    └── day_card.dart               (~120 linija — recurring day entry card)
```

**Napomena:** State ostaje u `order_flow_screen.dart`, child widgeti primaju callbacks.

---

## KORAK 7 — Razbijanje `order_detail_screen.dart` (P3)

Trenutno: **~1,000 linija**.

Predložena struktura:

```
lib/features/booking/presentation/
├── order_detail_screen.dart        (reduciran na ~300 linija — scaffold + state)
└── widgets/
    ├── order_summary_card.dart     (~200 linija)
    ├── jobs_section.dart           (~200 linija)
    ├── job_card.dart               (~100 linija)
    └── review_bottom_sheet.dart    (~100 linija)
```

---

## KORAK 8 — HelpiTheme clean-up (P2)

1. Maknuti `_` iz boja u `theme.dart` → koristiti `AppColors` iz koraka 1a
2. HelpiTheme referira `AppColors` umjesto privatnih varijabli
3. UI fajlovi koriste `AppColors` ili `Theme.of(context)` — nikad inline `Color(0xFF...)`

---

## REDOSLIJED IZVRŠAVANJA

```
Korak 1 (constants)      ← bez UI promjena, samo dodaj fajlove
    ↓
Korak 2 (formatters)     ← bez UI promjena, samo dodaj fajl
    ↓
Korak 3 (shared widgets) ← najviše eliminira duplikacije
    ↓
Korak 4 (tab selector)   ← mali ali koristan
    ↓
Korak 5 (AppStrings)     ← trivijalan
    ↓
Korak 6 (split order_flow) ← najveći fajl, oprezno
    ↓
Korak 7 (split order_detail) ← drugi najveći
    ↓
Korak 8 (theme cleanup)  ← finalni polish
```

Svaki korak je **inkrementalan** i **testabilan** — `flutter analyze` mora ostati na 0 errora nakon svakog koraka.

---

## PROCJENA

| Korak      | Fajlova dodano/izmijenjeno | Linija duplikacije eliminirano |
| ---------- | -------------------------- | ------------------------------ |
| 1          | +2                         | — (prep)                       |
| 2          | +1                         | ~50                            |
| 3          | +7, ~6 izmijenjenih        | ~300                           |
| 4          | +1, ~2 izmijenjenih        | ~60                            |
| 5          | ~1 izmijenjeni             | ~6                             |
| 6          | +6, ~1 izmijenjeni         | — (reorganizacija)             |
| 7          | +4, ~1 izmijenjeni         | — (reorganizacija)             |
| 8          | ~2 izmijenjeni             | ~70 inline boja                |
| **Ukupno** | **~21 fajlova**            | **~486 linija duplikacije**    |

---

> **STROGO:** Nijedan korak NE SMIJE započeti bez izričite potvrde. Ovo je plan, ne odobrenje.
