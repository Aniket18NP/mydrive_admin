import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverDetailsScreen extends StatelessWidget {
  final String driverId;

  const DriverDetailsScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Details"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('drivers')
            .doc(driverId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Driver not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final name = data['name'] ?? "Unknown";

          final email = data['email'] ?? "";

          final phone = data['phone'] ?? "";

          final earnings = (data['earnings'] ?? 0).toDouble();

          final isOnline = data['isOnline'] ?? false;

          final documents = (data['documents'] as Map<String, dynamic>?) ?? {};

          final verification = documents['verificationStatus'] ?? "Pending";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          child: Icon(Icons.person, size: 45),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(email),

                        Text(phone),

                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Chip(
                              backgroundColor: isOnline
                                  ? Colors.green
                                  : Colors.red,
                              label: Text(
                                isOnline ? "Online" : "Offline",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),

                            Chip(
                              backgroundColor: verification == "Approved"
                                  ? Colors.green
                                  : verification == "Rejected"
                                  ? Colors.red
                                  : Colors.orange,
                              label: Text(
                                verification,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        ListTile(
                          leading: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.green,
                          ),
                          title: const Text("Total Earnings"),
                          trailing: Text(
                            "Rs ${earnings.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Driver Documents",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        documentTile(
                          title: "Driving License",
                          icon: Icons.badge,
                          url: documents['licenseUrl'] ?? "",
                        ),

                        const Divider(),

                        documentTile(
                          title: "Citizenship",
                          icon: Icons.credit_card,
                          url: documents['citizenshipUrl'] ?? "",
                        ),

                        const Divider(),

                        documentTile(
                          title: "Blue Book",
                          icon: Icons.directions_car,
                          url: documents['blueBookUrl'] ?? "",
                        ),

                        const Divider(),

                        documentTile(
                          title: "Insurance",
                          icon: Icons.security,
                          url: documents['insuranceUrl'] ?? "",
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('drivers')
                        .doc(driverId)
                        .update({'documents.verificationStatus': 'Approved'});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Driver Approved")),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Approve Driver"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('drivers')
                        .doc(driverId)
                        .update({'documents.verificationStatus': 'Rejected'});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Driver Rejected")),
                    );
                  },
                  icon: const Icon(Icons.close),
                  label: const Text("Reject Driver"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget documentTile({
    required String title,
    required IconData icon,
    required String url,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(url.isEmpty ? "Not Uploaded" : "Uploaded"),
      trailing: url.isEmpty
          ? const Icon(Icons.close, color: Colors.red)
          : const Icon(Icons.visibility, color: Colors.green),
    );
  }
}
