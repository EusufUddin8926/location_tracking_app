import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location_tracking_app/controller/location_controller_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var locationControllerService = Get.put(LocationControllerService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _homeBody(),
    );
  }

  _buildAppBar() {
    return AppBar(
      title: const Text(
        "Location Service App",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      elevation: 4,
    );
  }

  _homeBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<Position>(
          stream: locationControllerService.streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Waiting for location...");
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              Position position = snapshot.data!;
              return Text(
                'Lat: ${position.latitude}, Long: ${position.longitude}',
                style: const TextStyle(fontSize: 18),
              );
            } else {
              return const Text("No location data available");
            }
          },
        ),
        const SizedBox(height: 20),
        Container(
          width: MediaQuery.sizeOf(context).width,
          alignment: Alignment.center,
          child: ElevatedButton(
              onPressed: () async {
                await locationControllerService.startGeoLocationService();
              },
              child: const Text("Start Location Service")),
        ),
      ],
    );
  }
}
