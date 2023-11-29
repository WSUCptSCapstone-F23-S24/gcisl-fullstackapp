import 'package:test/test.dart';
import 'package:gcisl_app/pages/geolocation_service.dart';

void main() {
  group('queryGeoLocation', () {
    test('should return coordinates for valid address parameters', () async {
      String country = 'United States';
      String city = 'New York';
      String state = 'NY';
      String zipCode = '10001';

      Map<String, double> result = await GeoLocationService.queryGeoLocation(country, city, state, zipCode);

      expect(result["latitude"], isNotNull);
      expect(result["latitude"], isNotNull);
      expect(result["longitude"], isNotNull);
    });

    test('should throw an exception for invalid address parameters', () async {
      String country = 'Nonexistent Country';
      String city = 'Nonexistent City';
      String state = 'Nonexistent State';
      String zipCode = 'Nonexistent Zip Code';

      
      expect(() async {
        await GeoLocationService.queryGeoLocation(country, city, state, zipCode);
      }, throwsA(TypeMatcher<Exception>()));
    });

    
  });
}