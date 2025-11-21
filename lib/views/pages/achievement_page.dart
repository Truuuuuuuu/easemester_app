import 'package:easemester_app/repositories/achivement_repository.dart';
import 'package:easemester_app/views/widgets/cards/achievement_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementPage extends StatelessWidget {
  AchievementPage({super.key});

  final AchievementRepository _achievementRepo =
      AchievementRepository(
    firestore: FirebaseFirestore.instance,
  );

  final Map<String, double> _defaultAchievements = {
    "Files Uploaded": 0,
    "Total Summaries": 0,
    "Completed Quiz": 0,
    "Generated Flash Cards": 0,
    "Notes Created": 0,
    "Profile Progress": 0,
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
        builder: (context, filesSnapshot) {
          return StreamBuilder<Map<String, dynamic>>(
            stream: _achievementRepo.generatedContentStream(uid),
            builder: (context, generatedSnapshot) {
              return StreamBuilder<int>(
                stream: _achievementRepo.completedQuizStream(uid),
                builder: (context, completedQuizSnapshot) {
                  return StreamBuilder<int>(
                    stream: _achievementRepo.notesCreatedStream(uid),
                    builder: (context, notesSnapshot) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .get(),
                        builder: (context, userSnapshot) {
                          // Start with default values
                          final achievements =
                              Map<String, double>.from(_defaultAchievements);

                          // Files Uploaded
                          achievements["Files Uploaded"] =
                              filesSnapshot.data?.toDouble() ?? 0;

                          // Generated Content
                          final generated = generatedSnapshot.data ?? {};
                          achievements["Total Summaries"] =
                              (generated["totalSummaries"] ?? 0).toDouble();
                          achievements["Generated Flash Cards"] =
                              (generated["totalFlashcards"] ?? 0).toDouble();

                          // Completed Quiz
                          achievements["Completed Quiz"] =
                              completedQuizSnapshot.data?.toDouble() ?? 0;

                          // Notes Created
                          achievements["Notes Created"] =
                              notesSnapshot.data?.toDouble() ?? 0;

                          // Profile Progress (0–4)
                          double profileProgress = 0;
                          if (userSnapshot.hasData && userSnapshot.data!.exists) {
                            final data = userSnapshot.data!.data() as Map<String, dynamic>;
                            if ((data['profileImageUrl'] ?? '').isNotEmpty) profileProgress += 1;
                            if ((data['college'] ?? '').isNotEmpty) profileProgress += 1;
                            if ((data['course'] ?? '').isNotEmpty) profileProgress += 1;
                            if ((data['address'] ?? '').isNotEmpty) profileProgress += 1;
                          }
                          achievements["Profile Progress"] = profileProgress;

                          return ListView(
                            padding: const EdgeInsets.all(16),
                            children: achievements.entries
                                .map(
                                  (e) => AchievementCard(
                                    title: e.key,
                                    value: e.value,
                                  ),
                                )
                                .toList(),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
