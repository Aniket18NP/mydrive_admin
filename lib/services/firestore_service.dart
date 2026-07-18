import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Total Drivers
  Stream<int> totalDrivers() {
    return _firestore.collection('drivers').snapshots().map(
          (snapshot) => snapshot.docs.length,
        );
  }

  /// Total Passengers
  Stream<int> totalUsers() {
    return _firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs.length,
        );
  }

  /// Total Rides
  Stream<int> totalRides() {
    return _firestore.collection('rides').snapshots().map(
          (snapshot) => snapshot.docs.length,
        );
  }

  /// Pending Driver Verification
  Stream<int> pendingDrivers() {
    return _firestore.collection('drivers').snapshots().map((snapshot) {
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['documents'] != null &&
            data['documents']['verificationStatus'] == "Pending") {
          count++;
        }
      }

      return count;
    });
  }

  /// Online Drivers
  Stream<int> onlineDrivers() {
    return _firestore.collection('drivers').snapshots().map((snapshot) {
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['isOnline'] == true) {
          count++;
        }
      }

      return count;
    });
  }

  /// Total Driver Earnings
  Stream<double> totalEarnings() {
    return _firestore.collection('drivers').snapshots().map((snapshot) {
      double total = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['earnings'] != null) {
          total += (data['earnings'] as num).toDouble();
        }
      }

      return total;
    });
  }
}