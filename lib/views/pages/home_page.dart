import 'package:easemester_app/data/constant.dart';
import 'package:easemester_app/helpers/dialog_helpers.dart';
import 'package:easemester_app/views/pages/ai%20features/ai_features_page.dart';
import 'package:easemester_app/views/widgets/cards/file_card.dart';
import 'package:easemester_app/views/widgets/study_card.dart';
import 'package:flutter/material.dart';
import 'package:easemester_app/views/widgets/cards/achievement_card.dart';
import 'package:easemester_app/controllers/home_controller.dart';
import 'file_viewer_page.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

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
                                  FeaturePage(file: file, isStudyHub: true),
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
                          onTap: () async {
                            final url = file.fileUrl;
                            final isTxt = url
                                .toLowerCase()
                                .endsWith('.txt');

                            showModalBottomSheet(
                              context: context,
                              builder: (_) => SafeArea(
                                child: Wrap(
                                  children: [
                                    if (isTxt)
                                      ListTile(
                                        leading: const Icon(
                                          Icons
                                              .description_outlined,
                                        ),
                                        title: const Text(
                                          'View in app (TXT)',
                                        ),
                                        onTap: () {
                                          Navigator.pop(
                                            context,
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  FileViewerPage(
                                                    fileUrl:
                                                        url,
                                                    fileName:
                                                        file.fileName,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.open_in_new,
                                      ),
                                      title: const Text(
                                        'Open with another app',
                                      ),
                                      onTap: () async {
                                        Navigator.pop(
                                          context,
                                        );
                                        try {
                                          // Show a simple loading dialog while downloading
                                          showDialog(
                                            context:
                                                context,
                                            barrierDismissible:
                                                false,
                                            builder: (_) =>
                                                const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                          );
                                          // Download to temp
                                          final response =
                                              await http.get(
                                                Uri.parse(
                                                  url,
                                                ),
                                              );
                                          final tempDir =
                                              await getTemporaryDirectory();
                                          final fileName =
                                              url
                                                  .split(
                                                    '/',
                                                  )
                                                  .last
                                                  .split(
                                                    '?',
                                                  )
                                                  .first;
                                          final filePath =
                                              '${tempDir.path}/$fileName';
                                          final f = File(
                                            filePath,
                                          );
                                          await f.writeAsBytes(
                                            response
                                                .bodyBytes,
                                          );
                                          Navigator.pop(
                                            context,
                                          ); // close loading dialog
                                          // Open chooser
                                          final result =
                                              await OpenFilex.open(
                                                filePath,
                                              );
                                          if (result.type !=
                                                  ResultType
                                                      .done &&
                                              context
                                                  .mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Could not open file: ${result.message}',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context
                                              .mounted) {
                                            Navigator.pop(
                                              context,
                                            ); // ensure dialog closed if error
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to open: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
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
