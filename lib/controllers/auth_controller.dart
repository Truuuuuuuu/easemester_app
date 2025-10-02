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
    User? user = await _authService.registerUser(
      email: email,
      password: password,
    );
    if (user != null) {
      final newUser = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        profileImageUrl: '',
      );

      await _firestoreService.saveUser(newUser);
    }

    return user;
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
