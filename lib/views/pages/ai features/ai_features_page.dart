import 'dart:ui';
import 'package:easemester_app/models/file_card_model.dart';
import 'package:easemester_app/repositories/achivement_repository.dart';
import 'package:easemester_app/views/pages/ai%20features/flash_card_page.dart';
import 'package:easemester_app/views/pages/ai%20features/short_quiz_page.dart';
import 'package:easemester_app/views/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'summary_page.dart';
import 'package:easemester_app/controllers/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeaturePage extends StatefulWidget {
  final FileCardModel file;
  final bool isStudyHub; // Only StudyHub should auto-generate
  
  const FeaturePage({super.key, required this.file, this.isStudyHub = true});

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage> {
  bool isGeneratingAI = false;
  late FileCardModel currentFile;
  final AchievementRepository _achievementRepository =
      AchievementRepository(firestore: FirebaseFirestore.instance);
  @override
  void initState() {
    super.initState();
    currentFile = widget.file;
    _maybeFetchOrGenerate();
  }

  Future<void> _maybeFetchOrGenerate() async {
    // Only StudyHub items should auto-generate
    if (!widget.isStudyHub) return;

    // Try to refresh from Firestore first in case another session already saved AI
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('studyHubFiles')
            .doc(currentFile.id)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['aiFeatures'] != null &&
              (data['aiFeatures'] as Map).isNotEmpty) {
            setState(() {
              currentFile = FileCardModel.fromMap(
                {
                  ...data,
                  'id': currentFile.id,
                },
              );
            });
            return; // AI exists; do not generate
          }
        }
      }
    } catch (_) {
      // Best-effort read; ignore and fall back to generation if needed
    }

    // No AI in Firestore or local; generate now
    if (currentFile.aiFeatures == null || currentFile.aiFeatures!.isEmpty) {
      setState(() => isGeneratingAI = true);
      final controller = HomeController.aiTools();
      final newFile = await controller.runExtractionAndAI(
        currentFile,
        isStudyHub: true,
      );
      setState(() => isGeneratingAI = false);
      if (newFile != null) {
        setState(() {
          currentFile = newFile;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Summarize',
        'imageIcon': 'assets/images/summarize.png',
        'route': SummaryPage(file: currentFile),
        'image': 'assets/images/summary_card.png',
      },
      {
        'title': 'Flash Cards',
        'imageIcon': 'assets/images/flash_card.png',
        'route': FlashCardPage(file: currentFile),
        'image': 'assets/images/flashcard_card.png',
      },
      {
        'title': 'Short Quiz',
        'imageIcon': 'assets/images/quiz.png',
        'route': ShortQuizPage(file: currentFile,  achievementRepository: _achievementRepository,),
        'image': 'assets/images/quiz_card.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Tools'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              iconSize: 40,
              onPressed: () =>
                  Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: features.map((feature) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        Image.asset(
                          feature['image'] as String,
                          fit: BoxFit.cover,
                        ),

                        // Dark overlay
                        Container(
                          color: Colors.black.withOpacity(
                            0.3,
                          ),
                        ),

                        // Foreground content with InkWell
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    feature['route']
                                        as Widget,
                              ),
                            );
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      feature['imageIcon']
                                          as String,
                                      width: 80,
                                      height: 80,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      feature['title']
                                          as String,
                                      style:
                                          const TextStyle(
                                            fontSize: 30,
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                            color: Colors
                                                .white,
                                          ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Loading overlay
          if (isGeneratingAI)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/lottie/loading_robot.json',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 24),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Almost there!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Your study materials are almost ready. Please wait…", 
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
