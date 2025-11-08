import 'package:easemester_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AchievementItem extends StatelessWidget {
  final String title;
  final bool isPending;
  final bool isFiles;
  final bool isQuiz; // For completed quizzes

  const AchievementItem({
    super.key,
    required this.title,
    this.isPending = false,
    this.isFiles = false,
    this.isQuiz = false,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return _buildCount("0", context);

    Stream<int>? countStream;

    if (isQuiz) {
      countStream = FirestoreService().completedQuizCountStream(uid);
    } else if (isFiles) {
      countStream = FirestoreService().totalFilesCountStream(uid);
    } else if (isPending) {
      countStream = FirestoreService().pendingChecklistCountStream(uid);
    }

    if (countStream == null) return _buildCount("0", context);

    return StreamBuilder<int>(
      stream: countStream,
      builder: (context, snapshot) {
        final count = snapshot.data?.toString() ?? "0";
        return _buildCount(count, context);
      },
    );
  }

  Widget _buildCount(String count, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
