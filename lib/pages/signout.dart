import 'package:flutter/material.dart';
import 'package:gcisl_app/main.dart';
import 'package:gcisl_app/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gcisl_app/palette.dart';

class SignOut extends StatelessWidget {
  const SignOut({super.key});

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    _signOut();
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
              //Wecolme Back
              Text(
                'You have been Signed Out',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ]))));
  }
}
