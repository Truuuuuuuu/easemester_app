import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register user and send verification email
  Future<User?> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

      // Send verification email immediately after registration
      await sendEmailVerification();
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Send verification email
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Login user
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  //check if the current user is verified
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload(); // refresh user data
      return user.emailVerified;
    }
    return false;
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
