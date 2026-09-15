import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:test_app/features/auth/auth_screen.dart';

void main() {
  testWidgets('auth screen shows sign-in controls', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Need an account? Sign up'), findsOneWidget);
  });
}
