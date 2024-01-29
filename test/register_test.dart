import 'package:test/test.dart';
import 'package:gcisl_app/helper_functions/register.dart';

class YourTestClass {
  static int sharedVariable = 0;

  static void showSignInPage() {
    sharedVariable = 1;
  }

  static void onSuccess() {
    sharedVariable = 1;
  }

  static void onFailure() {
    sharedVariable = -1;
  }

  static void testRegistrationSuccess() {
    test('Registering a user should succeed', () async {

      // Test data
      double? lat = 1.0;
      double? long = 2.0;
      int userID = 123;
      String email = 'test@example.com';
      String password = 'password123';
      String firstName = 'John';
      String lastName = 'Doe';
      String phone = '1234567890';
      String company = 'Test Company';
      String cityValue = 'Test City';
      String stateValue = 'Test State';
      String countryValue = 'Test Country';
      String zipcode = '12345';
      String position = 'Developer';
      String selectedUserType = 'student';

      // Test the registration
      await Register.registerUser(
        lat,
        long,
        userID,
        email,
        password,
        firstName,
        lastName,
        phone,
        company,
        cityValue,
        stateValue,
        countryValue,
        zipcode,
        position,
        selectedUserType,
        showSignInPage,
        onSuccess,
        onFailure,
      );
      expect(1, sharedVariable, reason: 'This test should pass');
    });
  }

  static void testRegistrationFailure() {
    test('Registering a user should fail', () async {

      // Test data
      double? lat = 1.0;
      double? long = 2.0;
      int userID = 123;
      String email = 'test@example.com';
      String password = 'asd';
      String firstName = 'John';
      String lastName = 'Doe';
      String phone = '1234567890';
      String company = 'Test Company';
      String cityValue = 'Test City';
      String stateValue = 'Test State';
      String countryValue = 'Test Country';
      String zipcode = '12345';
      String position = 'Developer';
      String selectedUserType = 'student';

      // Test the registration
      await Register.registerUser(
        lat,
        long,
        userID,
        email,
        password,
        firstName,
        lastName,
        phone,
        company,
        cityValue,
        stateValue,
        countryValue,
        zipcode,
        position,
        selectedUserType,
        showSignInPage,
        onSuccess,
        onFailure,
      );
      expect(-1, sharedVariable, reason: 'Weak password');
    });
  }

  static void main() {
    testRegistrationSuccess();
    testRegistrationFailure();
  }
}