import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

import 'driver_management_screen.dart';
import 'passenger_management_screen.dart';
import 'ride_management_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'package:mydrive_admin/screens/analytics_dashboard_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final AuthService _authService = AuthService();

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {});
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text("MyDrive Admin"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text("Administrator"),
              accountEmail: Text("MyDrive Admin Panel"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 42,
                  color: Colors.blue,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text("Drivers"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DriverManagementScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Passengers"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PassengerManagementScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.local_taxi),
              title: const Text("Rides"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RideManagementScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Reports"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text("Analytics"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnalyticsDashboardScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              const Text(
                "Real-time overview of MyDrive",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: _firestoreService.totalDrivers(),
                      builder: (context, snapshot) {
                        return dashboardCard(
                          title: "Drivers",
                          value: "${snapshot.data ?? 0}",
                          icon: Icons.badge,
                          color: Colors.blue,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: StreamBuilder<int>(
                      stream: _firestoreService.totalUsers(),
                      builder: (context, snapshot) {
                        return dashboardCard(
                          title: "Users",
                          value: "${snapshot.data ?? 0}",
                          icon: Icons.people,
                          color: Colors.green,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: _firestoreService.totalRides(),
                      builder: (context, snapshot) {
                        return dashboardCard(
                          title: "Rides",
                          value: "${snapshot.data ?? 0}",
                          icon: Icons.local_taxi,
                          color: Colors.orange,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: StreamBuilder<int>(
                      stream: _firestoreService.pendingDrivers(),
                      builder: (context, snapshot) {
                        return dashboardCard(
                          title: "Pending",
                          value: "${snapshot.data ?? 0}",
                          icon: Icons.pending_actions,
                          color: Colors.red,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: _firestoreService.onlineDrivers(),
                      builder: (context, snapshot) {
                        return dashboardCard(
                          title: "Online",
                          value: "${snapshot.data ?? 0}",
                          icon: Icons.wifi,
                          color: Colors.teal,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: StreamBuilder<double>(
                      stream: _firestoreService.totalEarnings(),
                      builder: (context, snapshot) {
                        final earnings = snapshot.data ?? 0;

                        return dashboardCard(
                          title: "Earnings",
                          value: "Rs ${earnings.toStringAsFixed(0)}",
                          icon: Icons.account_balance_wallet,
                          color: Colors.purple,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: 70,
                        color: Colors.blue,
                      ),

                      SizedBox(height: 20),

                      Text(
                        "Welcome to MyDrive Admin",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Monitor drivers, passengers, rides, earnings and verification requests in real time.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 30),
            ),

            const SizedBox(height: 16),

            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
