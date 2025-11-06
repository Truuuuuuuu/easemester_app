import 'package:easemester_app/repositories/quiz_repository.dart';

class QuizController {
  final QuizRepository _repository = QuizRepository();

  Map<int, String> userAnswers = {};
  bool submitted = false;
  bool isCompleted = false;
  int score = 0;
  List<dynamic> quizList = [];

  /// Load both quiz and user answers from Firestore
  Future<void> loadData(String fileId) async {
    final data = await _repository.loadUserData(fileId);
    quizList = data['quizList'];
    userAnswers = data['userAnswers'];
    isCompleted = data['isCompleted'] ?? false;
    score = data['score'] ?? 0;
    submitted = isCompleted; // disable editing if already completed
  }

  Future<void> saveAnswers(String fileId, {bool isCompleted = false}) async {
    await _repository.saveUserAnswers(
      fileId,
      userAnswers,
      isCompleted: isCompleted,
      score: score,
    );
    this.isCompleted = isCompleted;
  }

  /// Called when the user types in the answer field
  void updateAnswer(int index, String value) {
    userAnswers[index] = value;
  }

  /// Called when the user clicks submit
  void markSubmitted() {
    submitted = true;
    isCompleted = true;
  }

  /// Calculates the score based on correct answers
  void calculateScore() {
    int correctCount = 0;
    for (int i = 0; i < quizList.length; i++) {
      final correct = quizList[i]['answer']
              ?.toString()
              .trim()
              .toLowerCase() ??
          '';
      final user = userAnswers[i]?.trim().toLowerCase() ?? '';
      if (user == correct) correctCount++;
    }
    score = correctCount;
  }
}
