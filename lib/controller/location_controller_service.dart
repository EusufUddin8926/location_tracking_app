import 'dart:async';
import 'dart:isolate';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationControllerService extends GetxService {
  late bool serviceEnabled;
  late LocationPermission permission;
  StreamController<Position> streamController = StreamController<Position>();
  Isolate? _processingIsolate;
  ReceivePort _receivePort = ReceivePort(); // For receiving processed data

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> startLocationTracking() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    // Listen to location updates on the main thread
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (position != null) {
        // Send the position to the isolate for processing
        _processingIsolate?.kill(
            priority: Isolate.immediate); // Clean up any previous isolates
        Isolate.spawn(_processLocationData, [position, _receivePort.sendPort]);
      }
    });

    // Listen to processed data from the isolate
    _receivePort.listen((data) {
      streamController.add(data); // Emit processed position data
    });
  }

  // Isolate entry function for data processing
  static void _processLocationData(List<dynamic> params) {
    final Position position = params[0];
    final SendPort sendPort = params[1];

    // Here you can do some complex processing of the position
    // For demonstration, we'll just send back the same position

    sendPort.send(position); // Send the processed data back to the main thread
  }

  @override
  void onClose() {
    _processingIsolate?.kill(priority: Isolate.immediate); // Terminate isolate
    streamController.close(); // Close the stream controller
    _receivePort.close(); // Close the receive port
    super.onClose();
  }
}
