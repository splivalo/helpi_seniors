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
          bookedHours: [17],
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
          bookedHours: [16, 18],
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
          bookedHours: [10, 11],
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
          bookedHours: [9],
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

enum ServiceType {
  activities,
  shopping,
  household,
  companionship,
  techHelp,
  pets,
}
