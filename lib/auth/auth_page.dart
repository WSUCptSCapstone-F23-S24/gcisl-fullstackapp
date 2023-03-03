import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/pages/register.dart';
import 'package:gcisl_app/pages/signin.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLoggedIn = true;
  bool isSignedIn = true;
  String title = "Cobb Connect";

  void toggleScreens() {
    setState(() {
      isLoggedIn = !isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return SignInPage(showRegisterpage: toggleScreens);
    } else {
      return RegisterPage(showSignInPage: toggleScreens);
    }
  }
}
