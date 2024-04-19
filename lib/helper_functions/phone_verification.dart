// geolocation_service.dart

import 'dart:convert';
class PhoneVerification 
{
  static String? isValidPhoneNumber(String? phoneNumber) 
  {
    if(phoneNumber == null)
    {
      return "This Field is Required";
    }
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');    
    if(cleanedNumber.length == 10)
    {
      return null;
    }
    return "Invalid phone number";
  }

  static String extractNumbers(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'\D'), '');
  }
  
}