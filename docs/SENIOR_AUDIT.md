# SENIOR APP — Audit Report

> Generated: 2026-03-06  
> Flutter analyze: **0 errors, 0 warnings** ✅  
> Total Dart files: **15**  
> Total LOC (approx): **~4,800**

---

## 1. DUPLICIRANI KOD (Copy-Paste Violations)

### 1.1 `_statusChip()` — identičan u 3 fajla

| Fajl                       | Linija | Opis                                  |
| -------------------------- | ------ | ------------------------------------- |
| `orders_screen.dart`       | ~270   | `_statusChip(ThemeData, OrderStatus)` |
| `order_detail_screen.dart` | ~960   | `_statusChip(ThemeData, OrderStatus)` |
| `order_flow_screen.dart`   | —      | Nema ali koristi iste boje/logiku     |

**Identičan widget** (Container + padding + borderRadius + switch na 3 statusa s istim bojama). Copy-paste 1:1.

### 1.2 `_jobStatusBadge()` — slična logika kao `_statusChip()`

| Fajl                       | Linija |
| -------------------------- | ------ |
| `order_detail_screen.dart` | ~740   |

Isti pattern: switch → bg/fg/label → Container s borderRadius. Razlikuje se samo po `JobStatus` umjesto `OrderStatus`.

### 1.3 `_summaryRow()` — identičan u 2 fajla

| Fajl                       | Linija |
| -------------------------- | ------ | ----------------------------------------------------------------- |
| `order_flow_screen.dart`   | ~1615  | `_summaryRow(ThemeData, String label, String value, {bool bold})` |
| `order_detail_screen.dart` | ~430   | `_summaryRow(ThemeData, String label, String value, {bool bold})` |

Potpuno identična implementacija: Row → label (bodySmall/grey) + Spacer + value (bodyMedium/w600).

### 1.4 `_cardSummaryRow()` u `orders_screen.dart`

Gotovo identičan kao `_summaryRow()` iznad, samo bez `bold` parametra.

### 1.5 `_formatDate()` — identičan u 3 fajla

| Fajl                       | Opis                                                   |
| -------------------------- | ------------------------------------------------------ |
| `order_flow_screen.dart`   | `String _formatDate(DateTime date)` → `DD.MM.YYYY.`    |
| `order_detail_screen.dart` | `String _formatDate(DateTime date)` → `DD.MM.YYYY.`    |
| `order_model.dart`         | `static String _fmtDate(DateTime date)` → `DD.MM.YYYY` |

Sve 3 rade istu stvar: `padLeft(2, '0')` za dan i mjesec.

### 1.6 `_formatPrice()` — identičan u 2 fajla

| Fajl                       |
| -------------------------- | ------------------------------------------------- |
| `order_flow_screen.dart`   | `String _formatPrice(int euros) => '$euros,00 €'` |
| `order_detail_screen.dart` | `String _formatPrice(int euros) => '$euros,00 €'` |

### 1.7 `_priceForDay()` — identičan u 2 fajla

| Fajl                       |
| -------------------------- | --------------------------------------------------------------------------- |
| `order_flow_screen.dart`   | `int _priceForDay(int weekday, int hours)` — `hourlyRate=14, sundayRate=16` |
| `order_detail_screen.dart` | `int _priceForDay(int weekday, int hours)` — identični rate-ovi             |

### 1.8 `_dayMediumName()` — identičan u 2 fajla

| Fajl                       |
| -------------------------- | -------------------------------------------------------- |
| `order_flow_screen.dart`   | switch 1-7 → `AppStrings.dayMon` ... `AppStrings.daySun` |
| `order_detail_screen.dart` | identičan switch                                         |

### 1.9 `_dayFullName()` i `_dayShortName()` — `order_flow_screen.dart`

Isti pattern (switch 1-7 → AppStrings). Trebali bi biti zajednička utility.

### 1.10 `_buildField()` — dupliciran u 2 fajla

| Fajl                  | Razlika                                   |
| --------------------- | ----------------------------------------- |
| `login_screen.dart`   | Bez `enabled` parametra (uvijek editable) |
| `profile_screen.dart` | S `enabled: _isEditing`                   |

Isti core widget: TextField + labelText + borderRadius(16) + filled + fillColor.

### 1.11 `_buildGenderPicker()` — dupliciran u 2 fajla

| Fajl                  | Razlika                                              |
| --------------------- | ---------------------------------------------------- |
| `login_screen.dart`   | Prima `ThemeData` eksplicitno, uvijek editable       |
| `profile_screen.dart` | Koristi `Theme.of(context)`, s `enabled: _isEditing` |

Isti core: InputDecorator + DropdownButton M/F.

### 1.12 `_buildDatePicker()` — dupliciran u 2 fajla

| Fajl                  | Razlika                                                      |
| --------------------- | ------------------------------------------------------------ |
| `login_screen.dart`   | `DateTime?` (nullable), prima ThemeData                      |
| `profile_screen.dart` | `DateTime` (non-null), koristi Theme.of(), s enabled logikom |

Isti core: GestureDetector → showDatePicker → InputDecorator → formatted text.

### 1.13 `_sectionHeader()` — dupliciran u 2 fajla

| Fajl                  | Signature                                              |
| --------------------- | ------------------------------------------------------ |
| `login_screen.dart`   | `_sectionHeader(ThemeData, String)`                    |
| `profile_screen.dart` | `_sectionHeader(String)` — koristi `Theme.of(context)` |

---

## 2. HARDKODIRANE BOJE (Color Constants izvan Theme)

### 2.1 `_coral` i `_teal` hardkodirane u UI fajlovima

| Fajl                       | Konstanta | Vrijednost          |
| -------------------------- | --------- | ------------------- |
| `login_screen.dart`        | `_coral`  | `Color(0xFFEF5B5B)` |
| `login_screen.dart`        | `_teal`   | `Color(0xFF009D9D)` |
| `order_flow_screen.dart`   | `_teal`   | `Color(0xFF009D9D)` |
| `order_detail_screen.dart` | `_teal`   | `Color(0xFF009D9D)` |
| `order_detail_screen.dart` | `_coral`  | `Color(0xFFEF5B5B)` |
| `order_detail_screen.dart` | `_green`  | `Color(0xFF4CAF50)` |
| `order_detail_screen.dart` | `_grey`   | `Color(0xFF757575)` |

**Problem:** Iste boje su definirane u `theme.dart` (HelpiTheme.\_primary, HelpiTheme.\_accent) ali su private. UI fajlovi ne mogu ih pristupiti pa ih copy-paste-aju.

### 2.2 Inline boje bez varijable

Mnogi fajlovi koriste `const Color(0xFF757575)`, `const Color(0xFFE0E0E0)`, `const Color(0xFF9E9E9E)` inline, umjesto iz theme-a.

| Boja         | Upotreba              | Pojave                 |
| ------------ | --------------------- | ---------------------- |
| `0xFF757575` | Secondary text / grey | ~20+ puta              |
| `0xFFE0E0E0` | Border color          | ~15+ puta              |
| `0xFF9E9E9E` | Inactive tab text     | ~5 puta                |
| `0xFFEF5B5B` | Coral / primary       | ~10 puta (izvan theme) |
| `0xFF009D9D` | Teal / accent         | ~10 puta (izvan theme) |
| `0xFFE0F5F5` | Selected chip bg      | ~5 puta                |
| `0xFFE8F5E9` | Green status bg       | ~4 puta                |
| `0xFFE8F1FB` | Blue status bg        | ~3 puta                |

---

## 3. HARDKODIRANE VRIJEDNOSTI (Magic Numbers)

### 3.1 Pricing constants duplicirani

| Konstanta     | Vrijednost | Fajlovi                                              |
| ------------- | ---------- | ---------------------------------------------------- |
| `_hourlyRate` | `14`       | `order_flow_screen.dart`, `order_detail_screen.dart` |
| `_sundayRate` | `16`       | `order_flow_screen.dart`, `order_detail_screen.dart` |

### 3.2 Dimenzije ponavljane

| Vrijednost                          | Opis              | Pojave    |
| ----------------------------------- | ----------------- | --------- |
| `BorderRadius.circular(16)`         | Card/input radius | ~40+ puta |
| `BorderRadius.circular(12)`         | Chip/badge radius | ~10+ puta |
| `BorderRadius.circular(24)`         | Pill chip radius  | ~5 puta   |
| `EdgeInsets(16)` / `EdgeInsets(20)` | Padding           | ~30+ puta |
| `fontSize: 16`                      | Body text size    | ~15+ puta |

### 3.3 Hardkodirani stringovi (ne-lokalizirani)

| String           | Fajl                                       | Problem                                    |
| ---------------- | ------------------------------------------ | ------------------------------------------ |
| `'Hrvatski'`     | `login_screen.dart`, `profile_screen.dart` | Trebao bi ići kroz AppStrings              |
| `'English'`      | `login_screen.dart`, `profile_screen.dart` | Trebao bi ići kroz AppStrings              |
| `'Helpi v1.0.0'` | `profile_screen.dart`                      | Hardkodiran version string                 |
| `'HR'`, `'EN'`   | Login, Profile                             | OK kao vrijednosti dropdown-a (ne UI text) |

---

## 4. NEKONZISTENTNI WIDGETI I PATTERNI

### 4.1 Tab bar pattern — dupliciran, blago različit

| Fajl                     | Implementacija                                                                              |
| ------------------------ | ------------------------------------------------------------------------------------------- |
| `orders_screen.dart`     | Custom tab bar: Row → GestureDetector → Column → Text + Container(height:3)                 |
| `order_flow_screen.dart` | `_buildFrequencyChips()` — gotovo identičan ali koristi `Expanded` + malo drugačiji spacing |

Isti vizualni pattern, ali razlike u implementaciji.

### 4.2 Service chip container — dupliciran

| Fajl                            | Widget                                                                                          |
| ------------------------------- | ----------------------------------------------------------------------------------------------- |
| `order_flow_screen.dart`        | \_buildChip() — generic chip sa soft style                                                      |
| `order_detail_screen.dart`      | Inline Container(padding, borderRadius(24), border(teal), color(E0F5F5)) za service chip prikaz |
| `order_flow_screen.dart` Step 3 | Isti inline Container za service chips u summary                                                |

### 4.3 Info card pattern (plava kartica s info ikonicom)

Koristi se u `order_flow_screen.dart` na 2 mjesta s identičnim dekoracijom:

- Escort info card (Step 2)
- Overtime disclaimer card (Step 3)

Container → `HelpiTheme.cardBlue` + borderRadius(16) + Row(icon + text).

### 4.4 Day name helpers — 3 varijante iste logike

| Helper                | Output        | Fajl                                                 |
| --------------------- | ------------- | ---------------------------------------------------- |
| `_dayFullName(int)`   | "Ponedjeljak" | `order_flow_screen.dart`                             |
| `_dayShortName(int)`  | "Po"          | `order_flow_screen.dart`                             |
| `_dayMediumName(int)` | "Pon"         | `order_flow_screen.dart`, `order_detail_screen.dart` |

Svi koriste switch 1-7 → AppStrings.

### 4.5 Scroll-to-bottom helper — polu-dupliciran

| Fajl                     | Implementacija                                                 |
| ------------------------ | -------------------------------------------------------------- |
| `order_flow_screen.dart` | `_scrollToBottom()` → `addPostFrameCallback` + `animateTo`     |
| `chat_list_screen.dart`  | inline `addPostFrameCallback` + `animateTo` u `_sendMessage()` |

### 4.6 Review stars widget — dupliciran

| Fajl                                          | Kontekst                                                                   |
| --------------------------------------------- | -------------------------------------------------------------------------- |
| `order_detail_screen.dart` (job card)         | `List.generate(5, (i) => Icon(star/star_border, color: FFC107, size: 14))` |
| `order_detail_screen.dart` (one-time summary) | `List.generate(5, (i) => Icon(..., size: 18))`                             |
| `order_detail_screen.dart` (review sheet)     | `List.generate(5, (i) => Icon(..., size: 40))`                             |

3 varijante iste zvijezde logike s različitim veličinama.

### 4.7 `_firstOccurrence()` — duplicirana u 2 fajla

| Fajl                     |
| ------------------------ | --------------- |
| `order_flow_screen.dart` | instance metoda |
| `order_model.dart`       | static metoda   |

Identična logika: `(weekday - from.weekday + 7) % 7`.

---

## 5. STRUKTURALNI PROBLEMI

### 5.1 `order_flow_screen.dart` — 1,672 linija

Najveći fajl u projektu. Sadrži:

- 3 step build metode
- Chip buildere (time, minute, duration, day picker)
- Day card builder
- Summary builder
- CTA builder
- Submit logic
- Pricing logic
- Date formatting
- Day name helpers

**Preopterećen** — trebao bi biti razbijen.

### 5.2 `order_detail_screen.dart` — ~1,000 linija

Sadrži:

- Summary card builder
- Jobs section
- Job card builder
- Review bottom sheet
- Status chips
- Repeat order logic
- Cancel job dialog
- Day name helpers
- Pricing logic

### 5.3 Nema `shared/widgets/` — prazan folder

Pojektura ima `lib/shared/widgets/` ali je **prazan**. Svi widgeti su private metode unutar ekrana.

### 5.4 Nema `core/utils/formatters.dart`

Date formatting, price formatting, day name mapiranje — sve duplicirano po fajlovima.

### 5.5 Nema `core/constants/pricing.dart`

Hourly rate, Sunday rate — hardkodirani u 2 fajla.

### 5.6 Nema `core/constants/colors.dart`

Boje koje se koriste izvan theme-a nemaju centralno mjesto.

---

## 6. SAŽETAK

| Kategorija              | Broj pronađenih problema         |
| ----------------------- | -------------------------------- |
| Duplicirani widgeti     | 13                               |
| Hardkodirane boje       | 8 varijanti, ~70+ pojavljivanja  |
| Hardkodirani stringovi  | 3                                |
| Magic numbers (pricing) | 2 konstante × 2 fajla            |
| Nekonzistentni patterni | 7                                |
| Strukturalni problemi   | 6                                |
| **UKUPNO**              | **~39 identificiranih problema** |

---

> **Napomena:** Nijedan od ovih problema ne generira linter error — `flutter analyze` prolazi čisto.
> Ali WET (Write Everything Twice) kod se brzo akumulira i otežava održavanje.
