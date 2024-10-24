import 'package:bu_passport/pages/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _errorMessage;
  static bool newUser = false;

  // Navigate to the signup page
  void _navigateToSignUp() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignUpPage(),
        ),
      );
    }
  }

  // Navigate to the home page
  void _navigateToHome() {
    if (mounted) {
      Navigator.pushNamed(context, '/home');
    }
  }

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
      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user document exists in Firestore
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        
        if (!docSnapshot.exists) {
          // Create a new user document
          final name = user.displayName?.split(' ') ?? [];
          await userDoc.set({
            'userUID': user.uid,
            'userEmail': user.email,
            'firstName': name.isNotEmpty ? name[0] : '',
            'lastName': name.length > 1 ? name[1] : '',
            'userProfileURL': user.photoURL,
            'userPoints': 0,
            'userSavedEvents': {},
            // Additional fields to be filled by the user
            'userBUID': '',
            'userSchool': '',
            'userYear': 0,
            'admin': false,
          });
          // Set newUser flag
          newUser = true;
        } else {
          // Check if additional fields are set
          final data = docSnapshot.data();
          if (data != null && (data['userBUID'] == '' || data['userSchool'] == '' || data['userYear'] == 0)) {
            newUser = true;
          }
        }
      }

      return user;
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google Sign-In failed. Please try again. Error: $e';
        });
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  style: const TextStyle(color: Color(0xFFCC0000)),
                ),
              SizedBox(height: sizedBoxHeight),
              GestureDetector(
                onTap: () async {
                  User? user = await _signInWithGoogle();
                  if(user != null) {
                    if (newUser) {
                      _navigateToSignUp();
                    } else {
                      _navigateToHome();
                    }
                  };
                },
                child: Container(
                  width: 244.14,
                  height: 43.89,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC0000),
                    borderRadius: BorderRadius.circular(66.75),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign In with Google',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: sizedBoxHeight),
            ],
          ),
        ),
      ),
    );
  }
}