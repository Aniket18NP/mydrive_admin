import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<int>(
              stream: firestoreService.totalDrivers(),
              builder: (context, snapshot) {
                return reportCard(
                  "Total Drivers",
                  "${snapshot.data ?? 0}",
                  Icons.badge,
                  Colors.blue,
                );
              },
            ),

            const SizedBox(height: 15),

            StreamBuilder<int>(
              stream: firestoreService.totalUsers(),
              builder: (context, snapshot) {
                return reportCard(
                  "Total Passengers",
                  "${snapshot.data ?? 0}",
                  Icons.people,
                  Colors.green,
                );
              },
            ),

            const SizedBox(height: 15),

            StreamBuilder<int>(
              stream: firestoreService.totalRides(),
              builder: (context, snapshot) {
                return reportCard(
                  "Total Rides",
                  "${snapshot.data ?? 0}",
                  Icons.local_taxi,
                  Colors.orange,
                );
              },
            ),

            const SizedBox(height: 15),

            StreamBuilder<int>(
              stream: firestoreService.pendingDrivers(),
              builder: (context, snapshot) {
                return reportCard(
                  "Pending Drivers",
                  "${snapshot.data ?? 0}",
                  Icons.pending_actions,
                  Colors.red,
                );
              },
            ),

            const SizedBox(height: 15),

            StreamBuilder<double>(
              stream: firestoreService.totalEarnings(),
              builder: (context, snapshot) {
                return reportCard(
                  "Total Earnings",
                  "Rs ${snapshot.data?.toStringAsFixed(0) ?? "0"}",
                  Icons.account_balance_wallet,
                  Colors.purple,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget reportCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
