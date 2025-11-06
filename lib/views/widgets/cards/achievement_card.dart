import 'package:easemester_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AchievementItem extends StatelessWidget {
  final String title;
  final bool isPending;
  final bool isFiles;

  const AchievementItem({
    super.key,
    required this.title,
    this.isPending = false,
    this.isFiles = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFiles) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return _buildCount("0", context);

      return StreamBuilder<int>(
        stream: FirestoreService().totalFilesCountStream(
          uid,
        ),
        builder: (context, snapshot) {
          final count = snapshot.data?.toString() ?? "0";
          return _buildCount(count, context);
        },
      );
    }

    if (isPending) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return _buildCount("0", context);

      return StreamBuilder<int>(
        stream: FirestoreService()
            .pendingChecklistCountStream(uid),
        builder: (context, snapshot) {
          final count = snapshot.data?.toString() ?? "0";
          return _buildCount(count, context);
        },
      );
    }
    //Default fallback widget (fixes the error)
    return _buildCount("0", context);
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
