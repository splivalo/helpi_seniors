# Helpi Design System

> Ovaj dokument opisuje KOMPLETAN vizualni stil Helpi aplikacije.
> Koristi ga kao referencu kod izrade bilo kojeg novog ekrana ili komponente.
> Student app i Senior app dijele ISTI dizajn sustav.

> Last updated: 2026-03-02

---

## 1. Boje

### Primarne

| Naziv                       | Hex       | Uporaba                                                                                                            |
| --------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------ |
| **Coral** (primary)         | `#EF5B5B` | CTA gumbi, tab underline (active), cancel link, login gumb, logo krug pozadina                                     |
| **Teal** (secondary/accent) | `#009D9D` | Outlined gumbi, chipovi (active), input field ikone, text linkovi, bottom nav selected, student name, Ocijeni gumb |

### Pozadine

| Naziv               | Hex       | Uporaba                                     |
| ------------------- | --------- | ------------------------------------------- |
| **Warm off-white**  | `#F9F7F4` | Scaffold background — svi ekrani            |
| **Surface (white)** | `#FFFFFF` | Kartice, input fieldovi, bottom nav, modali |
| **Pastel teal**     | `#E0F5F5` | Chip pozadina (selektirani servisi)         |

### Pastelne boje za kartice

| Naziv         | Hex       |
| ------------- | --------- |
| Card Mint     | `#E8F5F1` |
| Card Lavender | `#F0EBFA` |
| Card Cream    | `#FFF8E7` |
| Card Blue     | `#E8F1FB` |

### ColorScheme dopune

| Naziv               | Hex       |
| ------------------- | --------- |
| Primary container   | `#FFE8E5` |
| Secondary container | `#D4F0F0` |
| Error               | `#C62828` |

### Tekst boje

| Naziv                 | Hex       | Uporaba                                            |
| --------------------- | --------- | -------------------------------------------------- |
| **Text primary**      | `#2D2D2D` | Naslovi, body tekst                                |
| **Text secondary**    | `#757575` | Subtitles, labels, hintovi                         |
| **Border grey**       | `#E0E0E0` | Card borders, input borders, social button borders |
| **Inactive tab text** | `#9E9E9E` | Tab tekst kad nije selektiran                      |
| **Divider**           | `#EEEEEE` | Separator linije                                   |
| **Nav unselected**    | `#B0B0B0` | Bottom nav neselektirane ikone                     |

### Status / Badge boje

| Status         | Foreground | Background | Uporaba                                         |
| -------------- | ---------- | ---------- | ----------------------------------------------- |
| **Processing** | `#1976D2`  | `#E8F1FB`  | "U obradi" order badge, "Predstojeći" job badge |
| **Active**     | `#4CAF50`  | `#E8F5E9`  | "Aktivna" order badge                           |
| **Completed**  | `#4CAF50`  | `#E8F5E9`  | "Završena" order badge, "Završen" job badge     |
| **Cancelled**  | `#EF5B5B`  | `#FFEBEE`  | "Otkazan" job badge                             |

### Specijalne

| Naziv                 | Hex       | Uporaba                                |
| --------------------- | --------- | -------------------------------------- |
| **Star yellow**       | `#FFC107` | Zvjezdice za ocjene                    |
| **Facebook blue**     | `#1877F2` | Facebook logo                          |
| **Review card bg**    | `#F5F5F5` | Inline review container na job kartici |
| **Cancelled card bg** | `#FAFAFA` | Job kartica kad je otkazan             |

---

## 2. Border Radius

| Vrijednost | Koristi se za                                                             |
| ---------- | ------------------------------------------------------------------------- |
| **24**     | Service chipovi u Pregled koraku (pill oblik), Chat bubble                |
| **16**     | Kartice, CTA gumbi, input fieldovi — STANDARDNI radius                    |
| **12**     | Order status chipovi, review kartice, job kartice — manji elementi        |
| **10**     | Inline review container unutar job kartice                                |
| **8**      | Job status badge, mali action gumbi (Ocijeni, Otkaži) — najmanji elementi |
| **20**     | BottomSheet gornji kutovi                                                 |
| **2**      | Tab underline indikator (namjerno tanki)                                  |

> **PRAVILO:** Za nove komponente koristi **16** osim ako je element manji (mali gumb → 8, chip status → 12) ili je poseban oblik (service chip summary → 24).

---

## 3. Dimenzije

| Konstanta         | Vrijednost | Opis                                              |
| ----------------- | ---------- | ------------------------------------------------- |
| `buttonHeight`    | 56         | Standardna visina ElevatedButton i OutlinedButton |
| `buttonRadius`    | 16         | Border radius velikih gumba                       |
| `cardRadius`      | 16         | Border radius svih kartica                        |
| Login CTA visina  | 52         | LoginScreen gumb je nešto manji                   |
| Action btn visina | 30         | Mali Ocijeni/Otkaži gumbi na job karticama        |

---

## 4. Tipografija (TextTheme)

| TextTheme slot   | Veličina | Weight | Boja      |
| ---------------- | -------- | ------ | --------- |
| `headlineLarge`  | 30       | w800   | `#2D2D2D` |
| `headlineMedium` | 26       | w700   | `#2D2D2D` |
| `headlineSmall`  | 20       | w700   | `#2D2D2D` |
| `bodyLarge`      | 18       | w400   | `#2D2D2D` |
| `bodyMedium`     | 16       | w400   | `#2D2D2D` |
| `bodySmall`      | 14       | w400   | `#757575` |
| `labelLarge`     | 18       | w600   | white     |

---

## 5. Komponente

### 5.1 ElevatedButton (Primary CTA)

```dart
ElevatedButton.styleFrom(
  backgroundColor: Color(0xFFEF5B5B),  // coral
  foregroundColor: Colors.white,
  minimumSize: Size(double.infinity, 56),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  elevation: 0,
)
```

### 5.2 OutlinedButton (Secondary)

```dart
OutlinedButton.styleFrom(
  foregroundColor: Color(0xFF009D9D),  // teal
  minimumSize: Size(double.infinity, 56),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  side: BorderSide(color: Color(0xFF009D9D), width: 2),
  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
)
```

### 5.3 TextButton

```dart
TextButton.styleFrom(
  foregroundColor: Color(0xFF009D9D),  // teal
  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
)
```

### 5.4 Card

- Pozadina: white
- Elevation: 0
- Border: `Border.all(color: Color(0xFFE0E0E0))` — sivi border
- Border radius: 16
- Margin: horizontal 16, vertical 8

### 5.5 Input Field (TextField)

- Filled: true, fillColor: white
- Border: `OutlineInputBorder(borderRadius: 16, borderSide: Color(0xFFE0E0E0))`
- Focus border: teal `#009D9D`, width 2
- Error border: `#C62828`, width 2
- Prefix ikone: teal boja
- Content padding: horizontal 20, vertical 18
- Label/hint style: fontSize 16, color `#757575`

### 5.6 Tab Toggle (custom, nije TabBar)

- **Active tab:** coral text + 3px coral underline
- **Inactive tab:** `#9E9E9E` text + 1px `#E0E0E0` underline
- Implementirano kao Row od GestureDetector + Column(Text, Container underline)
- Sve tabove jednako širi s `Expanded`

### 5.7 Service Chip (Order Flow — odabir usluga)

- Bijeli background, `#E0E0E0` border
- Selektirani: pastel teal fill (`#E0F5F5`) + teal border + teal tekst
- Border radius: 16
- Padding: horizontal 16, vertical 10

### 5.7a Service Chip (Pregled korak — prikaz odabranih)

- Pastel teal fill (`#E0F5F5`) + teal border (`#009D9D`)
- Teal tekst, fontSize 13, w500
- Border radius: **24** (pill oblik)
- Padding: horizontal 12, vertical 6

### 5.7b Time Selection Chips (Order Flow)

Order flow koristi progresivno otkrivanje za odabir vremena:

1. **Sati** — 12 chipova u 3 reda po 4: `08:00`, `09:00` ... `19:00`
2. **Minute** — 4 chipa u 1 redu: `:00`, `:15`, `:30`, `:45` (pojavi se tek nakon odabira sata)
3. **Trajanje** — 4 chipa: `1 sat`, `2 sata`, `3 sata`, `4 sata` (pojavi se tek nakon odabira minuta)

- Svaki nivo se pojavljuje tek kad prethodni bude odabran (progressive disclosure)
- Promjena sata resetira odabir minuta
- Chipovi koriste isti stil kao ostali (`_buildChip`)
- Labeli sekcija: "Sati", "Minute", "Trajanje" — bodyMedium, w600

### 5.7c One-Time Card (Order Flow)

Jednokratni termin je umotan u istu karticu kao ponavljajući:

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFE0E0E0)),
  ),
  child: Column(
    children: [
      Row(children: [
        Text(dayName, style: bodyLarge.copyWith(fontWeight: FontWeight.w700)),
        Spacer(),
        GestureDetector(onTap: cancel, child: Icon(Icons.close, size: 22, color: Color(0xFF757575))),
      ]),
      SizedBox(height: 6),
      Text(formattedDate, style: bodySmall.copyWith(color: Color(0xFF757575))),
      // ... Sati → Minute → Trajanje chipovi
    ],
  ),
)
```

### 5.8 Order Status Chip (na order karticama)

- Border radius: **12**
- Padding: horizontal 12, vertical 4
- Font: 13, w600

| Status     | Text color | Background |
| ---------- | ---------- | ---------- |
| `U obradi` | `#1976D2`  | `#E8F1FB`  |
| `Aktivna`  | `#4CAF50`  | `#E8F5E9`  |
| `Završena` | `#4CAF50`  | `#E8F5E9`  |

### 5.9 Job Status Badge (na job karticama)

- Border radius: **8**
- Padding: horizontal 8, vertical 2
- Font: 11, w600

| Status          | Text color | Background | Icon           |
| --------------- | ---------- | ---------- | -------------- |
| **Završen**     | `#4CAF50`  | `#E8F5E9`  | `check_circle` |
| **Predstojeći** | `#1976D2`  | `#E8F1FB`  | `schedule`     |
| **Otkazan**     | `#EF5B5B`  | `#FFEBEE`  | `cancel`       |

- Icon size: 18, color matches text color
- Cancelled date text: `TextDecoration.lineThrough` + grey

### 5.10 Job Card (Termini sekcija)

```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: isCancelled ? Color(0xFFFAFAFA) : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Color(0xFFE0E0E0)),  // unified grey for ALL statuses
  ),
)
```

- **Row 1:** Status icon (18px) + date (3-letter day + date) + status badge
- **Row 2:** Time · Duration · Price (bodySmall, grey, left padding 26)
- **Row 3:** Student name with `person_outline` icon (teal, w600)
- **Row 4 (conditional):**
  - Completed without review: **teal outlined** "Ocijeni" button (height 30, borderRadius 8)
  - Upcoming: **coral outlined** "Otkaži" button (height 30, borderRadius 8, aligned right with Spacer)
- **Review inline (if rated):** Stars + comment in #F5F5F5 container (borderRadius 10)

### 5.10a Ocijeni Button (mali, na job kartici)

```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Color(0xFF009D9D),  // teal
    side: BorderSide(color: Color(0xFF009D9D)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    minimumSize: Size(0, 30),
    padding: EdgeInsets.symmetric(horizontal: 12),
  ),
  child: Text('Ocijeni', style: TextStyle(fontSize: 12)),
)
```

### 5.10b Otkaži Button (mali, na job kartici)

```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Color(0xFFEF5B5B),  // coral
    side: BorderSide(color: Color(0xFFEF5B5B)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    minimumSize: Size(0, 30),
    padding: EdgeInsets.symmetric(horizontal: 12),
  ),
  child: Text('Otkaži', style: TextStyle(fontSize: 12)),
)
```

### 5.10c One-Time Review (inside summary card)

Za jednokratne završene narudžbe, recenzija se prikazuje **unutar summary kartice**, ne u Termini sekciji:

- Grey title: "Ime studenta" (AppStrings.studentName), fontSize 12, color `#757575`
- Ako **nema recenzije**: Row s person icon + student name (teal) + mali Ocijeni gumb (teal outlined, height 30, borderRadius 8)
- Ako **ima recenzija**: Person icon + student name, stars + date, comment text — sve inline u summary kartici

### 5.11 Termini Section Container

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFE0E0E0)),
  ),
)
```

- Header: "Termini" title + chevron icon (expand/collapse)
- Default state: **collapsed**
- GestureDetector on header row toggles `_jobsExpanded`
- **Skrivena** za narudžbe sa statusom `processing` i za jednokratne (`isOneTime`) narudžbe

### 5.12 Social Login Button (krug)

```dart
Container(
  width: 56, height: 56,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
    border: Border.all(color: Color(0xFFE0E0E0)),
  ),
  child: Center(
    child: SvgPicture.asset(assetPath, width: 24, height: 24),
  ),
)
```

- Google, Apple, Facebook — SVG logotipi u `assets/images/`
- Razmak između: 16

### 5.13 Bottom Navigation Bar

- Pozadina: white
- Selected item: teal `#009D9D`
- Unselected item: `#B0B0B0`
- Selected label: fontSize 14, w600
- Unselected label: fontSize 14
- Type: fixed
- Elevation: 0
- Shadow: `BoxShadow(color: black/alpha10, blurRadius: 12, offset: Offset(0, -4))`
- Ikone: size 28

### 5.14 AppBar

- Pozadina: `#F9F7F4` (ista kao scaffold)
- Foreground: `#2D2D2D`
- Elevation: 0
- Center title: true
- Title style: fontSize 22, w700

### 5.15 Logo (Login ekran)

```dart
Container(
  width: 100, height: 100,
  decoration: BoxDecoration(color: coral, shape: BoxShape.circle),
  child: SvgPicture.asset('h_logo.svg', width: 50, height: 50,
    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
)
```

### 5.16 Action Buttons (Order Detail — footer)

Na dnu order detail ekrana, ovisno o statusu narudžbe:

| Status     | Gumbi                                              |
| ---------- | -------------------------------------------------- |
| Processing | "Otkaži narudžbu" — coral outlined, borderRadius 8 |
| Active     | "Otkaži narudžbu" — coral outlined, borderRadius 8 |
| Completed  | "Ponovi narudžbu" — teal outlined, borderRadius 16 |

### 5.17 Ponovi Narudžbu (Repeat Order)

Kad senior klikne "Ponovi narudžbu" na završenoj narudžbi:

- **Jednokratna / ponavljajuća bez kraja**: `showDatePicker` — odaberi novi početni datum
- **Ponavljajuća s krajnjim datumom**: `showDateRangePicker` — odaberi novi raspon datuma
- Ponovljena narudžba ide u status **Processing** ("U obradi"), bez studenta i bez termina
- Tab se automatski prebaci na "U obradi" (tab 0) nakon ponavljanja

---

## 6. Layout Patterns

### 6.1 Login/Register Screen

- `LayoutBuilder` + `ConstrainedBox(minHeight: constraints.maxHeight)` + `MainAxisAlignment.center`
- `SingleChildScrollView` za keyboard safety
- Horizontal padding: 28
- Sadržaj se vertikalno centrira na većim ekranima, scrollabilno na manjim

### 6.2 Standardni Content Screen

- `SafeArea` wrapping body
- `SingleChildScrollView` ili `ListView` za scrollabilni sadržaj
- Padding: 16 horizontal

### 6.3 Screen s tabovima (npr. Orders)

- Custom tab toggle (NE Material TabBar)
- Ispod tabova: odgovarajuća lista ili empty state

### 6.4 Empty State

- Centered icon (size 80, secondary color withAlpha(100))
- Heading (headlineMedium)
- Subtitle (bodyLarge, secondary text)
- CTA button ispod

---

## 7. Spacing Konvencije

| Razmak | Koristi se za                                       |
| ------ | --------------------------------------------------- |
| 8      | Između title i subtitle                             |
| 12     | Između password fielda i forgot password            |
| 16     | Između input fieldova, između kartica, chip spacing |
| 20     | Iznad CTA gumba                                     |
| 24     | Između sekcija (logo→title, divider→social buttons) |
| 32     | Veći razmak (social→toggle, toggle→language picker) |
| 40     | Između subtitle i prvog input fielda                |

---

## 8. Ikone

- Stil: **Outlined** (Material Icons) — `Icons.xxx_outlined`
- Bottom nav veličina: 28
- Input prefix veličina: default (24)
- Boja: teal za input ikone, tema za ostalo

---

## 9. SVG Asseti

Svi SVG-ovi u `assets/images/`:

- `h_logo.svg` — Helpi H logo
- `logo.svg` — Full Helpi logo
- `google_logo.svg` — Google 4-color G
- `apple_logo.svg` — Apple jabuka (crna)
- `facebook_logo.svg` — Facebook F (plavi #1877F2)
- Servisne ikone: `shopping.svg`, `home_help.svg`, `companionship.svg`, `walk.svg`, `escort.svg`, `other.svg`

---

## 10. Animacije & Interakcije

- `HapticFeedback.selectionClick()` na bottom nav tap i key actions
- Nema custom animacija — sve standardni Flutter transitions
- `GestureDetector` za social buttone i kartice (tap-to-detail)

---

## 11. Responsive Pattern

- Fiksni paddinging, `double.infinity` za gumbe
- `LayoutBuilder` + `ConstrainedBox` za vertikalno centriranje (login)
- Nema breakpointova — mobile-only app

---

## 12. Dependency-ji

```yaml
flutter_svg: ^2.2.3 # SVG rendering
flutter_localizations: sdk # i18n
```

---

## 13. Brza Referenca: Najčešći Pattern

```dart
// Coral CTA
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFEF5B5B),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
  ),
  child: Text('Action'),
)

// Teal Outlined (veliki full-width)
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: Color(0xFF009D9D),
    side: BorderSide(color: Color(0xFF009D9D), width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  child: Text('Secondary'),
)

// Teal Outlined (mali — Ocijeni)
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: Color(0xFF009D9D),
    side: BorderSide(color: Color(0xFF009D9D)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    minimumSize: Size(0, 30),
    padding: EdgeInsets.symmetric(horizontal: 12),
  ),
  child: Text('Ocijeni', style: TextStyle(fontSize: 12)),
)

// Standardna kartica
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFE0E0E0)),
  ),
  padding: EdgeInsets.all(16),
  child: ...,
)
```
