import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage
    extends StatelessWidget {
  final String
      name;
  final double
      latitude;
  final double
      longitude;

  const MapPage({
    super.key,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget
      build(BuildContext context) {
    final LatLng
        bankLocation =
        LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text('Location of $name'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: bankLocation,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('blood-bank-location'),
            position: bankLocation,
            infoWindow: InfoWindow(title: name),
          ),
        },
      ),
    );
  }
}
