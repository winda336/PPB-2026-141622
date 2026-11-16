import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_lost_found/screens/login_page.dart';

void main() {
  testWidgets('Halaman login menampilkan form dengan benar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Campus Lost & Found'), findsOneWidget);

    expect(find.byType(TextFormField), findsNWidgets(2));

    expect(find.widgetWithText(FilledButton, 'Masuk'), findsOneWidget);

    expect(find.text('Belum punya akun? Daftar'), findsOneWidget);
  });
}
