import 'package:test/test.dart';
import 'package:gcisl_app/helper_functions/geolocation_service.dart';

void main() {
  group('queryGeoLocation', () {
    test('should return coordinates for valid address parameters', () async {
      String country = 'United States';
      String city = 'New York';
      String state = 'NY';
      String zipCode = '10001';

      Map<String, double> result = await GeoLocationService.queryGeoLocation(country, city, state, zipCode);

      expect(result["latitude"], 42.879179);
      expect(result["longitude"], -75.246253);
      print("${result["longitude"]}  ${result["latitude"]}");
    });

    test('should return coordinates for a valid address in a different country', () async {
    String country = 'Canada';
    String city = 'Toronto';
    String state = 'ON';
    String zipCode = 'M5V 2L7';

    Map<String, double> result = await GeoLocationService.queryGeoLocation(country, city, state, zipCode);

    expect(result["latitude"], 38.511316);
    expect(result["longitude"], -122.460908);
    print("${result["longitude"]}  ${result["latitude"]}");
  });
    
  });
}