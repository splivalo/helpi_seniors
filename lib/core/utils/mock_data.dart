/// Mock podaci za UI prototip.
/// Ovo će programer zamijeniti pravim API pozivima.
class MockData {
  MockData._();

  static final List<MockStudent> students = [
    MockStudent(
      id: '5',
      firstName: 'Petra',
      lastName: 'Jurić',
      avatarEmoji: '👩‍🏫',
      imageAsset: 'assets/images/student_4.jpg',
      bio:
          'Studentica pedagogije. Strpljiva i topla osoba. Rado pomažem '
          'oko svakodnevnih stvari i volim slušati priče.',
      rating: 5.0,
      reviewCount: 7,
      hourlyRate: 14.0,
      services: [ServiceType.companionship, ServiceType.techHelp],
      distanceKm: 0.8,
      availableSlots: [
        MockSlot(
          dayLabel: 'Pon',
          date: '03.03.',
          startTime: '16:00',
          endTime: '20:00',
        ),
        MockSlot(
          dayLabel: 'Sri',
          date: '05.03.',
          startTime: '16:00',
          endTime: '20:00',
        ),
        MockSlot(
          dayLabel: 'Čet',
          date: '06.03.',
          startTime: '16:00',
          endTime: '20:00',
        ),
        MockSlot(
          dayLabel: 'Pet',
          date: '07.03.',
          startTime: '16:00',
          endTime: '20:00',
        ),
      ],
    ),
    MockStudent(
      id: '3',
      firstName: 'Maja',
      lastName: 'Horvat',
      avatarEmoji: '👩‍🔬',
      imageAsset: 'assets/images/student_3.jpg',
      bio:
          'Studentica socijalnog rada. Iskustvo u radu s umirovljenicima '
          'kroz volontiranje u domu za starije. Druželjubiva i vesela.',
      rating: 4.9,
      reviewCount: 31,
      hourlyRate: 14.0,
      services: [
        ServiceType.shopping,
        ServiceType.household,
        ServiceType.companionship,
      ],
      distanceKm: 1.5,
      availableSlots: [
        MockSlot(
          dayLabel: 'Pon',
          date: '03.03.',
          startTime: '08:00',
          endTime: '20:00',
        ),
        MockSlot(
          dayLabel: 'Sri',
          date: '05.03.',
          startTime: '14:00',
          endTime: '18:00',
        ),
        MockSlot(
          dayLabel: 'Pet',
          date: '07.03.',
          startTime: '08:00',
          endTime: '12:00',
        ),
      ],
    ),
    MockStudent(
      id: '1',
      firstName: 'Ana',
      lastName: 'Marković',
      avatarEmoji: '👩‍🎓',
      imageAsset: 'assets/images/student_1.jpg',
      bio:
          'Studentica medicine, 3. godina. Volim pomagati starijim osobama '
          'jer me podsjeća na moju baku. Strpljiva sam i uredna.',
      rating: 4.8,
      reviewCount: 23,
      hourlyRate: 14.0,
      services: [ServiceType.techHelp, ServiceType.companionship],
      distanceKm: 2.3,
      availableSlots: [
        MockSlot(
          dayLabel: 'Pon',
          date: '03.03.',
          startTime: '09:00',
          endTime: '13:00',
        ),
        MockSlot(
          dayLabel: 'Sri',
          date: '05.03.',
          startTime: '09:00',
          endTime: '13:00',
        ),
        MockSlot(
          dayLabel: 'Pet',
          date: '07.03.',
          startTime: '14:00',
          endTime: '18:00',
        ),
      ],
    ),
    MockStudent(
      id: '2',
      firstName: 'Ivan',
      lastName: 'Kovačević',
      avatarEmoji: '👨‍🎓',
      imageAsset: 'assets/images/student_2.jpg',
      bio:
          'Student informatike. Pomažem s mobitelima, tabletima, računalima. '
          'Mogu postaviti i WhatsApp i Viber za vas!',
      rating: 4.5,
      reviewCount: 15,
      hourlyRate: 14.0,
      services: [ServiceType.techHelp, ServiceType.activities],
      distanceKm: 3.8,
      availableSlots: [
        MockSlot(
          dayLabel: 'Uto',
          date: '04.03.',
          startTime: '10:00',
          endTime: '14:00',
        ),
        MockSlot(
          dayLabel: 'Čet',
          date: '06.03.',
          startTime: '10:00',
          endTime: '14:00',
        ),
        MockSlot(
          dayLabel: 'Sub',
          date: '08.03.',
          startTime: '09:00',
          endTime: '12:00',
        ),
      ],
    ),
    MockStudent(
      id: '4',
      firstName: 'Luka',
      lastName: 'Babić',
      avatarEmoji: '🧑‍💼',
      bio:
          'Student kineziologije. Jak i spreman za fizičke poslove — '
          'čišćenje, nošenje namirnica, uređenje dvorišta.',
      rating: 4.3,
      reviewCount: 9,
      hourlyRate: 14.0,
      services: [ServiceType.household, ServiceType.shopping, ServiceType.pets],
      distanceKm: 5.1,
      availableSlots: [
        MockSlot(
          dayLabel: 'Uto',
          date: '04.03.',
          startTime: '08:00',
          endTime: '16:00',
        ),
        MockSlot(
          dayLabel: 'Sub',
          date: '08.03.',
          startTime: '08:00',
          endTime: '16:00',
        ),
      ],
    ),
  ];
}

class MockStudent {
  final String id;
  final String firstName;
  final String lastName;
  final String avatarEmoji;
  final String? imageAsset;
  final String bio;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final List<ServiceType> services;
  final double distanceKm;
  final List<MockSlot> availableSlots;

  const MockStudent({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.avatarEmoji,
    this.imageAsset,
    required this.bio,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.services,
    required this.distanceKm,
    required this.availableSlots,
  });

  String get fullName => '$firstName $lastName';

  /// Inicijali (npr. "AM" za Ana Marković).
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  // ── Generiranje dostupnosti po datumima ─────────────────────

  static const _labelToWeekday = {
    'Pon': 1,
    'Uto': 2,
    'Sri': 3,
    'Čet': 4,
    'Pet': 5,
    'Sub': 6,
    'Ned': 7,
  };

  /// Mock bookings per student per date (key: 'month-day').
  static final Map<String, Map<String, List<int>>> _mockBookings = {
    '5': {
      // Petra (Mon/Wed/Thu/Fri 16-20)
      '3-9': [16, 17, 18, 19], // Mon fully booked
      '3-5': [16, 18], // Thu partially
      '3-13': [18, 19], // Fri partially
      '3-18': [16], // Wed partially
    },
    '3': {
      // Maja (Mon 8-20, Wed 14-18, Fri 8-12)
      '3-2': [10, 11], // Mon partially
      '3-6': [9], // Fri partially
      '3-16': [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19], // Mon fully
      '3-18': [14, 15, 16, 17], // Wed fully
    },
  };

  /// Generate concrete date availability for a given month.
  List<MockDateAvailability> getMonthAvailability(int year, int month) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDay = DateTime(year, month + 1, 0);

    // Build weekly pattern from availableSlots
    final patterns = <int, MockSlot>{};
    for (final slot in availableSlots) {
      final wd = _labelToWeekday[slot.dayLabel];
      if (wd != null) patterns[wd] = slot;
    }

    final result = <MockDateAvailability>[];
    for (
      var d = DateTime(year, month, 1);
      !d.isAfter(lastDay);
      d = d.add(const Duration(days: 1))
    ) {
      if (d.isBefore(todayDate)) continue;

      final pattern = patterns[d.weekday];
      if (pattern == null) continue;

      final startH = int.parse(pattern.startTime.split(':')[0]);
      final endH = int.parse(pattern.endTime.split(':')[0]);

      final key = '$month-${d.day}';
      final booked = _mockBookings[id]?[key] ?? <int>[];

      result.add(
        MockDateAvailability(
          date: d,
          startHour: startH,
          endHour: endH,
          bookedHours: booked,
        ),
      );
    }

    return result;
  }
}

class MockSlot {
  final String dayLabel;
  final String date;
  final String startTime;
  final String endTime;

  /// Sati koji su već rezervirani (npr. [16, 17] = 16:00-18:00 zauzeto).
  /// Backend će popuniti; za mock demo stavljamo par primjera.
  final List<int> bookedHours;

  const MockSlot({
    required this.dayLabel,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.bookedHours = const [],
  });

  String get label => '$dayLabel $date  $startTime – $endTime';
}

/// Concrete date availability (generated from weekly pattern + bookings).
class MockDateAvailability {
  final DateTime date;
  final int startHour;
  final int endHour;
  final List<int> bookedHours;

  const MockDateAvailability({
    required this.date,
    required this.startHour,
    required this.endHour,
    this.bookedHours = const [],
  });

  bool get isFullyBooked {
    for (var h = startHour; h < endHour; h++) {
      if (!bookedHours.contains(h)) return false;
    }
    return true;
  }

  bool get isPartiallyBooked => bookedHours.isNotEmpty && !isFullyBooked;

  int get freeHourCount {
    var count = 0;
    for (var h = startHour; h < endHour; h++) {
      if (!bookedHours.contains(h)) count++;
    }
    return count;
  }

  int get totalHours => endHour - startHour;

  static const _weekdayToLabel = {
    1: 'Pon',
    2: 'Uto',
    3: 'Sri',
    4: 'Čet',
    5: 'Pet',
    6: 'Sub',
    7: 'Ned',
  };

  String get dayLabel => _weekdayToLabel[date.weekday] ?? '';

  String get dateFormatted =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.';
}

enum ServiceType {
  activities,
  shopping,
  household,
  companionship,
  techHelp,
  pets,
}
