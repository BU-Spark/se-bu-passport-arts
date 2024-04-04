import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> isWithinRadius(double eventLatitude, double eventLongitude, double radiusInMeters) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false; // Location services are disabled
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false; // Location permissions are denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // Location permissions are permanently denied
    }

    Position position = await Geolocator.getCurrentPosition();
    double distance = Geolocator.distanceBetween(position.latitude, position.longitude, eventLatitude, eventLongitude);
    return distance <= radiusInMeters;
  }
}
