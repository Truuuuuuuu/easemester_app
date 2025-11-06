import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> loadUserData(String fileId) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('studyHubFiles')
        .doc(fileId);

    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      return {
        'quizList': [],
        'userAnswers': {},
        'isCompleted': false,
        'score': 0,
      };
    }

    final data = docSnap.data() ?? {};
    final aiFeatures = data['aiFeatures'] ?? {};
    final quizList = aiFeatures['quiz'] ?? [];
    final quizAnswers = aiFeatures['quizAnswers'] ?? {};
    final userAnswers = quizAnswers['userAnswers'] ?? {};
    final isCompleted = quizAnswers['isCompleted'] ?? false;
    final score = quizAnswers['score'] ?? 0;

    return {
      'quizList': List.from(quizList),
      'userAnswers': Map<int, String>.from(userAnswers.map(
        (key, value) => MapEntry(int.parse(key), value.toString()),
      )),
      'isCompleted': isCompleted,
      'score': score,
    };
  }

  Future<void> saveUserAnswers(
    String fileId,
    Map<int, String> answers, {
    required bool isCompleted,
    required int score,
  }) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('studyHubFiles')
        .doc(fileId);

    await docRef.set({
      'aiFeatures': {
        'quizAnswers': {
          'userAnswers': answers.map((key, value) => MapEntry(key.toString(), value)),
          'isCompleted': isCompleted,
          'score': score,
        }
      }
    }, SetOptions(merge: true));
  }
}
