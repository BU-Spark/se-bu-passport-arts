import 'package:bu_passport/firebase_options.dart';
import 'package:bu_passport/pages/explore_page.dart';
import 'package:bu_passport/pages/login_page.dart';
import 'package:bu_passport/pages/profile_page.dart';
import 'package:bu_passport/pages/signup_page.dart';
import 'package:bu_passport/pages/onboarding_page.dart';
import 'package:bu_passport/pages/passport_page.dart';
import 'package:bu_passport/classes/passport_model.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth_gate.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Timezone initialization for check in
  tz.initializeTimeZones();
  var estLocation = tz.getLocation('America/New_York');
  // Setting local location to EST (since all BU events are in EST)
  tz.setLocalLocation(estLocation);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PassportModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFFCC0000),
            brightness: Brightness.light,
          ),
        ),
        home: const AuthGate(),
        routes: {
          '/onboarding': (context) => const OnboardingPage(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/home': (context) => const AuthGate(),
          '/explore_page': (context) => const ExplorePage(),
          '/passport_page': (context) => const PassportPage(),
          '/profile_page': (context) => const ProfilePage(),
        },
      ),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,

//         // Define the default brightness and colors.
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Color(0xFFCC0000),
//           brightness: Brightness.light,
//         ),
//       ),
//       home: const AuthGate(),
//       routes: {
//         '/onboarding': (context) => const OnboardingPage(),
//         '/login': (context) => const LoginPage(),
//         '/signup': (context) => const SignUpPage(),
//         '/home': (context) => const AuthGate(),
//         '/explore_page': (context) => const ExplorePage(),
//         '/profile_page': (context) => const ProfilePage(),
//       },
//     );
//   }
// }