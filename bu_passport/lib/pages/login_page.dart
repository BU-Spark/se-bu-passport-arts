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
  static bool BUemail = true;

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
      final GoogleSignIn googleSignIn = GoogleSignIn(
        hostedDomain: 'bu.edu',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
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
        if (user.email != null && !user.email!.contains("bu.edu")) {
          BUemail = false;
          await user.delete();
          setState(() {
            _errorMessage = 'Please sign in with a BU email address.';
          });
          return null;
        } else {
          BUemail = true;
        }
        // Check if the user document exists in Firestore
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        
        if (!docSnapshot.exists) {
          // Create a new user document
          await userDoc.set({
            'userUID': user.uid,
            'userEmail': user.email,
            'firstName': userCredential.additionalUserInfo?.profile?['given_name'],
            'lastName': userCredential.additionalUserInfo?.profile?['family_name'],
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
      } else {
        setState(() {
          _errorMessage = 'Sign in failed. Please sign in with a BU email address.';
        });
        return null;
      }

      return user;
    } catch (e) {
      if (_errorMessage != null) {
        setState(() {
          _errorMessage = 'Please sign in with a BU email address. Error: $e';
        });
      } else if (mounted) {
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
              SizedBox(height: sizedBoxHeight),
              GestureDetector(
                onTap: () async {
                  User? user = await _signInWithGoogle();
                  if (user != null) {
                    if (newUser) {
                      debugPrint("navigate to signup");
                      _navigateToSignUp();
                    } else {
                      debugPrint("navigate to home");
                      _navigateToHome();
                    }
                  }
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
                      'Sign In with BU Gmail',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: sizedBoxHeight),
              if (_errorMessage != null || !BUemail)
                Text(
                  'Please sign in with a BU email address.',
                  style: const TextStyle(color: Color(0xFFCC0000)),
                ),
              SizedBox(height: sizedBoxHeight),
            ],
          ),
        ),
      ),
    );
  }
}