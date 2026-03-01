import 'package:flutter/foundation.dart';

/// Status narudžbe.
enum OrderStatus { processing, active, completed }

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
  }) : students = students ?? [];

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
    if (order.students.isEmpty) {
      final name = _mockStudentNames[_mockNameIndex % _mockStudentNames.length];
      _mockNameIndex++;
      order.students.add(StudentAssignment(name: name, fromDate: order.date));
    }
    _orders.insert(0, order);
    _nextId++;
    notifyListeners();
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
}
