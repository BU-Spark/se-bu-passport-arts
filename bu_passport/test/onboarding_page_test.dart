import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bu_passport/pages/onboarding_page.dart'; 

void main() {
  group('OnboardingPage Tests', () {
    testWidgets('displays the initial page correctly', (WidgetTester tester) async {
      // Pump the OnboardingPage widget
      await tester.pumpWidget(MaterialApp(home: OnboardingPage()));

      // Verify that the first page's title and description are displayed
      expect(find.text('Attend events'), findsOneWidget);
      expect(find.text("When you attend an event, make sure to check in with our app! A pop-up will appear with the options to check-in with a photo for 25 points, check-in without a photo for 20 points, or to let us know you are not attending."), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('swipes to the next page', (WidgetTester tester) async {
      // Pump the widget
      await tester.pumpWidget(MaterialApp(home: OnboardingPage()));

      // Swipe left to navigate to the next page
      await tester.drag(find.byType(PageView), const Offset(-400.0, 0.0));
      await tester.pumpAndSettle();

    });

    testWidgets('navigates to login when completed', (WidgetTester tester) async {
      // Pump the widget with a Navigator to catch route navigation
      await tester.pumpWidget(MaterialApp(
        home: OnboardingPage(),
        onGenerateRoute: (settings) {
          if (settings.name == '/login') {
            return MaterialPageRoute(builder: (context) => Scaffold(body: Text('Login Page')));
          }
          return null;
        },
      ));

      // Navigate through all pages
      for (int i = 0; i < 4; i++) {
        await tester.drag(find.byType(PageView), const Offset(-400.0, 0.0));
        await tester.pumpAndSettle();
      }

      // Tap 'Next' which should now navigate to login
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

    });

    testWidgets('skip button goes directly to login', (WidgetTester tester) async {
      // Pump the widget
      await tester.pumpWidget(MaterialApp(
        home: OnboardingPage(),
        onGenerateRoute: (settings) {
          if (settings.name == '/login') {
            return MaterialPageRoute(builder: (context) => Scaffold(body: Text('Login Page')));
          }
          return null;
        },
      ));

      // Tap 'Skip'
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Verify that navigation to login page was triggered
      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
