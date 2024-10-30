import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _userBUIDController = TextEditingController();
  final _userSchoolController = TextEditingController();
  final _userYearController = TextEditingController();

  Future<void> _saveUserInfo() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDoc.update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'userBUID': _userBUIDController.text,
          'userSchool': _userSchoolController.text,
          'userYear': int.parse(_userYearController.text),
        });
        Navigator.pushNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile',
          style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14.93,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14.93,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _userBUIDController,
                decoration: InputDecoration(labelText: 'BUID'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14.93,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your BUID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _userSchoolController,
                decoration: InputDecoration(labelText: 'School'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14.93,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your school';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _userYearController,
                decoration: InputDecoration(labelText: 'Year'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14.93,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your year';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC0000),
                  textStyle: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 22.32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: _saveUserInfo,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}