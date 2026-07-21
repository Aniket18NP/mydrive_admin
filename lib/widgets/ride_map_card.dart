import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideMapCard extends StatefulWidget {
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;

  const RideMapCard({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
  });

  @override
  State<RideMapCard> createState() => _RideMapCardState();
}

class _RideMapCardState extends State<RideMapCard> {

  GoogleMapController? _controller;

  bool _cameraMoved = false;

  @override
  Widget build(BuildContext context) {
    final pickup = LatLng(widget.pickupLat, widget.pickupLng);
    final destination = LatLng(
      widget.destinationLat,
      widget.destinationLng,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🗺️ Ride Route",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: pickup,
                    zoom: 14,
                  ),
                 onMapCreated: (controller) async {
  _controller = controller;

  if (_cameraMoved) return;

  _cameraMoved = true;

  final bounds = LatLngBounds(
    southwest: LatLng(
      widget.pickupLat < widget.destinationLat
          ? widget.pickupLat
          : widget.destinationLat,
      widget.pickupLng < widget.destinationLng
          ? widget.pickupLng
          : widget.destinationLng,
    ),
    northeast: LatLng(
      widget.pickupLat > widget.destinationLat
          ? widget.pickupLat
          : widget.destinationLat,
      widget.pickupLng > widget.destinationLng
          ? widget.pickupLng
          : widget.destinationLng,
    ),
  );

  await Future.delayed(
    const Duration(milliseconds: 300),
  );

  controller.animateCamera(
    CameraUpdate.newLatLngBounds(
      bounds,
      80,
    ),
  );
},
                  markers: {
                    Marker(
                      markerId: const MarkerId("pickup"),
                      position: pickup,
                      infoWindow: const InfoWindow(title: "Pickup"),
                    ),
                    Marker(
                      markerId: const MarkerId("destination"),
                      position: destination,
                      infoWindow: const InfoWindow(title: "Destination"),
                    ),
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}