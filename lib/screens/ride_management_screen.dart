import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mydrive_admin/screens/live_tracking_screen.dart';

class RideManagementScreen extends StatefulWidget {
  const RideManagementScreen({super.key});

  @override
  State<RideManagementScreen> createState() =>
      _RideManagementScreenState();
}

class _RideManagementScreenState
    extends State<RideManagementScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      case "ongoing":
        return Colors.orange;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Management"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Ride",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("rides")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Rides Found"),
                  );
                }

                final rides = snapshot.data!.docs.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  final driver =
                      (data["driverName"] ?? "")
                          .toString()
                          .toLowerCase();

                  final passenger =
                      (data["passengerName"] ?? "")
                          .toString()
                          .toLowerCase();

                  if (_searchText.isEmpty) {
                    return true;
                  }

                  return driver.contains(_searchText) ||
                      passenger.contains(_searchText);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final rideDoc = rides[index];

                    final data =
                        rideDoc.data() as Map<String, dynamic>;

                    final rideId = rideDoc.id;

                    final status =
                        data["status"] ?? "Pending";

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Driver : ${data["driverName"] ?? "-"}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                                "Passenger : ${data["passengerName"] ?? "-"}"),
                            Text(
                                "Pickup : ${data["pickup"] ?? "-"}"),
                            Text(
                                "Drop : ${data["drop"] ?? "-"}"),
                            Text(
                                "Fare : Rs ${data["fare"] ?? 0}"),

                            const SizedBox(height: 10),

                            Chip(
                              backgroundColor:
                                  statusColor(status)
                                      .withOpacity(0.2),
                              label: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor(status),
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                    Icons.location_on),
                                label:
                                    const Text("Track Ride"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.blue,
                                  foregroundColor:
                                      Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LiveTrackingScreen(
                                        rideId: rideId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}