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

  // Subject to change schools and years

  final List<String> schools = <String>[
    'CAS',
    'COM',
    'CFA',
    'CEIT',
    'COS',
    'COE',
    'COB',
    'CBA',
    'CON',
    'CIT',
    'COT',
    'COP'
  ];
  final List<String> years = <String>['1', '2', '3', '4', '5'];

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _firstNameController, // Controller for first name
                decoration: const InputDecoration(
                  labelText: 'First Name',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _lastNameController, // Controller for last name
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _buIDController,
                decoration: const InputDecoration(
                  labelText: 'BU ID',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _userSchool,
                decoration: const InputDecoration(
                  labelText: 'School',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _userYear,
                decoration: const InputDecoration(
                  labelText: 'Year',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
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
