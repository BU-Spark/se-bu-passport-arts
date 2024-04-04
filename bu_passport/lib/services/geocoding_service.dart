import 'package:http/http.dart' as http;
import 'package:bu_passport/config/secrets.dart';
import 'dart:convert';

class GeocodingService {
  Future<Map<String, dynamic>?> getAddressCoordinates(String address) async {
    final Uri requestUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googlePlacesApiKey');

    final response = await http.get(requestUrl);

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      if (responseJson['results'].isNotEmpty) {
        final location = responseJson['results'][0]['geometry']['location'];
        return location; // Returns a Map with 'lat' and 'lng'
      }
    }
    return null;
  }
}
