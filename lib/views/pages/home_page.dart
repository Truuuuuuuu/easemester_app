import 'package:easemester_app/data/constant.dart';
import 'package:easemester_app/helpers/dialog_helpers.dart';
import 'package:easemester_app/views/pages/ai%20features/ai_features_page.dart';
import 'package:easemester_app/views/pages/ai%20features/summary_page.dart';
import 'package:easemester_app/views/widgets/cards/file_card.dart';
import 'package:easemester_app/views/widgets/study_card.dart';
import 'package:flutter/material.dart';
import 'package:easemester_app/views/widgets/cards/achievement_card.dart';
import 'package:easemester_app/controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  final HomeController controller;

  const HomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Column(
          children: [
            // Achievement Section
            Container(
              margin: const EdgeInsets.all(12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      AchievementItem(
                        title: "Files Uploaded",
                        isFiles: true,
                      ),
                      AchievementItem(
                        title: "Quizzes Completed",
                        // add later
                      ),
                      AchievementItem(
                        title: "Pending Tasks",
                        isPending: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // TabBar
            TabBar(
              controller: controller.tabController,
              labelColor: Theme.of(
                context,
              ).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.6),
              labelStyle: AppFonts.heading3,
              tabs: const [
                Tab(text: "Study Hub"),
                Tab(text: "Files"),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  // Study Hub tab (files with AI features)
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        controller.studyHubCards.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                    itemBuilder: (context, index) {
                      final file = controller
                          .studyHubCards[index]; // FileCardModel
                      return StudyCard(
                        file: file,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                    FeaturePage(file: file),
                                  
                            ),
                          );
                        },
                        onLongPress: () {
                          confirmDeleteFile(
                            context,
                            controller,
                            file,
                          );
                        },
                      );
                    },
                  ),

                  // Files tab (normal files)
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.filesCards.length,
                    itemBuilder: (context, index) {
                      final file =
                          controller.filesCards[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: FileCardWidget(
                          fileCard: file,
                          onTap: () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Tapped file: ${file.fileName}',
                                ),
                              ),
                            );
                          },
                          onLongPress: () {
                            confirmDeleteFile(
                              context,
                              controller,
                              file,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
