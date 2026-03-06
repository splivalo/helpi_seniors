/// Centralizirane cijene za Helpi Senior app.
///
/// Zamjenjuje hardkodirane _hourlyRate / _sundayRate iz order_flow_screen.dart
/// i order_detail_screen.dart.
class AppPricing {
  AppPricing._();

  static const int hourlyRate = 14; // €/h standard
  static const int sundayRate = 16; // €/h Sunday

  /// Cijena za [hours] sati na [weekday] (1=Mon…7=Sun).
  static int priceForDay(int weekday, int hours) {
    final rate = weekday == DateTime.sunday ? sundayRate : hourlyRate;
    return rate * hours;
  }

  /// Format: "14,00 €"
  static String formatPrice(int euros) => '$euros,00 €';
}
