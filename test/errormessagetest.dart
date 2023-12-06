import 'package:gcisl_app/helper_functions/ErrorMessages.dart';
import 'package:test/test.dart';

void main() {
  test('Test errorMessage method', () {
    // Test case 1: Invalid email
    ErrorMessages error1 = ErrorMessages(code: 'invalid-email', message: '');
    expect(error1.errorMessage(error1.code), equals('Invalid email'));

    // Test case 5: Missing password
    ErrorMessages error2 = ErrorMessages(code: 'missing-password', message: '');
    expect(error2.errorMessage(error2.code), equals('Missing Password'));

    // Test case 6: Invalid login credentials
    ErrorMessages error3 =
        ErrorMessages(code: 'invalid-login-credentials', message: '');
    expect(error3.errorMessage(error3.code),
        equals('Email or Password is Invalid'));
  });
}
