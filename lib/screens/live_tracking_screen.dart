import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String rideId;

  const LiveTrackingScreen({
    super.key,
    required this.rideId,
  });

  @override
  State<LiveTrackingScreen> createState() =>
      _LiveTrackingScreenState();
}

class _LiveTrackingScreenState
    extends State<LiveTrackingScreen> {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  GoogleMapController? mapController;

  final Set<Marker> markers = {};

  StreamSubscription<DocumentSnapshot>? rideSubscription;

  StreamSubscription<DocumentSnapshot>? driverSubscription;

LatLng? driverLocation;

Map<String, dynamic>? driverData;

  bool loading = true;

  Map<String, dynamic>? rideData;

  String driverId = "";

  LatLng? pickupLocation;
  LatLng? destinationLocation;

  CameraPosition initialCamera =
      const CameraPosition(
    target: LatLng(26.9987719, 84.8768412),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    loadRide();
  }

  @override
  void dispose() {
    rideSubscription?.cancel();
driverSubscription?.cancel();
mapController?.dispose();
    super.dispose();
  }

  void loadRide() {
    rideSubscription = firestore
        .collection("rides")
        .doc(widget.rideId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data =
          snapshot.data() as Map<String, dynamic>;

      driverId = data["driverId"] ?? "";

      pickupLocation = LatLng(
        (data["pickupLat"] as num).toDouble(),
        (data["pickupLng"] as num).toDouble(),
      );

      destinationLocation = LatLng(
        (data["destinationLat"] as num).toDouble(),
        (data["destinationLng"] as num).toDouble(),
      );

      rideData = data;

      markers.clear();

      markers.add(
        Marker(
          markerId:
              const MarkerId("pickup"),
          position: pickupLocation!,
          infoWindow: InfoWindow(
            title: "Pickup",
            snippet:
                data["pickup"] ?? "",
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );

      markers.add(
        Marker(
          markerId:
              const MarkerId("destination"),
          position: destinationLocation!,
          infoWindow: InfoWindow(
            title: "Destination",
            snippet:
                data["destination"] ?? "",
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );

      loading = false;

      if (mounted) {
        setState(() {});
      }

      void startDriverTracking() {
  if (driverId.isEmpty) return;

  driverSubscription?.cancel();

  driverSubscription = firestore
      .collection("drivers")
      .doc(driverId)
      .snapshots()
      .listen((snapshot) {
    if (!snapshot.exists) return;

    driverData =
        snapshot.data() as Map<String, dynamic>;

    driverLocation = LatLng(
      (driverData!["latitude"] as num).toDouble(),
      (driverData!["longitude"] as num).toDouble(),
    );

    markers.removeWhere(
      (marker) => marker.markerId.value == "driver",
    );

    markers.add(
      Marker(
        markerId: const MarkerId("driver"),
        position: driverLocation!,
        infoWindow: InfoWindow(
          title: driverData!["name"] ?? "Driver",
          snippet: driverData!["vehicleNumber"] ?? "",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  });
}

      zoomToFit();

      startDriverTracking();
    });
  }

  void zoomToFit() {
    if (mapController == null) return;
    if (pickupLocation == null) return;
    if (destinationLocation == null) return;

    LatLngBounds bounds;

    if (pickupLocation!.latitude <
        destinationLocation!.latitude) {
      bounds = LatLngBounds(
        southwest: pickupLocation!,
        northeast: destinationLocation!,
      );
    } else {
      bounds = LatLngBounds(
        southwest: destinationLocation!,
        northeast: pickupLocation!,
      );
    }

    Future.delayed(
      const Duration(milliseconds: 400),
      () {
        mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            bounds,
            80,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Live Ride Tracking"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Stack(
  children: [
    GoogleMap(
      initialCameraPosition: initialCamera,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: true,
      markers: markers,
      onMapCreated: (controller) {
        mapController = controller;
        zoomToFit();
      },
    ),

    rideInformationCard(),
  ],
)
    );
  }
  Widget rideInformationCard() {
  if (rideData == null) {
    return const SizedBox();
  }

  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              children: [

                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      driverData?["profileImage"] != null
                          ? NetworkImage(
                              driverData!["profileImage"])
                          : null,
                  child: driverData?["profileImage"] == null
                      ? const Icon(Icons.person)
                      : null,
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        driverData?["name"] ??
                            "Loading...",
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      Text(
                        driverData?["vehicleNumber"] ??
                            "",
                      ),

                      Text(
                        driverData?["vehicleType"] ??
                            "",
                      ),
                    ],
                  ),
                ),

                Chip(
                  backgroundColor: Colors.green.shade100,
                  label: Text(
                    rideData!["status"],
                    style: const TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                infoTile(
                  Icons.attach_money,
                  "Fare",
                  "Rs ${rideData!["fare"]}",
                ),

                infoTile(
                  Icons.route,
                  "Distance",
                  "${rideData!["distance"]} km",
                ),

                infoTile(
                  Icons.star,
                  "Rating",
                  "${driverData?["rating"] ?? "-"}",
                ),
              ],
            ),

            const SizedBox(height: 15),

            ListTile(
              leading:
                  const Icon(Icons.location_on),
              title: const Text("Pickup"),
              subtitle:
                  Text(rideData!["pickup"]),
            ),

            ListTile(
              leading:
                  const Icon(Icons.flag),
              title:
                  const Text("Destination"),
              subtitle: Text(
                  rideData!["destination"]),
            ),
            const SizedBox(height: 20),

Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Call feature coming soon"),
            ),
          );
        },
        icon: const Icon(Icons.call),
        label: const Text("Call"),
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          showDriverDetails();
        },
        icon: const Icon(Icons.person),
        label: const Text("Driver"),
      ),
    ),
  ],
),

const SizedBox(height: 10),

Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        onPressed: cancelRide,
        icon: const Icon(Icons.cancel),
        label: const Text("Cancel"),
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: completeRide,
        icon: const Icon(Icons.check_circle),
        label: const Text("Complete"),
      ),
    ),
  ],
),
          ],
        ),
      ),
    ),
  );
}
Widget infoTile(
    IconData icon,
    String title,
    String value,
    ) {
  return Column(
    children: [

      Icon(
        icon,
        color: Colors.blue,
      ),

      const SizedBox(height: 6),

      Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
  
}

Future<void> cancelRide() async {
  await firestore
      .collection("rides")
      .doc(widget.rideId)
      .update({
    "status": "Cancelled",
  });

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Ride Cancelled"),
    ),
  );
}

Future<void> completeRide() async {
  await firestore
      .collection("rides")
      .doc(widget.rideId)
      .update({
    "status": "Completed",
    "completedAt": Timestamp.now(),
  });

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Ride Completed"),
    ),
  );
}

void showDriverDetails() {
  if (driverData == null) return;

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Driver Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${driverData!["name"]}"),
            Text("Phone: ${driverData!["phone"]}"),
            Text("Vehicle: ${driverData!["vehicleType"]}"),
            Text("Vehicle No: ${driverData!["vehicleNumber"]}"),
            Text("Rating: ${driverData!["rating"]}"),
            Text("Trips: ${driverData!["trips"]}"),
            Text("Online: ${driverData!["isOnline"]}"),
            Text("Available: ${driverData!["isAvailable"]}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}
}