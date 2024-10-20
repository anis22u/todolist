import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location {
  double? latitude;
  double? longitude;

  Future<void> getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 50,
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);

      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print(e);
    }
  }

  LatLng getGooglePlex() {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    } else {
      throw 'Location not set yet!';
    }
  }

  GoogleMap gethemap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: getGooglePlex(), zoom: 13),
      markers: {
        Marker(
            markerId: MarkerId('_currentlocation'),
            icon: BitmapDescriptor.defaultMarker,
            position: getGooglePlex())
      },
    );
  }
}
