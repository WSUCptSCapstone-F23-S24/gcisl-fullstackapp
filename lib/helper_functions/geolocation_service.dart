// geolocation_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocode/geocode.dart';
class GeoLocationService {
  static Future<Map<String, double>> queryGeoLocation(
      String? country, String? city, String? state, String? zipCode) async {
    final apiUrl = Uri.parse('https://api.radar.io/v1/search/autocomplete');

    String csvParameters = '$country,$city,$state';

    if (zipCode != null) {
      csvParameters += ',$zipCode';
    }

    final url = Uri.parse('$apiUrl?query=$csvParameters');

    final response =
        await http.get(url, headers: {'Authorization': 'prj_live_sk_2fb53893e9f964d139db2df3f78ef8480ba5d424'});

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final latitude = responseData["addresses"][0]['latitude'];
      final longitude = responseData["addresses"][0]['longitude'];

      return {'latitude': latitude, 'longitude': longitude};
    } else {
      throw Exception(
          'Error: ${response.statusCode}, Response: ${response.body}');
    }
  }
}
