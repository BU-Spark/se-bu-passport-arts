import 'package:geocoding/geocoding.dart';

class GeocodingService {
  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    return locations;
  }
}
