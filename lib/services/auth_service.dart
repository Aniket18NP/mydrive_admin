import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      final adminDoc = await _firestore
          .collection('admins')
          .doc(uid)
          .get();

      if (!adminDoc.exists) {
        await _auth.signOut();
        return "Access denied. Admin account not found.";
      }

      final data = adminDoc.data()!;

      if (data['active'] != true) {
        await _auth.signOut();
        return "Your admin account is inactive.";
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No account found with this email.";

        case 'wrong-password':
          return "Incorrect password.";

        case 'invalid-email':
          return "Invalid email address.";

        case 'invalid-credential':
          return "Invalid email or password.";

        default:
          return e.message ?? "Login failed.";
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}