import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _buIDController = TextEditingController();
  TextEditingController _userSchool = TextEditingController();
  TextEditingController _userYear = TextEditingController();

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.05);
    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(edgeInsets),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: sizedBoxHeight),
              TextField(
                controller: _firstNameController, // Controller for first name
                decoration: const InputDecoration(
                  labelText: 'First Name',
                ),
              ),
              SizedBox(height: sizedBoxHeight),
              TextField(
                controller: _lastNameController, // Controller for last name
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
              SizedBox(height: sizedBoxHeight),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: sizedBoxHeight),
              TextField(
                controller: _buIDController,
                decoration: const InputDecoration(
                  labelText: 'BU ID',
                ),
              ),
              SizedBox(height: sizedBoxHeight),
              TextField(
                controller: _userSchool,
                decoration: const InputDecoration(
                  labelText: 'School',
                ),
              ),
              SizedBox(height: sizedBoxHeight),
              TextField(
                controller: _userYear,
                decoration: const InputDecoration(
                  labelText: 'Year',
                ),
              ),
              SizedBox(height: sizedBoxHeight),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: sizedBoxHeight),
              ElevatedButton(
                onPressed: () async {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  String firstName = _firstNameController.text;
                  String lastName = _lastNameController.text;
                  String buID = _buIDController.text;
                  String school = _userSchool.text;
                  int year = int.parse(_userYear.text);

                  try {
                    final userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    final user = <String, dynamic>{
                      'firstName': firstName,
                      'lastName': lastName,
                      'userEmail': userCredential.user!.email,
                      'userUID': userCredential.user!.uid,
                      'userSchool': school,
                      'userYear': year,
                      'userBUID': buID,
                      'userRegisteredEvents': [],
                      'userPreferences': [],
                    };
                    await db
                        .collection('users')
                        .doc(userCredential.user!.uid)
                        .set(user);
                    Navigator.pushNamed(context, '/home');
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
