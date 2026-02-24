/// Gemini Hybrid i18n — centralizirani stringovi za Helpi Senior.
///
/// Svaki tekst koji se prikazuje korisniku MORA ići kroz ovu klasu.
/// Backend šalje labelKey/placeholderKey, Flutter mapira na AppStrings getters.
class AppStrings {
  AppStrings._();

  // ─── Trenutni jezik ─────────────────────────────────────────────
  static String _currentLocale = 'hr';

  static String get currentLocale => _currentLocale;

  static void setLocale(String locale) {
    if (_localizedValues.containsKey(locale)) {
      _currentLocale = locale;
    }
  }

  // ─── Lokalizirane vrijednosti ───────────────────────────────────
  static final Map<String, Map<String, String>> _localizedValues = {
    'hr': {
      // ── App ───────────────────────────────────
      'appName': 'Helpi',
      'appTagline': 'Pomoć na dlanu',

      // ── Navigacija ────────────────────────────
      'navHome': 'Početna',
      'navStudents': 'Studenti',
      'navMessages': 'Poruke',
      'navProfile': 'Profil',

      // ── Općenito ──────────────────────────────
      'loading': 'Učitavanje...',
      'error': 'Greška',
      'retry': 'Pokušaj ponovo',
      'cancel': 'Odustani',
      'confirm': 'Potvrdi',
      'save': 'Spremi',
      'back': 'Natrag',
      'next': 'Dalje',
      'close': 'Zatvori',
      'search': 'Pretraži',
      'noResults': 'Nema rezultata',
      'ok': 'U redu',

      // ── Auth ──────────────────────────────────
      'login': 'Prijava',
      'register': 'Registracija',
      'email': 'E-mail adresa',
      'password': 'Lozinka',
      'forgotPassword': 'Zaboravljena lozinka?',
      'loginButton': 'Prijavi se',
      'registerButton': 'Registriraj se',
      'noAccount': 'Nemate račun?',
      'hasAccount': 'Već imate račun?',
      'firstName': 'Ime',
      'lastName': 'Prezime',
      'phone': 'Broj telefona',

      // ── Marketplace ───────────────────────────
      'marketplace': 'Studenti',
      'filterTitle': 'Filtriraj',
      'filterService': 'Vrsta usluge',
      'filterDate': 'Datum',
      'filterDay': 'Slobodan dan',
      'filterAnyDay': 'Bilo koji dan',
      'filterApply': 'Primijeni filtre',
      'filterClear': 'Očisti filtre',
      'perHour': '/sat',
      'reviews': 'Recenzija',
      'available': 'Dostupan',
      'unavailable': 'Nedostupan',

      // ── Vrste usluga ─────────────────────────
      'serviceActivities': 'Aktivnosti',
      'serviceShopping': 'Kupovina',
      'serviceHousehold': 'Kućanstvo',
      'serviceCompanionship': 'Pratnja',
      'serviceTechHelp': 'Tehnologija',
      'servicePets': 'Ljubimci',

      // ── Time picker ──────────────────────────
      'availableWindow': 'Dostupan: {start} – {end}',
      'startTimeLabel': 'Početak',
      'durationLabel': 'Trajanje',
      'hourSingular': 'sat',
      'hourPlural': 'sata',
      'aboutStudent': 'O studentu',

      // ── Ponavljanje ──────────────────────────
      'oneTime': 'Jednokratno',
      'recurring': 'Ponavljajuće',
      'selectDays': 'Odaberite dane',
      'noEndDate': 'Bez kraja',
      'selectEndDate': 'Odaberi datum',
      'untilDate': 'Do {date}',
      'everyWeek': 'Svaki',
      'dayMon': 'Pon',
      'dayTue': 'Uto',
      'dayWed': 'Sri',
      'dayThu': 'Čet',
      'dayFri': 'Pet',
      'daySat': 'Sub',
      'daySun': 'Ned',
      'dayMonShort': 'Po',
      'dayTueShort': 'Ut',
      'dayWedShort': 'Sr',
      'dayThuShort': 'Če',
      'dayFriShort': 'Pe',
      'daySatShort': 'Su',
      'daySunShort': 'Ne',
      'perSession': '/termin',
      'recurringLabel': '{days} — {end}',
      'configureAllDays': 'Odaberite vrijeme za sve dane',
      'notConfigured': 'Nije postavljeno',

      // ── Booking ───────────────────────────────
      'availability': 'Dostupnost',
      'booking': 'Narudžba',
      'selectSlot': 'Odaberi termin',
      'orderSummary': 'Pregled narudžbe',
      'placeOrder': 'Naruči',
      'orderConfirmed': 'Narudžba potvrđena!',
      'orderNotes': 'Napomene (opcionalno)',
      'totalPrice': 'Ukupna cijena',

      // ── Payment ───────────────────────────────
      'payment': 'Plaćanje',
      'payNow': 'Plati sada',
      'paymentSuccess': 'Plaćanje uspješno!',
      'paymentFailed': 'Plaćanje neuspješno',

      // ── Chat ──────────────────────────────────
      'chat': 'Poruke',
      'typeMessage': 'Upiši poruku...',
      'sendMessage': 'Pošalji',
      'noMessages': 'Nema poruka',

      // ── Profil ────────────────────────────────
      'profile': 'Moj profil',
      'editProfile': 'Uredi profil',
      'logout': 'Odjava',
      'settings': 'Postavke',
      'language': 'Jezik',

      // ── Parametrizirani ───────────────────────
      'deleteConfirm': 'Obriši {item}?',
      'distanceKm': '{km} km',
      'pricePerHour': '{price} €/sat',
      'ratingCount': '{count} recenzija',
      'welcomeUser': 'Dobrodošli, {name}!',
      'orderForStudent': 'Narudžba za {student}',
      'slotTime': '{start} - {end}',
    },
    'en': {
      // ── App ───────────────────────────────────
      'appName': 'Helpi',
      'appTagline': 'Help at your fingertips',

      // ── Navigacija ────────────────────────────
      'navHome': 'Home',
      'navStudents': 'Students',
      'navMessages': 'Messages',
      'navProfile': 'Profile',

      // ── Općenito ──────────────────────────────
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Try again',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'back': 'Back',
      'next': 'Next',
      'close': 'Close',
      'search': 'Search',
      'noResults': 'No results',
      'ok': 'OK',

      // ── Auth ──────────────────────────────────
      'login': 'Login',
      'register': 'Register',
      'email': 'Email address',
      'password': 'Password',
      'forgotPassword': 'Forgot password?',
      'loginButton': 'Sign in',
      'registerButton': 'Sign up',
      'noAccount': "Don't have an account?",
      'hasAccount': 'Already have an account?',
      'firstName': 'First name',
      'lastName': 'Last name',
      'phone': 'Phone number',

      // ── Marketplace ───────────────────────────
      'marketplace': 'Students',
      'filterTitle': 'Filter',
      'filterService': 'Service type',
      'filterDate': 'Date',
      'filterDay': 'Available day',
      'filterAnyDay': 'Any day',
      'filterApply': 'Apply filters',
      'filterClear': 'Clear filters',
      'perHour': '/hour',
      'reviews': 'Reviews',
      'available': 'Available',
      'unavailable': 'Unavailable',

      // ── Vrste usluga ─────────────────────────
      'serviceActivities': 'Activities',
      'serviceShopping': 'Shopping',
      'serviceHousehold': 'Household',
      'serviceCompanionship': 'Companionship',
      'serviceTechHelp': 'Technology',
      'servicePets': 'Pets',

      // ── Time picker ──────────────────────────
      'availableWindow': 'Available: {start} – {end}',
      'startTimeLabel': 'Start time',
      'durationLabel': 'Duration',
      'hourSingular': 'hour',
      'hourPlural': 'hours',
      'aboutStudent': 'About student',

      // ── Ponavljanje ──────────────────────────
      'oneTime': 'One-time',
      'recurring': 'Recurring',
      'selectDays': 'Select days',
      'noEndDate': 'No end date',
      'selectEndDate': 'Select date',
      'untilDate': 'Until {date}',
      'everyWeek': 'Every',
      'dayMon': 'Mon',
      'dayTue': 'Tue',
      'dayWed': 'Wed',
      'dayThu': 'Thu',
      'dayFri': 'Fri',
      'daySat': 'Sat',
      'daySun': 'Sun',
      'dayMonShort': 'Mo',
      'dayTueShort': 'Tu',
      'dayWedShort': 'We',
      'dayThuShort': 'Th',
      'dayFriShort': 'Fr',
      'daySatShort': 'Sa',
      'daySunShort': 'Su',
      'perSession': '/session',
      'recurringLabel': '{days} — {end}',
      'configureAllDays': 'Select time for all days',
      'notConfigured': 'Not configured',

      // ── Booking ───────────────────────────────
      'availability': 'Availability',
      'booking': 'Booking',
      'selectSlot': 'Select time slot',
      'orderSummary': 'Order summary',
      'placeOrder': 'Place order',
      'orderConfirmed': 'Order confirmed!',
      'orderNotes': 'Notes (optional)',
      'totalPrice': 'Total price',

      // ── Payment ───────────────────────────────
      'payment': 'Payment',
      'payNow': 'Pay now',
      'paymentSuccess': 'Payment successful!',
      'paymentFailed': 'Payment failed',

      // ── Chat ──────────────────────────────────
      'chat': 'Messages',
      'typeMessage': 'Type a message...',
      'sendMessage': 'Send',
      'noMessages': 'No messages',

      // ── Profil ────────────────────────────────
      'profile': 'My profile',
      'editProfile': 'Edit profile',
      'logout': 'Log out',
      'settings': 'Settings',
      'language': 'Language',

      // ── Parametrizirani ───────────────────────
      'deleteConfirm': 'Delete {item}?',
      'distanceKm': '{km} km',
      'pricePerHour': '€{price}/hour',
      'ratingCount': '{count} Reviews',
      'welcomeUser': 'Welcome, {name}!',
      'orderForStudent': 'Order for {student}',
      'slotTime': '{start} - {end}',
    },
  };

  // ─── Interni getter s parametrima ───────────────────────────────
  static String _t(String key, {Map<String, String>? params}) {
    String value = _localizedValues[_currentLocale]?[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }

  // ═══════════════════════════════════════════════════════════════
  //  STATIC GETTERS — koriste se u UI-ju: AppStrings.appName
  // ═══════════════════════════════════════════════════════════════

  // ── App ───────────────────────────────────────
  static String get appName => _t('appName');
  static String get appTagline => _t('appTagline');

  // ── Navigacija ────────────────────────────────
  static String get navHome => _t('navHome');
  static String get navStudents => _t('navStudents');
  static String get navMessages => _t('navMessages');
  static String get navProfile => _t('navProfile');

  // ── Općenito ──────────────────────────────────
  static String get loading => _t('loading');
  static String get error => _t('error');
  static String get retry => _t('retry');
  static String get cancel => _t('cancel');
  static String get confirm => _t('confirm');
  static String get save => _t('save');
  static String get back => _t('back');
  static String get next => _t('next');
  static String get close => _t('close');
  static String get search => _t('search');
  static String get noResults => _t('noResults');
  static String get ok => _t('ok');

  // ── Auth ──────────────────────────────────────
  static String get login => _t('login');
  static String get register => _t('register');
  static String get email => _t('email');
  static String get password => _t('password');
  static String get forgotPassword => _t('forgotPassword');
  static String get loginButton => _t('loginButton');
  static String get registerButton => _t('registerButton');
  static String get noAccount => _t('noAccount');
  static String get hasAccount => _t('hasAccount');
  static String get firstName => _t('firstName');
  static String get lastName => _t('lastName');
  static String get phone => _t('phone');

  // ── Marketplace ───────────────────────────────
  static String get marketplace => _t('marketplace');
  static String get filterTitle => _t('filterTitle');
  static String get filterService => _t('filterService');
  static String get filterDate => _t('filterDate');
  static String get filterDay => _t('filterDay');
  static String get filterAnyDay => _t('filterAnyDay');
  static String get filterApply => _t('filterApply');
  static String get filterClear => _t('filterClear');
  static String get perHour => _t('perHour');
  static String get reviews => _t('reviews');
  static String get available => _t('available');
  static String get unavailable => _t('unavailable');

  // ── Vrste usluga ─────────────────────────────
  static String get serviceActivities => _t('serviceActivities');
  static String get serviceShopping => _t('serviceShopping');
  static String get serviceHousehold => _t('serviceHousehold');
  static String get serviceCompanionship => _t('serviceCompanionship');
  static String get serviceTechHelp => _t('serviceTechHelp');
  static String get servicePets => _t('servicePets');
  // ── Time picker ──────────────────────────────
  static String availableWindow(String start, String end) =>
      _t('availableWindow', params: {'start': start, 'end': end});
  static String get startTimeLabel => _t('startTimeLabel');
  static String get durationLabel => _t('durationLabel');
  static String get hourSingular => _t('hourSingular');
  static String get hourPlural => _t('hourPlural');
  static String get aboutStudent => _t('aboutStudent');

  // ── Ponavljanje ──────────────────────────────
  static String get oneTime => _t('oneTime');
  static String get recurring => _t('recurring');
  static String get selectDays => _t('selectDays');
  static String get noEndDate => _t('noEndDate');
  static String get selectEndDate => _t('selectEndDate');
  static String untilDate(String date) =>
      _t('untilDate', params: {'date': date});
  static String get everyWeek => _t('everyWeek');
  static String get dayMon => _t('dayMon');
  static String get dayTue => _t('dayTue');
  static String get dayWed => _t('dayWed');
  static String get dayThu => _t('dayThu');
  static String get dayFri => _t('dayFri');
  static String get daySat => _t('daySat');
  static String get daySun => _t('daySun');
  static String get dayMonShort => _t('dayMonShort');
  static String get dayTueShort => _t('dayTueShort');
  static String get dayWedShort => _t('dayWedShort');
  static String get dayThuShort => _t('dayThuShort');
  static String get dayFriShort => _t('dayFriShort');
  static String get daySatShort => _t('daySatShort');
  static String get daySunShort => _t('daySunShort');
  static String get perSession => _t('perSession');
  static String get configureAllDays => _t('configureAllDays');
  static String get notConfigured => _t('notConfigured');
  static String recurringLabel(String days, String end) =>
      _t('recurringLabel', params: {'days': end});

  // ── Booking ───────────────────────────────────
  static String get availability => _t('availability');
  static String get booking => _t('booking');
  static String get selectSlot => _t('selectSlot');
  static String get orderSummary => _t('orderSummary');
  static String get placeOrder => _t('placeOrder');
  static String get orderConfirmed => _t('orderConfirmed');
  static String get orderNotes => _t('orderNotes');
  static String get totalPrice => _t('totalPrice');

  // ── Payment ───────────────────────────────────
  static String get payment => _t('payment');
  static String get payNow => _t('payNow');
  static String get paymentSuccess => _t('paymentSuccess');
  static String get paymentFailed => _t('paymentFailed');

  // ── Chat ──────────────────────────────────────
  static String get chat => _t('chat');
  static String get typeMessage => _t('typeMessage');
  static String get sendMessage => _t('sendMessage');
  static String get noMessages => _t('noMessages');

  // ── Profil ────────────────────────────────────
  static String get profile => _t('profile');
  static String get editProfile => _t('editProfile');
  static String get logout => _t('logout');
  static String get settings => _t('settings');
  static String get language => _t('language');

  // ── Parametrizirani stringovi ─────────────────
  static String deleteConfirm(String item) =>
      _t('deleteConfirm', params: {'item': item});

  static String distanceKm(String km) => _t('distanceKm', params: {'km': km});

  static String pricePerHour(String price) =>
      _t('pricePerHour', params: {'price': price});

  static String ratingCount(String count) =>
      _t('ratingCount', params: {'count': count});

  static String welcomeUser(String name) =>
      _t('welcomeUser', params: {'name': name});

  static String orderForStudent(String student) =>
      _t('orderForStudent', params: {'student': student});

  static String slotTime(String start, String end) =>
      _t('slotTime', params: {'start': start, 'end': end});
}
