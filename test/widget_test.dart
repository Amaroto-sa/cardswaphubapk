import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding screen shows up', (WidgetTester tester) async {
    // Wrap in MaterialApp + Scaffold + SafeArea + SingleChildScrollView
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SafeArea(
              child: const OnboardingScreen(),
            ),
          ),
        ),
      ),
    );

    // Wait for any async build operations
    await tester.pumpAndSettle();

    // Verify the onboarding screen is displayed
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
