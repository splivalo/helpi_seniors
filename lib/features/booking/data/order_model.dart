import 'package:flutter/foundation.dart';

/// Status narudžbe.
enum OrderStatus { processing, active, completed }

/// Strukturirani zapis jednog dana u ponavljajućoj narudžbi.
class OrderDayEntry {
  const OrderDayEntry({
    required this.dayName,
    required this.time,
    required this.duration,
  });

  final String dayName; // e.g. "Ponedjeljak"
  final String time; // e.g. "08:00"
  final String duration; // e.g. "1 sat"
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
  });

  final int id;
  final List<String> services;
  final String date; // first occurrence date for recurring
  final String frequency;
  final String notes;
  OrderStatus status;

  // ── One-time fields ──
  final bool isOneTime;
  final String time; // "08:00" for one-time
  final String duration; // "1 sat" for one-time

  // ── Recurring fields ──
  final List<OrderDayEntry> dayEntries;
  final String endDate; // empty if no end date
}

/// In-memory spremnik narudžbi — dijeli se preko InheritedWidget / callback.
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

  /// Simulate an order going from processing → active.
  void activateOrder(int id) {
    final order = _orders.firstWhere((o) => o.id == id);
    order.status = OrderStatus.active;
    notifyListeners();
  }
}
