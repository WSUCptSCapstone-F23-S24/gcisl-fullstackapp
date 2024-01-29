import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Register {
  static Future registerUser(
      double? lat,
      double? long,
      int userID,
      String email,
      String password,
      String firstName,
      String lastName,
      String phone,
      String company,
      String cityValue,
      String stateValue,
      String countryValue,
      String zipcode,
      String position,
      String selectedUserType,
      Function showSignInPage,
      Function onSuccess,
      Function onFailure
  ) async {
    try {
      // Try adding a new user to the authenticator
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user's unique ID
      DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userID");
      bool isAdmin = email == "admin@wsu.edu" ? true : false;

      await ref.set({
        'first name': firstName,
        'last name': lastName,
        'email': email,
        'phone': phone,
        'company': company,
        'city address': cityValue,
        'state address': stateValue,
        'country address': countryValue,
        'zip address': zipcode,
        'lat': lat,
        'long': long,
        'position': position,
        'experience': "1",
        'date added': ServerValue.timestamp,
        'userType': selectedUserType,
        'isAdmin': isAdmin,
      });
      onSuccess();
      showSignInPage();
    } on FirebaseAuthException catch (e) {
      handleRegisterError(e, onFailure);
    }
  }

  static void handleRegisterError(FirebaseAuthException e, Function onFailure) {
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
    onFailure(message);

  }

}

    
