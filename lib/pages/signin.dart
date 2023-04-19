// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/main.dart';
import 'package:gcisl_app/palette.dart';

class SignInPage extends StatefulWidget {
  final VoidCallback showRegisterpage;
  const SignInPage({Key? key, required this.showRegisterpage})
      : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailControllor = TextEditingController();
  final _passwordControllor = TextEditingController();

  _login() async {
    try {
      UserCredential uID = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailControllor.text, password: _passwordControllor.text);

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => MyApp()));
    } on FirebaseAuthException catch (e) {
      var message = '';
      switch (e.code) {
        case 'invalid-email':
          message = "Invalid email";
          break;
        case 'user-diabled':
          message = "Invalid user";
          break;
        case 'user-not-found':
          message = "no account with this email";
          break;
        case 'wrong-password':
          message = "Wrong password";
          break;
      }

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(message),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Wecolme Back
                Text(
                  'Sign in',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),

                //Email textfield
                SizedBox(height: 50),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _emailControllor,
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                        hoverColor: Colors.black,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ),
                //Password textfield
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        _login();
                      },
                      controller: _passwordControllor,
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),

                //sign in button
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.ktoCrimson,
                      minimumSize: const Size(0, 65),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () {
                      _login();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => MyHomePage(title : 'Cobb Connect')),
                      // );
                    },
                    child: Center(
                        child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    )),
                  ),
                ),

                //Not a memeber? Register
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a user? ',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                        onPressed: widget.showRegisterpage,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, elevation: 0),
                        child: Text(
                          'Register Now',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ))
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
