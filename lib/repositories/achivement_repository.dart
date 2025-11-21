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
        final currentTotal =
            snapshot.get('totalUploaded') as int? ?? 0;
        final history = List.from(
          snapshot.get('history') ?? [],
        );
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
        .map(
          (snapshot) =>
              (snapshot.data()?['totalUploaded'] ?? 0)
                  as int,
        );
  }

  //Total summaries, flash cards, quizzes
  Future<void> incrementAllFeatures({
    required String uid,
    bool generatedSummary = false,
    bool generatedFlashcards = false,
    bool generatedQuiz = false,
  }) async {
    final contentRef = firestore
        .collection('users')
        .doc(uid)
        .collection('Achievement')
        .doc('generatedContent');

    await firestore.runTransaction((transaction) async {
      final snap = await transaction.get(contentRef);

      // Initialize the doc if it does not exist
      if (!snap.exists) {
        transaction.set(contentRef, {
          'totalSummaries': 0,
          'totalFlashcards': 0,
          'totalQuizzes': 0,
        });
      }

      // Current data
      final data = snap.data() ?? {};
      int totalSummaries = data['totalSummaries'] ?? 0;
      int totalFlashcards = data['totalFlashcards'] ?? 0;
      int totalQuizzes = data['totalQuizzes'] ?? 0;

      // Increment totals accordingly
      if (generatedSummary) totalSummaries++;
      if (generatedFlashcards) totalFlashcards++;
      if (generatedQuiz) totalQuizzes++;

      // Update the single generatedContent document
      transaction.update(contentRef, {
        'totalSummaries': totalSummaries,
        'totalFlashcards': totalFlashcards,
        'totalQuizzes': totalQuizzes,
      });
    });
  }

  Stream<Map<String, dynamic>> generatedContentStream(
    String uid,
  ) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('Achievement')
        .doc('generatedContent')
        .snapshots()
        .map((snap) => snap.data() ?? {});
  }

  //COMPLETED QUIZZES
  Future<void> incrementCompletedQuiz(String uid) async {
    final docRef = firestore
        .collection('users')
        .doc(uid)
        .collection('Achievement')
        .doc('completedQuiz');

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, {
          'totalCompleted': 1,
          'history': [DateTime.now()],
        });
      } else {
        final currentTotal =
            snapshot.get('totalCompleted') as int? ?? 0;
        final history = List.from(
          snapshot.get('history') ?? [],
        );
        history.add(DateTime.now());
        transaction.update(docRef, {
          'totalCompleted': currentTotal + 1,
          'history': history,
        });
      }
    });
  }

  Stream<int> completedQuizStream(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('Achievement')
        .doc('completedQuiz')
        .snapshots()
        .map(
          (s) => (s.data()?['totalCompleted'] ?? 0) as int,
        );
  }

  //TOTAL NOTES CREATED
  Future<void> incrementNotesCreated(String uid) async {
    final docRef = firestore
        .collection('users')
        .doc(uid)
        .collection('Achievement')
        .doc('notesCreated');

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, {
          'totalCreated': 1,
          'history': [DateTime.now()],
        });
      } else {
        final currentTotal =
            snapshot.get('totalCreated') as int? ?? 0;
        final history = List.from(
          snapshot.get('history') ?? [],
        );
        history.add(DateTime.now());
        transaction.update(docRef, {
          'totalCreated': currentTotal + 1,
          'history': history,
        });
      }
    });
  }

  // Stream for total notes created
  Stream<int> notesCreatedStream(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('Achievement')
        .doc('notesCreated')
        .snapshots()
        .map(
          (s) => (s.data()?['totalCreated'] ?? 0) as int,
        );
  }

  //PROFILE PROGRESS
  Stream<int> profileProgressStream(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data() ?? {};
          int progress = 0;

          // Profile photo
          if (data['profileImageUrl'] != null &&
              data['profileImageUrl']
                  .toString()
                  .trim()
                  .isNotEmpty) {
            progress += 1;
          }

          // College
          if (data['college'] != null &&
              data['college']
                  .toString()
                  .trim()
                  .isNotEmpty) {
            progress += 1;
          }

          // Course
          if (data['course'] != null &&
              data['course'].toString().trim().isNotEmpty) {
            progress += 1;
          }

          // Address
          if (data['address'] != null &&
              data['address']
                  .toString()
                  .trim()
                  .isNotEmpty) {
            progress += 1;
          }

          return progress; 
        });
  }
}
