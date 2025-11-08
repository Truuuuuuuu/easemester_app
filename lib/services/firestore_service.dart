import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easemester_app/models/profile_model.dart';
import 'package:rxdart/rxdart.dart';

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
  Future<void> saveUser(UserModel user) async {
    await _db
        .collection("users")
        .doc(user.uid)
        .set(user.toMap());
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

  // <<COUNT ALL PENDING CHECKLIST TASKS>>
  Stream<int> pendingChecklistCountStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('checklist')
        .where('completed', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.size);
  }

  // <<COUNT STUDYHUB FILES WITH aiFeatures>>
  Stream<int> activeFilesCountStream(String uid) {
    return _db
        .collection("users")
        .doc(uid)
        .collection("studyHubFiles")
        .where('aiFeatures', isGreaterThan: {})
        .snapshots()
        .map((snap) => snap.size);
  }

  // <<COUNT PENDING QUIZZES>>
  Stream<int> pendingQuizCountStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('studyHubFiles')
        .snapshots()
        .map((filesSnapshot) {
          int pendingCount = 0;

          for (final fileDoc in filesSnapshot.docs) {
            final aiFeatures =
                fileDoc.data()['aiFeatures']
                    as Map<String, dynamic>?;

            if (aiFeatures == null) {
              //avoid count dropiing zero
              pendingCount += 0;
              continue;
            }

            final quizAnswers =
                aiFeatures['quizAnswers']
                    as Map<String, dynamic>?;

            if (quizAnswers == null ||
                quizAnswers['isCompleted'] == false) {
              pendingCount += 1;
            }
          }

          return pendingCount;
        });
  }
}
