import 'package:flutter/foundation.dart';

/// Status narudžbe.
enum OrderStatus { processing, active, completed }

/// Status pojedinog posla/termina.
enum JobStatus { completed, upcoming, cancelled }

/// Strukturirani zapis jednog dana u ponavljajućoj narudžbi.
class OrderDayEntry {
  const OrderDayEntry({
    required this.dayName,
    required this.time,
    required this.duration,
    this.weekday = 1,
    this.durationHours = 0,
  });

  final String dayName;
  final String time;
  final String duration;
  final int weekday; // 1=Mon … 7=Sun
  final int durationHours; // numeric hours for price calc
}

/// Jedan konkretan termin (posao) unutar narudžbe.
class JobModel {
  JobModel({
    required this.date,
    required this.weekday,
    required this.time,
    required this.durationHours,
    required this.studentName,
    this.status = JobStatus.upcoming,
    this.review,
  });

  /// Formatted date string "DD.MM.YYYY."
  final String date;
  final int weekday; // 1=Mon … 7=Sun
  final String time;
  final int durationHours;
  final String studentName;
  JobStatus status;
  ReviewModel? review;
}

/// Recenzija studenta od strane seniora.
class ReviewModel {
  ReviewModel({required this.rating, this.comment = '', required this.date});

  final int rating; // 1-5
  final String comment;
  final String date;
}

/// Student dodijeljen narudžbi.
class StudentAssignment {
  StudentAssignment({
    required this.name,
    required this.fromDate,
    this.toDate = '',
  });

  final String name;
  final String fromDate;
  final String toDate;
  final List<ReviewModel> reviews = [];
}

/// Pojednostavljen model narudžbe (mock — bez bacenda).
class OrderModel {
  OrderModel({
    required this.id,
    required this.services,
    required this.date,
    required this.frequency,
    this.status = OrderStatus.processing,
    this.notes = '',
    this.isOneTime = true,
    this.time = '',
    this.duration = '',
    this.dayEntries = const [],
    this.endDate = '',
    this.weekday = 1,
    this.durationHours = 0,
    List<StudentAssignment>? students,
    List<JobModel>? jobs,
  }) : students = students ?? [],
       jobs = jobs ?? [];

  final int id;
  final List<String> services;
  final String date;
  final String frequency;
  final String notes;
  OrderStatus status;

  final bool isOneTime;
  final String time;
  final String duration;

  final List<OrderDayEntry> dayEntries;
  final String endDate;

  /// For one-time orders: weekday (1=Mon…7=Sun) and numeric hours.
  final int weekday;
  final int durationHours;

  /// Studenti dodijeljeni ovoj narudžbi.
  final List<StudentAssignment> students;

  /// Konkretni termini (poslovi) generirani iz rasporeda.
  final List<JobModel> jobs;
}

/// Mock imena studenata za prototype.
const _mockStudentNames = ['Ana M.', 'Marko K.', 'Ivana P.', 'Luka S.'];
int _mockNameIndex = 0;

/// In-memory spremnik narudžbi.
class OrdersNotifier extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  List<OrderModel> get processing =>
      _orders.where((o) => o.status == OrderStatus.processing).toList();

  List<OrderModel> get active =>
      _orders.where((o) => o.status == OrderStatus.active).toList();

  List<OrderModel> get completed =>
      _orders.where((o) => o.status == OrderStatus.completed).toList();

  int _nextId = 1;

  void addOrder(OrderModel order) {
    // Prototype: set to active and assign a mock student
    order.status = OrderStatus.active;
    final studentName =
        _mockStudentNames[_mockNameIndex % _mockStudentNames.length];
    _mockNameIndex++;
    if (order.students.isEmpty) {
      order.students.add(
        StudentAssignment(name: studentName, fromDate: order.date),
      );
    }

    // Generate concrete job dates
    _generateJobs(order, studentName);

    _orders.insert(0, order);
    _nextId++;
    notifyListeners();
  }

  /// Generate concrete job occurrences from order schedule.
  void _generateJobs(OrderModel order, String studentName) {
    if (order.isOneTime) {
      order.jobs.add(
        JobModel(
          date: order.date,
          weekday: order.weekday,
          time: order.time,
          durationHours: order.durationHours,
          studentName: studentName,
          status: JobStatus.upcoming,
        ),
      );
      return;
    }

    // Recurring: parse start/end, generate occurrences
    final start = _parseDate(order.date);
    if (start == null) return;

    final end = order.endDate.isNotEmpty ? _parseDate(order.endDate) : null;
    final limit = end ?? start.add(const Duration(days: 60));

    final jobs = <JobModel>[];
    for (final entry in order.dayEntries) {
      var current = _firstOccurrence(entry.weekday, start);
      while (!current.isAfter(limit)) {
        jobs.add(
          JobModel(
            date: _fmtDate(current),
            weekday: entry.weekday,
            time: entry.time,
            durationHours: entry.durationHours,
            studentName: studentName,
            status: JobStatus.upcoming,
          ),
        );
        current = current.add(const Duration(days: 7));
      }
    }

    // Sort chronologically
    jobs.sort((a, b) => a.date.compareTo(b.date));

    // Mock: mark first 3 as completed
    for (var i = 0; i < jobs.length && i < 3; i++) {
      jobs[i].status = JobStatus.completed;
    }

    order.jobs.addAll(jobs);
  }

  // ── Date helpers ──
  static DateTime? _parseDate(String s) {
    final parts = s.replaceAll('.', '/').split('/');
    if (parts.length < 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  static String _fmtDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  static DateTime _firstOccurrence(int weekday, DateTime from) {
    final diff = (weekday - from.weekday + 7) % 7;
    return from.add(Duration(days: diff));
  }

  int get nextId => _nextId;

  void cancelOrder(int id) {
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  void completeOrder(int id) {
    final order = _orders.firstWhere((o) => o.id == id);
    order.status = OrderStatus.completed;
    notifyListeners();
  }

  /// Add a review for a student on an order.
  void addReview(int orderId, int studentIndex, ReviewModel review) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    order.students[studentIndex].reviews.add(review);
    notifyListeners();
  }

  /// Cancel a specific job (termin) within an order.
  void cancelJob(int orderId, int jobIndex) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    if (jobIndex >= 0 && jobIndex < order.jobs.length) {
      order.jobs[jobIndex].status = JobStatus.cancelled;
      notifyListeners();
    }
  }

  /// Add a review to a specific job.
  void addJobReview(int orderId, int jobIndex, ReviewModel review) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    if (jobIndex >= 0 && jobIndex < order.jobs.length) {
      order.jobs[jobIndex].review = review;
      notifyListeners();
    }
  }
}
