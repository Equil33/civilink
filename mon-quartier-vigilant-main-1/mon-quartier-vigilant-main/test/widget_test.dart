import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mon_quartier_vigilant_flutter/app.dart';

void main() {
  testWidgets('App starts on welcome page', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CiviLinkApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Mon Quartier Vigilant'), findsOneWidget);
  });
}
