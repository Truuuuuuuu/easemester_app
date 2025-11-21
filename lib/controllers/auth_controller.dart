import 'package:easemester_app/models/profile_model.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService =
      FirestoreService();

  // Register and save extra info to Firestore
  Future<User?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Only create user in Firebase Auth
    User? user = await _authService.registerUser(
      email: email,
      password: password,
    );

    return user;
  }

  Future<User?> loginAndCheckVerification({
    required String email,
    required String password,
  }) async {
    final user = await _authService.loginUser(
      email: email,
      password: password,
    );

    if (user != null) {
      // Reload to make sure verification status is updated
      await user.reload();
      final refreshedUser = _authService.currentUser;

      if (refreshedUser != null &&
          !refreshedUser.emailVerified) {
        // User exists in Firebase Auth but NOT verified
        return null; // Return null so UI knows to redirect
      }

      return refreshedUser; // Verified user
    }
    return null;
  }

  // Login
  Future<User?> login({
    required String email,
    required String password,
  }) {
    return _authService.loginUser(
      email: email,
      password: password,
    );
  }

  // Get Firestore user data
  Future<DocumentSnapshot<Map<String, dynamic>>>
  getUserData(String uid) {
    return _firestoreService.getUser(uid);
  }

  // Logout
  Future<void> signOut() {
    return _authService.signOut();
  }
}
