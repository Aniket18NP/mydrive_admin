import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 45,
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              "MyDrive Administrator",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 5),

          const Center(
            child: Text(
              "Admin Panel",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text("App Version"),
              subtitle: const Text("Version 1.0.0"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text("Security"),
              subtitle: const Text("Firebase Authentication"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_done),
              title: const Text("Database"),
              subtitle: const Text("Cloud Firestore"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.flutter_dash),
              title: const Text("Framework"),
              subtitle: const Text("Flutter"),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await authService.logout();

                if (context.mounted) {
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(
                  double.infinity,
                  50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}