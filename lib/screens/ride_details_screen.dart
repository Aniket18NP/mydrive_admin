import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RideDetailsScreen extends StatelessWidget {
  final String rideId;

  const RideDetailsScreen({
    super.key,
    required this.rideId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Details"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("rides")
            .doc(rideId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Ride not found"),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                userInfoCard(
  collection: "users",
  documentId: data["passengerId"] ?? "",
  title: "Passenger",
  icon: Icons.person,
),

userInfoCard(
  collection: "drivers",
  documentId: data["driverId"] ?? "",
  title: "Driver",
  icon: Icons.drive_eta,
),

infoCard(
  Icons.location_on,
  "Pickup",
  data["pickup"] ?? "N/A",
),


  infoCard(
    Icons.flag,
    "Destination",
    data["destination"] ?? "N/A",
  ),

  infoCard(
    Icons.directions_bike,
    "Ride Type",
    data["rideType"] ?? "N/A",
  ),

  infoCard(
    Icons.route,
    "Distance",
    "${(data["distance"] ?? 0).toString()} km",
  ),

  timelineCard(
  createdAt: data["createdAt"],
  startedAt: data["tripStartedAt"],
  completedAt: data["completedAt"],
),

paymentCard(
  fare: (data["fare"] ?? 0).toDouble(),
  paymentMethod: data["paymentMethod"] ?? "N/A",
  paymentStatus: data["paymentStatus"] ?? "Pending",
),

infoCard(
  Icons.local_taxi,
  "Ride Status",
  data["status"] ?? "N/A",
),
],
            ),
          );
        },
      ),
    );
  }
  Widget infoCard(
  IconData icon,
  String title,
  String value,
) {
  return Card(
    margin: const EdgeInsets.only(bottom: 14),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: ListTile(
      leading: Icon(
        icon,
        color: Colors.blue,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(value),
    ),
  );
}
Widget userInfoCard({
  required String collection,
  required String documentId,
  required String title,
  required IconData icon,
}) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection(collection)
        .doc(documentId)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return Card(
          child: ListTile(
            leading: Icon(icon, color: Colors.blue),
            title: Text(title),
            subtitle: const Text("Not Found"),
          ),
        );
      }

      final userData = snapshot.data!.data() as Map<String, dynamic>;

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

        Row(
          children: [

            CircleAvatar(
              radius: 30,
              backgroundImage:
                  (userData["profileImage"] != null &&
                          userData["profileImage"].toString().isNotEmpty)
                      ? NetworkImage(userData["profileImage"])
                      : null,
              child:
                  (userData["profileImage"] == null ||
                          userData["profileImage"].toString().isEmpty)
                      ? const Icon(Icons.person, size: 30)
                      : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    userData["fullName"] ??
                        userData["name"] ??
                        "Unknown",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(userData["phone"] ?? ""),

                  Text(userData["email"] ?? ""),

                  if (collection == "drivers") ...[

  const SizedBox(height: 12),

  Row(
    children: [
      const Icon(Icons.star, color: Colors.amber, size: 18),
      const SizedBox(width: 6),
      Text(
        "Rating: ${(userData["rating"] ?? 0).toStringAsFixed(1)}",
      ),
    ],
  ),

  const SizedBox(height: 6),

  Row(
    children: [
      const Icon(Icons.directions_car, color: Colors.blue, size: 18),
      const SizedBox(width: 6),
      Text(
        "${userData["vehicleType"] ?? "N/A"} • ${userData["vehicleNumber"] ?? "N/A"}",
      ),
    ],
  ),

  const SizedBox(height: 6),

  Row(
    children: [
      const Icon(Icons.account_balance_wallet,
          color: Colors.green, size: 18),
      const SizedBox(width: 6),
      Text(
        "Earnings: Rs ${(userData["earnings"] ?? 0).toString()}",
      ),
    ],
  ),

  const SizedBox(height: 12),

Wrap(
  spacing: 10,
  runSpacing: 10,
  children: [

    Chip(
      avatar: Icon(
        Icons.circle,
        size: 12,
        color: userData["isOnline"] == true
            ? Colors.green
            : Colors.red,
      ),
      label: Text(
        userData["isOnline"] == true
            ? "Online"
            : "Offline",
      ),
      backgroundColor:
          userData["isOnline"] == true
              ? Colors.green.shade100
              : Colors.red.shade100,
    ),

    Chip(
      avatar: const Icon(
        Icons.verified,
        color: Colors.white,
        size: 18,
      ),
      label: Text(
        userData["documents"]?["verificationStatus"] ??
            "Pending",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor:
          userData["documents"]?["verificationStatus"] ==
                  "Approved"
              ? Colors.green
              : userData["documents"]?["verificationStatus"] ==
                      "Rejected"
                  ? Colors.red
                  : Colors.orange,
    ),

  ],
),

],

                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
); 
    },
  );
}
Widget paymentCard({
  required double fare,
  required String paymentMethod,
  required String paymentStatus,
}) {
  Color statusColor;

  switch (paymentStatus.toLowerCase()) {
    case "paid":
      statusColor = Colors.green;
      break;
    case "failed":
      statusColor = Colors.red;
      break;
    default:
      statusColor = Colors.orange;
  }

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
            "💳 Payment Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: Colors.green,
            ),
            title: const Text("Fare"),
            trailing: Text(
              "Rs ${fare.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Method"),
            trailing: Text(paymentMethod),
          ),

          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text("Status"),
            trailing: Chip(
              backgroundColor: statusColor,
              label: Text(
                paymentStatus,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget timelineCard({
  required Timestamp? createdAt,
  required Timestamp? startedAt,
  required Timestamp? completedAt,
}) {
  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";

    final date = timestamp.toDate();

    return "${date.day}/${date.month}/${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  String duration() {
    if (startedAt == null || completedAt == null) {
      return "N/A";
    }

    final diff =
        completedAt.toDate().difference(startedAt.toDate());

    return "${diff.inMinutes} min ${diff.inSeconds % 60} sec";
  }

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
            "🕒 Ride Timeline",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.event),
            title: const Text("Ride Created"),
            subtitle: Text(formatTime(createdAt)),
          ),

          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text("Trip Started"),
            subtitle: Text(formatTime(startedAt)),
          ),

          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text("Trip Completed"),
            subtitle: Text(formatTime(completedAt)),
          ),

          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text("Trip Duration"),
            subtitle: Text(duration()),
          ),
        ],
      ),
    ),
  );
}
}