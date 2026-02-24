// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:helpi_senior/app/app.dart';
import 'package:helpi_senior/core/l10n/app_strings.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HelpiApp());

    // Verify bottom navigation is displayed.
    expect(find.text(AppStrings.navHome), findsWidgets);
    expect(find.text(AppStrings.navStudents), findsOneWidget);
    expect(find.text(AppStrings.navMessages), findsOneWidget);
    expect(find.text(AppStrings.navProfile), findsOneWidget);
  });
}
