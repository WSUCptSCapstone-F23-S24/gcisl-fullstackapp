import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/palette.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showSignInPage;
  const RegisterPage({Key? key, required this.showSignInPage})
      : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailControllor = TextEditingController();
  final _passwordControllor = TextEditingController();
  final _confirmPasswordControllor = TextEditingController();

  var loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Wecolme Back
                const Text(
                  'Welcome to Cobb Connect!',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),

                //Email textfield
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        controller: _emailControllor,
                        validator: _requiredValidator,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ),
                ),
                //Password textfield
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        controller: _passwordControllor,
                        validator: _requiredValidator,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ),
                ),

                //Confirm Password textfield
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        onFieldSubmitted: (value) {
                          debugPrint("pressed");
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            _register();
                          }
                        },
                        controller: _confirmPasswordControllor,
                        validator: _confirmPassword,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Re-enter Password',
                        ),
                      ),
                    ),
                  ),
                ),

                //Register button
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.ktoCrimson,
                      minimumSize: const Size(0, 65),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () {
                      debugPrint("pressed");
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate()) {
                        _register();
                      }
                    },
                    child: const Center(
                        child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    )),
                  ),
                ),

                //Already a Member? Login
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already a User? ',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: widget.showSignInPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }

  String? _requiredValidator(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'This Field is Required';
    }
    return null;
  }

  String? _confirmPassword(String? confirmPass) {
    if (confirmPass == null || confirmPass.trim().isEmpty) {
      return 'This Field is Required';
    }
    if (_passwordControllor.text != confirmPass) {
      return "Passwords do not match";
    }
    return null;
  }

  void _handleRegisterError(FirebaseAuthException e) {
    String message = " ";
    switch (e.code) {
      case 'email-already-in-use':
        message = "An account is already being used with this email";
        break;
      case 'invalid-email':
        message = "Invalid Email";
        break;
      case 'operation-not-alowed':
        message = "Error: Opporation not allowed";
        break;
      case 'weak-password':
        message = "Password is too weak, please enter a longer one";
        break;
    }

    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text("Sign up failed"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok"))
              ],
            )));
  }

  Future _register() async {
    setState(() {
      loading = true;
    });

    try {
      //try adding new user to authenticator
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailControllor.text, password: _passwordControllor.text);

      //TODO: add user data to database
      //DatabaseReference ref = FirebaseDatabase.instance.ref();

      //show success message
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Sign up Success"),
                content:
                    const Text("Your account was created, you can now login"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Ok"))
                ],
              ));

      widget.showSignInPage();
    } on FirebaseAuthException catch (e) {
      _handleRegisterError(e);
      setState(() {
        loading = false;
      });
    }
  }
}
