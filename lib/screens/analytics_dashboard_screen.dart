import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends State<AnalyticsDashboardScreen> {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  int totalDrivers = 0;
  int totalUsers = 0;
  int totalRides = 0;

  double totalEarnings = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {

    final drivers =
        await firestore.collection("drivers").get();

    final users =
        await firestore.collection("users").get();

    final rides =
        await firestore.collection("rides").get();

    double earnings = 0;

    for (var ride in rides.docs) {
      final data = ride.data();

      earnings +=
          (data["fare"] ?? 0).toDouble();
    }

    setState(() {
      totalDrivers = drivers.docs.length;
      totalUsers = users.docs.length;
      totalRides = rides.docs.length;
      totalEarnings = earnings;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                children: [

                  Row(
                    children: [

                      Expanded(
                        child: dashboardCard(
                          "Drivers",
                          totalDrivers.toString(),
                          Icons.drive_eta,
                          Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: dashboardCard(
                          "Users",
                          totalUsers.toString(),
                          Icons.people,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      Expanded(
                        child: dashboardCard(
                          "Rides",
                          totalRides.toString(),
                          Icons.local_taxi,
                          Colors.orange,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: dashboardCard(
                          "Earnings",
                          "Rs ${totalEarnings.toStringAsFixed(2)}",
                          Icons.attach_money,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Monthly Earnings",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        borderData:
                            FlBorderData(show: false),

                        titlesData:
                            FlTitlesData(show: false),

                        barGroups: [],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {

    return Card(
      elevation: 5,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          children: [

            Icon(
              icon,
              size: 42,
              color: color,
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}