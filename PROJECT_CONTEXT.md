# Helpi — Kontekst Projekta

> Ovaj dokument daje novom chatu/agentu KOMPLETAN kontekst o projektu Helpi.
> Pročitaj ga zajedno s DESIGN_SYSTEM.md i imat ćeš sve što ti treba.

> Last updated: 2026-03-02

---

## 1. Što je Helpi?

**Helpi** je platforma koja spaja **starije osobe (seniore)** sa **studentima** koji im pružaju svakodnevnu pomoć.

- Seniori (ili njihovi ukućani) naručuju usluge: kupovina, pomoć u kući, društvo, šetnja, pratnja, ostalo.
- Studenti prihvaćaju narudžbe, dolaze kod seniora, obavljaju uslugu i zarađuju.

**Analogija:** Uber, ali za svakodnevnu pomoć starijima. Uber ima 2 app-e (putnik + vozač), Helpi ima 2 app-e (senior + student).

---

## 2. Arhitektura — 3 Odvojene Aplikacije

### Helpi Senior (gotova)

- **Što radi:** Senior naručuje pomoć
- **Ekrani:** Login → Naruči pomoć → Moje narudžbe (3 taba: U obradi / Aktivne / Završene) → Chat s podrškom → Profil
- **Projekt:** `helpi_senior/`
- **Repo:** `splivalo/helpi_seniors`, branch `main`
- **Ključne funkcije:**
  - 3-step order flow (Kada → Što → Pregled)
  - Order detail s pricing (14€/h, 16€/h ned.), Termini sekcija, per-job ocjene
  - "Ponovi narudžbu" (DatePicker/DateRangePicker) → processing status
  - Jednokratne narudžbe: review inside summary card
  - Ponavljajuće narudžbe: Termini sekcija s per-job cards

### Helpi Student (za napraviti)

- **Što radi:** Student prima i obavlja narudžbe
- **Ekrani (plan):**
  - Login/Register (ISTI dizajn kao senior)
  - Dashboard — lista dolazećih narudžbi za prihvaćanje
  - Moje narudžbe — prihvaćene narudžbe i raspored
  - Chat — komunikacija sa seniorima / podrškom
  - Profil — osobni podaci, zarada, dostupnost, ocjene
- **Isti dizajn sustav:** Boje, border radius, gumbi, kartice, fontovi — SVE isto kao senior app
- **Dijeli assets:** Logo, SVG ikone, social login SVG-ovi

### Helpi Admin (planiran)

- **Što radi:** Admin upravlja narudžbama, dodjeljuje studente, prati plaćanja
- **Platforma:** Desktop + mobile responsive (Flutter web ili zasebni Flutter projekt)
- **Ključne funkcije (plan):**
  - Dashboard s pregledom svih narudžbi (processing/active/completed)
  - Dodjela studenta narudžbi (matching po lokaciji, dostupnosti, ocjenama)
  - Chat moderacija (senior ↔ admin ↔ student)
  - Upravljanje korisnicima (seniori + studenti)
  - Financijski pregled (plaćanja, Stripe)
  - Push notifikacije za nove narudžbe
- **Dijeli:** Isti dizajn sustav (boje, tipografija, border radius), backend API
- **Kontekst:** Čita DESIGN_SYSTEM.md i PROJECT_CONTEXT.md iz oba app-a (senior + student)

---

## 3. Struktura Senior App-a (referenca za student)

```
lib/
├── main.dart                        # Entry point
├── app/
│   ├── app.dart                     # Root widget, auth state, locale
│   ├── main_shell.dart              # BottomNavigationBar (4 taba)
│   └── theme.dart                   # CENTRALIZIRANI theme — SVE boje i stilovi
├── core/
│   ├── l10n/
│   │   ├── app_strings.dart         # i18n (HR + EN) — Gemini Hybrid pattern
│   │   └── locale_notifier.dart     # ValueNotifier<Locale>
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── login_screen.dart    # Login/Register s social auth (SVG circles)
│   ├── order/
│   │   └── presentation/
│   │       ├── order_screen.dart    # "Naruči pomoć" entry point
│   │       └── order_flow_screen.dart # 3-step wizard (Kada → Što → Pregled) ~1454 lines
│   ├── booking/
│   │   ├── data/
│   │   │   └── order_model.dart     # Order/Job/Review models + OrdersNotifier + mock data
│   │   └── presentation/
│   │       ├── orders_screen.dart   # Lista narudžbi (3 taba: U obradi/Aktivne/Završene)
│   │       └── order_detail_screen.dart # Detalji narudžbe + pricing + Termini (job-level) + per-job ocjene
│   ├── chat/
│   │   └── presentation/
│   │       └── chat_list_screen.dart # Chat s Helpi podrškom
│   ├── profile/
│   │   └── presentation/
│   │       └── profile_screen.dart  # Profil s sekcijama
│   ├── payment/
│   └── reviews/
├── shared/
│   └── widgets/
└── di/
```

---

## 4. Ključni Patterini (koristi iste u student app-u)

### 4.1 i18n — Gemini Hybrid Pattern

- **NIKAD** hardkodirati tekst u widgete
- Sve ide kroz `AppStrings` klasu
- `_localizedValues` mapa s HR i EN
- Static getteri: `static String get loginTitle => _t('loginTitle');`
- Parametrizirani: `static String orderNumber(String number) => _t('orderNumber', params: {'number': number});`

### 4.2 Auth Flow (mock)

```
LoginScreen (onLoginSuccess callback)
    ↓ klik Login/Register
_isLoggedIn = true → MainShell prikazan
    ↓ klik Logout u profilu
_isLoggedIn = false → LoginScreen prikazan
```

- Nema prave autentikacije — sve je UI prototip
- Social buttoni (Google, Apple, Facebook) svi zovu `onLoginSuccess`

### 4.3 Locale Management

```
LocaleNotifier (ValueNotifier<Locale>)
    ↓ setLocale('HR' ili 'EN')
AppStrings.setLocale(locale)
    ↓
ValueListenableBuilder na MaterialApp rebuilda UI
```

### 4.4 Navigacija

- `MainShell` — `IndexedStack` + `BottomNavigationBar`
- 4 taba: Naruči | Narudžbe | Poruke | Profil
- Student app će imati drugačije tabove, ali ISTI pattern

### 4.5 State Management

- `ValueNotifier` + `ValueListenableBuilder` (lokale, narudžbe)
- `setState` za lokalni UI state
- Nema Riverpod/Bloc/Provider — jednostavno i čisto

### 4.6 Async Safety

- Obavezan `if (!context.mounted) return;` nakon svakog `await` u UI sloju

---

## 5. Student App — Razlike od Senior-a

| Aspekt           | Senior                             | Student                                              |
| ---------------- | ---------------------------------- | ---------------------------------------------------- |
| **Uloga**        | Naručuje usluge                    | Prima i obavlja narudžbe                             |
| **Tab 1**        | "Naruči" (wizard za novu narudžbu) | "Dashboard" (lista novih narudžbi za prihvaćanje)    |
| **Tab 2**        | "Narudžbe" (moje narudžbe, 3 taba) | "Raspored" (prihvaćene narudžbe, kalendar)           |
| **Tab 3**        | "Poruke" (chat s podrškom)         | "Poruke" (chat sa seniorima + podrška)               |
| **Tab 4**        | "Profil" (osobni podaci, kartice)  | "Profil" (osobni podaci, zarada, dostupnost, ocjene) |
| **Order flow**   | Kreira narudžbu                    | Prihvaća/odbija narudžbu                             |
| **Ocjenjivanje** | Ocjenjuje studente                 | Prima ocjene od seniora                              |
| **Plaćanje**     | Plaća za uslugu                    | Prima uplatu za uslugu                               |

---

## 6. Usluge koje Helpi nudi

| Ključ                      | HR           | EN        |
| -------------------------- | ------------ | --------- |
| `bookingChipShopping`      | Kupovina     | Errands   |
| `bookingChipCleaning`      | Pomoć u kući | Home help |
| `bookingChipCompanionship` | Društvo      | Company   |
| `bookingChipWalk`          | Šetnja       | Walk      |
| `bookingChipEscort`        | Pratnja      | Escort    |
| `bookingChipOther`         | Ostalo       | Other     |

---

## 7. Mock Data Pattern

Trenutno SVE je mock data — nema backenda.

- `OrdersNotifier` (ValueNotifier) drži listu narudžbi u memoriji
- `_seedMockData()` kreira 3 mock završene narudžbe:
  1. Jednokratna: Čišćenje+Kuhanje, Ana M., 1 completed job
  2. Ponavljajuća bez kraja: Čišćenje, Marko K., frequency="Ponavljajuće", 4 completed jobs
  3. Ponavljajuća s krajem: Kuhanje+Šetnja, Ivana P., frequency="Do 07.02.2026", 4 completed + 1 cancelled job
- `JobModel` drži individualne termine (sesije) s datumom, statusom, ocjenom
- `JobStatus`: `completed`, `upcoming`, `cancelled`
- Ocjenjivanje je na razini **termina** (job), ne narudžbe (order)
- Pricing: 14€/h radnim danima, 16€/h nedjeljom
- Studenti su hardkodirani s imenima i ocjenama
- **Status boje:**
  - Processing/Upcoming: blue `#1976D2` on `#E8F1FB`
  - Active/Completed: green `#4CAF50` on `#E8F5E9`
  - Cancelled: coral `#EF5B5B` on `#FFEBEE`
- **`addProcessingOrder()`**: kreira narudžbu bez studenta i bez termina (processing status)
- **`addOrder()`**: kreira narudžbu sa studentom i generira termine (active status)
- **`completeOrder()`**: za jednokratne također označava job kao completed

Za student app: isti pristup — mock data, bez backenda, čisti UI prototip.

---

## 8. Git & Repo

- **Senior Repo:** `splivalo/helpi_seniors`
- **Student Repo:** `splivalo/helpi_students`
- **Branch:** `main`
- **Commit format:** `feat/fix/refactor: opis (rezultat: X errors → Y errors)`

---

## 9. Kodeks Rada (pravila za agenta)

Ova pravila su u `kodeks rada za fakturist projekt.instructions.md` i MORAJU se poštovati:

1. **Pre-flight check:** `dart analyze` prije i poslije svake izmjene
2. **0 linter issues:** Nikad `// ignore`, nikad `dynamic` bez casta
3. **Nema hardkodiranja teksta:** Sve kroz `AppStrings`
4. **Async safety:** `if (!context.mounted) return;` nakon `await`
5. **Incremental changes:** Jedan fajl po jedan, čekaj potvrdu
6. **Bez tehničkog duga:** Pobriši test skripte nakon korištenja
7. **Manual UI testing:** Napiši upute za testiranje
8. **Verification protocol:** 3-5 koraka za ručnu provjeru
9. **Živa dokumentacija:** Održavaj PROGRESS.md
10. **Roadmap disciplina:** Ne započinji task bez izričite potvrde

---

## 10. Kako Početi Admin App

### Korak 1: Novi Flutter projekt

```bash
flutter create helpi_admin
```

### Korak 2: Kopiraj iz senior app-a

- `theme.dart` → `lib/app/theme.dart` (IDENTIČAN)
- `app_strings.dart` strukturu → ali s admin-specifičnim stringovima
- `locale_notifier.dart` → `lib/core/l10n/`
- SVG assete → `assets/images/` (logo, service ikone)

### Korak 3: Dodaj dependencies

```yaml
flutter_svg: ^2.2.3
flutter_localizations:
  sdk: flutter
```

### Korak 4: Struktura foldera

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── main_shell.dart     # Desktop sidebar / mobile bottom nav
│   └── theme.dart          # Kopija iz seniora
├── core/
│   └── l10n/
│       ├── app_strings.dart
│       └── locale_notifier.dart
├── features/
│   ├── auth/               # Admin login
│   ├── dashboard/          # NOVO — pregled svih narudžbi
│   ├── orders/             # NOVO — upravljanje narudžbama, dodjela studenata
│   ├── users/              # NOVO — pregled seniora i studenata
│   ├── chat/               # Chat moderacija
│   └── finance/            # Stripe plaćanja, pregled zarade
```

### Korak 5: U novom chatu reci

> "Pročitaj DESIGN_SYSTEM.md i PROJECT_CONTEXT.md iz oba projekta (helpi_senior i helpi_student). Radimo admin app za Helpi. Koristi ISTI dizajn sustav. Desktop + mobile responsive. Krećemo s [ekran koji želiš]."
