import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easemester_app/models/profile_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //<<<USERS>>>
  // Get current logged-in user as UserModel
  Future<UserModel?> getCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db
        .collection("users")
        .doc(uid)
        .get();
    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(uid, doc.data()!);
  }

  // Save user data after signup
  Future<void> saveUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection("users").doc(uid).set(data);
  }

  // Get user data
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(
    String uid,
  ) async {
    return await _db.collection("users").doc(uid).get();
  }

  // Update user data
  Future<void> updateUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection("users").doc(uid).update(data);
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    await _db.collection("users").doc(uid).delete();
  }

  //<<<NOTES>>>
  // Get reference to notes subcollection of a user
  // Get reference to a user's notes subcollection
  CollectionReference<Map<String, dynamic>> userNotesRef(
    String uid,
  ) {
    return _db
        .collection("users")
        .doc(uid)
        .collection("notes");
  }

  // Add a note
  Future<void> addNote(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await userNotesRef(uid).add(data);
  }

  // Update a note
  Future<void> updateNote(
    String uid,
    String noteId,
    Map<String, dynamic> data,
  ) async {
    await userNotesRef(uid).doc(noteId).update(data);
  }

  // Delete a note
  Future<void> deleteNote(String uid, String noteId) async {
    await userNotesRef(uid).doc(noteId).delete();
  }

  // Stream all notes of a user
  Stream<QuerySnapshot<Map<String, dynamic>>>
  getNotesStream(String uid) {
    return userNotesRef(
      uid,
    ).orderBy('createdAt', descending: true).snapshots();
  }
}
