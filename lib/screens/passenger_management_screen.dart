import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PassengerManagementScreen extends StatefulWidget {
  const PassengerManagementScreen({super.key});

  @override
  State<PassengerManagementScreen> createState() =>
      _PassengerManagementScreenState();
}

class _PassengerManagementScreenState extends State<PassengerManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Passenger Management"),
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
                hintText: "Search passenger",
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
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Passengers Found"));
                }

                final docs = snapshot.data!.docs;

                final passengers = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final name = (data["name"] ?? "").toString().toLowerCase();

                  final email = (data["email"] ?? "").toString().toLowerCase();

                  final phone = (data["phone"] ?? "").toString().toLowerCase();

                  if (_searchText.isEmpty) {
                    return true;
                  }

                  return name.contains(_searchText) ||
                      email.contains(_searchText) ||
                      phone.contains(_searchText);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: passengers.length,
                  itemBuilder: (context, index) {
                    final data =
                        passengers[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(data["name"] ?? "Unknown"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data["email"] ?? ""),
                            Text(data["phone"] ?? ""),
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
