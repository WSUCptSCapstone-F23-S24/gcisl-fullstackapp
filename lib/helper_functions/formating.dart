// geolocation_service.dart

import 'dart:convert';
class Formatting {
  static String formatPhoneString(String phoneNumber)
  {
    if(phoneNumber.length != 10)
    {
      return phoneNumber;
    }

    return "(${phoneNumber.substring(0,3)})-${phoneNumber.substring(3,6)}-${phoneNumber.substring(6)}";
  }
}
