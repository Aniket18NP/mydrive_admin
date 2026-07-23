import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/routes_service.dart';

class RideMapCard extends StatefulWidget {
  final String driverId;

final double pickupLat;
final double pickupLng;
final double destinationLat;
final double destinationLng;

  const RideMapCard({
  super.key,
  required this.driverId,
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

  LatLng? _previousDriverPosition;

Timer? _animationTimer;

double _driverRotation = 0;

bool _cameraMoved = false;

Set<Polyline> _polylines = {};

Marker? _driverMarker;

BitmapDescriptor? _carIcon;

StreamSubscription<DocumentSnapshot>? _driverSubscription;

bool _loadingRoute = false;

Future<void> _loadRoute() async {
  if (_loadingRoute) return;

  _loadingRoute = true;

  final result = await RoutesService.getRoute(
    originLat: widget.pickupLat,
    originLng: widget.pickupLng,
    destinationLat: widget.destinationLat,
    destinationLng: widget.destinationLng,
  );

  _loadingRoute = false;

  if (result == null) return;

  final routes = result['routes'];

  if (routes == null || routes.isEmpty) return;

  final encoded =
      routes[0]['polyline']['encodedPolyline'] as String;

  final points = PolylinePoints().decodePolyline(encoded);

  final coordinates = points
      .map((p) => LatLng(p.latitude, p.longitude))
      .toList();

  setState(() {
    _polylines = {
      Polyline(
  polylineId: const PolylineId("rideRoute"),
  points: coordinates,
  color: Colors.blue,
  width: 6,
)
    };
  });
}

Future<void> _loadCarIcon() async {
  _carIcon = await AssetMapBitmap.create(
    const ImageConfiguration(
      size: Size(64, 64),
    ),
    'assets/images/car.png',
  );
}



void _listenToDriverLocation() {
  _driverSubscription = FirebaseFirestore.instance
      .collection('drivers')
      .doc(widget.driverId)
      .snapshots()
      .listen((snapshot) {
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;

    debugPrint("Driver document: $data");

    final lat = (data['latitude'] ?? 0).toDouble();
    final lng = (data['longitude'] ?? 0).toDouble();

    debugPrint("Driver Location: $lat, $lng");

    if (!mounted) return;

    final newPosition = LatLng(lat, lng);

if (_driverMarker == null) {
  setState(() {
    _driverMarker = Marker(
      markerId: const MarkerId('driver'),
      position: newPosition,
      icon: _carIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: const InfoWindow(
        title: '🚗 Driver',
      ),
      zIndex: 100,
    );
  });

  _previousDriverPosition = newPosition;
} else {
  _animateDriverMarker(newPosition);
}
  });
}

void _animateDriverMarker(LatLng newPosition) {
  // First location received
  if (_previousDriverPosition == null) {
    _previousDriverPosition = newPosition;

    setState(() {
      _driverMarker = _driverMarker?.copyWith(
        positionParam: newPosition,
      );
    });

    return;
  }

  _animationTimer?.cancel();

  const int steps = 30;
  int currentStep = 0;

  final double latStep =
      (newPosition.latitude - _previousDriverPosition!.latitude) / steps;

  final double lngStep =
      (newPosition.longitude - _previousDriverPosition!.longitude) / steps;

  _animationTimer = Timer.periodic(
    const Duration(milliseconds: 50),
    (timer) {
      currentStep++;

      final animatedPosition = LatLng(
        _previousDriverPosition!.latitude + latStep * currentStep,
        _previousDriverPosition!.longitude + lngStep * currentStep,
      );

      if (!mounted) return;

      setState(() {
        _driverMarker = _driverMarker?.copyWith(
          positionParam: animatedPosition,
        );
      });

      // Follow the driver
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: animatedPosition,
            zoom: 17,
          ),
        ),
      );

      if (currentStep >= steps) {
        timer.cancel();
        _previousDriverPosition = newPosition;
      }
    },
  );
}


@override
void initState() {
  super.initState();

  debugPrint("Driver ID: ${widget.driverId}");

  _loadCarIcon();

  _listenToDriverLocation();
}

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

  await _loadRoute();

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
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueAzure,
  ),
    position: pickup,
    infoWindow: const InfoWindow(title: "Pickup"),
  ),

  Marker(
  markerId: const MarkerId("destination"),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueRed,
  ),
    position: destination,
    infoWindow: const InfoWindow(title: "Destination"),
  ),

  if (_driverMarker != null) _driverMarker!,
},
                  polylines: _polylines,
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
  
@override
void dispose() {
  _driverSubscription?.cancel();
  _animationTimer?.cancel();
  super.dispose();
}
}