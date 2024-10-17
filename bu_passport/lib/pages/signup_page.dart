import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// SignUpPage allows new users to create an account.
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

// State class for SignUpPage handling user sign-up logic.
class _SignUpPageState extends State<SignUpPage> {
  // Text controllers to manage the input fields for user registration.
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _buIDController = TextEditingController();
  TextEditingController _userSchool = TextEditingController();
  TextEditingController _userYear = TextEditingController();

  final db = FirebaseFirestore.instance; // Firestore instance for data storage.

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Variables for consistent spacing and padding in the UI.
    double sizedBoxHeight = screenHeight * 0.02;
    double edgeInsets = screenWidth * 0.02;

    return Scaffold(
      appBar: AppBar(), // Simple AppBar for the layout.
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(edgeInsets),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: sizedBoxHeight),
                // Input field for first name.
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                // Input field for last name.
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                // Input field for email.
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                // Input field for university ID.
                TextField(
                  controller: _buIDController,
                  decoration: const InputDecoration(
                    labelText: 'BU ID',
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                // Input field for the school within the university.
                TextField(
                  controller: _userSchool,
                  decoration: const InputDecoration(
                    labelText: 'School',
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                // Input field for the year in school.
                TextField(
                  controller: _userYear,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                // Input field for password, obscured for security.
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: sizedBoxHeight),
                // Button to submit the sign-up form.
                ElevatedButton(
                  onPressed: () async {
                    String email = _emailController.text;
                    String password = _passwordController.text;
                    String firstName = _firstNameController.text;
                    String lastName = _lastNameController.text;
                    String buID = _buIDController.text;
                    String school = _userSchool.text;
                    String year_text = _userYear.text.trim();

                    // Check if any of the fields are empty.
                    if (email.isEmpty ||
                        password.isEmpty ||
                        firstName.isEmpty ||
                        lastName.isEmpty ||
                        buID.isEmpty ||
                        school.isEmpty ||
                        year_text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill out all fields.')),
                      );
                      return;
                    }
                    int year = int.parse(year_text);

                    try {
                      // Firebase Auth call to create a new user with email and password.
                      final userCredential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      // Preparing user data for Firestore.
                      final user = <String, dynamic>{
                        'firstName': firstName,
                        'lastName': lastName,
                        'userEmail': userCredential.user!.email,
                        'userUID': userCredential.user!.uid,
                        'userSchool': school,
                        'userYear': year,
                        'userBUID': buID,
                        'userPoints': 0,
                        'userProfileURL': '',
                        'userSavedEvents': Map<String, bool>(),
                      };
                      // Saving user data to Firestore.
                      await db
                          .collection('users')
                          .doc(userCredential.user!.uid)
                          .set(user);
                      Navigator.pushNamed(context, '/onboarding');
                    } catch (e) {
                      if (e is FirebaseAuthException) {
                        if (e.code == 'weak-password') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('The password provided is too weak.')),
                          );
                        } else if (e.code == 'email-already-in-use') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'The account already exists for that email.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Error: ${e.message ?? 'An unknown error occurred.'}')),
                          );
                        }
                      } else {
                        // Handle other types of exceptions
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
