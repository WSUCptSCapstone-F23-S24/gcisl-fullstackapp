import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gcisl_app/pages/home.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  State<EmailLogin> createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  final _emailControllor = TextEditingController();
  final _passwordControllor = TextEditingController();

  _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailControllor.text, password: _passwordControllor.text);

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomePage()));
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
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            'Cobb Connect',
            style: TextStyle(
                color: Colors.grey, fontSize: 50, fontWeight: FontWeight.w900),
          ),
          const Text(
            'Log In',
            style: TextStyle(
                color: Colors.purple,
                fontSize: 25,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 80.0, right: 80.0),
            child: TextField(
              controller: _emailControllor,
              decoration: const InputDecoration(
                  labelText: 'Enter Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 80.0, right: 80.0, top: 10),
            child: TextField(
              controller: _passwordControllor,
              decoration: const InputDecoration(
                  labelText: 'Enter Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                _login();
              },
              child: const Text("Log In"))
        ]),
      ),
    );
  }
}
