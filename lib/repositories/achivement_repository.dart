import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementRepository {
  final FirebaseFirestore firestore;

  AchievementRepository({required this.firestore});

  /// Increment total uploaded files and keep history
  Future<void> incrementFilesUploaded(String uid) async {
    final docRef = firestore
        .collection('users')
        .doc(uid)
        .collection('Achievement')
        .doc('filesUploaded');

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, {
          'totalUploaded': 1,
          'history': [DateTime.now()],
        });
      } else {
        final currentTotal = snapshot.get('totalUploaded') as int? ?? 0;
        final history = List.from(snapshot.get('history') ?? []);
        history.add(DateTime.now());
        transaction.update(docRef, {
          'totalUploaded': currentTotal + 1,
          'history': history,
        });
      }
    });
  }

  /// Stream total uploaded files
  Stream<int> filesUploadedStream(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('Achievement')
        .doc('filesUploaded')
        .snapshots()
        .map((snapshot) => (snapshot.data()?['totalUploaded'] ?? 0) as int);
  }

  /// You can add more achievements here later
  /// Example: login streak, notes created, quizzes completed, etc.
}
