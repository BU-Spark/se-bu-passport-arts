import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/navigation_page.dart';
import '../pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print(FirebaseAuth.instance.authStateChanges());

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the authentication state
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          // User is authenticated, navigate to the NavigationPage
          return NavigationPage();
        } else {
          // User is not authenticated, show the LoginPage
          return LoginPage();
        }
      },
    );
  }
}
