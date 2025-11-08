import 'package:easemester_app/repositories/achivement_repository.dart';
import 'package:easemester_app/views/widgets/cards/achievement_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AchievementPage extends StatelessWidget {
  AchievementPage({super.key});

  final AchievementRepository _achievementRepo =
      AchievementRepository(firestore: FirebaseFirestore.instance);

  final Map<String, double> _defaultAchievements = {
    "Files Uploaded": 0,
    "Total Summaries": 0,
    "Completed Quiz": 0,
    "Completed Tasks": 0,
    "Notes Created": 0,
    "Review Flash Cards": 0,
    "Login Streak (Days)": 0,
    "Study Hours Logged": 0,
    "Profile Completed": 0,
  };

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
        centerTitle: true,
      ),
      body: StreamBuilder<int>(
        stream: _achievementRepo.filesUploadedStream(uid),
        builder: (context, snapshot) {
          // Copy default achievements and update Files Uploaded dynamically
          final achievements = Map<String, double>.from(_defaultAchievements);
          achievements["Files Uploaded"] = snapshot.data?.toDouble() ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: achievements.entries
                .map((e) => AchievementCard(title: e.key, value: e.value))
                .toList(),
          );
        },
      ),
    );
  }
}
