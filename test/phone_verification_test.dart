import 'package:test/test.dart';
import 'package:gcisl_app/helper_functions/phone_verification.dart';

void main() {
  group('Phone Verification Tests', () {
    test('Valid phone number', () {
      expect(PhoneVerification.isValidPhoneNumber("(555) 123-4567"), isNull);
    });

    test('Null phone number', () {
      expect(PhoneVerification.isValidPhoneNumber(null), "This Field is Required");
    });

    test('Invalid phone number', () {
      expect(PhoneVerification.isValidPhoneNumber("(555) 123"), "Invalid phone number");
    });

    test('Extract numbers from phone number', () {
      expect(PhoneVerification.extractNumbers("(555) 123-4567"), "5551234567");
    });
  });
}
