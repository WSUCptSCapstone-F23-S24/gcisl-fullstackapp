import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/pages/register.dart';
import 'package:gcisl_app/pages/signin.dart';
import 'package:gcisl_app/pages/resetpasswd.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLoggedIn = true;
  bool isSignedIn = true;
  bool isResetPassword = false;
  String title = "Cobb Connect";

  void toggleScreens() {
    setState(() {
      isResetPassword = false;
      isLoggedIn = !isLoggedIn;
    });
  }

  void toggleReset()
  {
    setState(() {
      isResetPassword = true;
    });
  }

  void returnToLogin() {
    print("HERE");
    setState(() {
      isLoggedIn = true;
      isResetPassword = false;

    });
  }

  @override
  Widget build(BuildContext context) {
    if(isResetPassword)
      return ResetPasswordPage(showLoginPage: returnToLogin);
    if (isLoggedIn) {
      return SignInPage(showRegisterpage: toggleScreens, showForgotPassword : toggleReset);
    } else {
      return RegisterPage(showSignInPage: toggleScreens);
    }
  }
}
