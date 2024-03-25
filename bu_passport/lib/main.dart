import 'package:bu_passport/firebase_options.dart';
import 'package:bu_passport/pages/navigation_page.dart';
import 'package:bu_passport/pages/login_page.dart';
import 'package:bu_passport/pages/calendar_page.dart';
import 'package:bu_passport/pages/profile_page.dart';
import 'package:bu_passport/pages/signup_page.dart';
import 'package:bu_passport/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const AuthGate(),
      routes: {
        '/onboarding' : (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
