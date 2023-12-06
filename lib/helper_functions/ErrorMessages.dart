class ErrorMessages {
  String code;
  String message;
  ErrorMessages({required this.code, required this.message});

  String errorMessage(String code) {
    switch (code) {
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
      case 'missing-password':
        message = "Missing Password";
        break;
      case 'invalid-login-credentials':
        message = "Email or Password is Invalid";
        break;
    }
    return message;
  }
}
