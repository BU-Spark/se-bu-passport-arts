import 'package:bu_passport/pages/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _errorMessage;

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-In failed. Please try again.';
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.05);
    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(edgeInsets),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/onboarding/BU art logo.png",
                fit: BoxFit.contain,
              ),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: sizedBoxHeight),
              ElevatedButton(
                onPressed: () async {
                  User? user = await _signInWithGoogle();
                  if (user != null) {
                    Navigator.pushNamed(context, '/home');
                  }
                },
                child: const Text('Sign In with Google'),
              ),
              SizedBox(height: sizedBoxHeight),
            ],
          ),
        ),
      ),
    );
  }
}