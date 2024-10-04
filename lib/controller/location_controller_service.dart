import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationControllerService extends GetxService {
  late bool serviceEnabled;
  late LocationPermission permission;
  StreamController<Position> streamController = StreamController<Position>();

  Future<void> startGeoLocationService() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (position != null) {
        streamController.add(position); // Emit the position data
      }
    });
  }

  @override
  void onClose() {
    streamController
        .close(); // Close the stream controller when service is disposed
    super.onClose();
  }
}
