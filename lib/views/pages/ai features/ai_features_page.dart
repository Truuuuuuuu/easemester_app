import 'package:easemester_app/models/file_card_model.dart';
import 'package:easemester_app/views/pages/ai%20features/flash_card_page.dart';
import 'package:easemester_app/views/pages/ai%20features/short_quiz_page.dart';
import 'package:easemester_app/views/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'summary_page.dart';

class FeaturePage extends StatelessWidget {
  final FileCardModel file;

  const FeaturePage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Summarize',
        'imageIcon': 'assets/images/summarize.png',
        'route': SummaryPage(file: file),
        'image': 'assets/images/summary_card.png',
      },
      {
        'title': 'Flash Cards',
        'imageIcon': 'assets/images/flash_card.png',
        'route': FlashCardPage(file: file),
        'image': 'assets/images/flashcard_card.png',
      },
      {
        'title': 'Short Quiz',
        'imageIcon': 'assets/images/quiz.png',
        'route': ShortQuizPage(file: file),
        'image': 'assets/images/quiz_card.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Tools'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
          ), 
          onPressed: () {
            Navigator.of(context).pop(); 
          },
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: features.map((feature) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
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

                    // Dark overlay for readability
                    Container(
                      color: Colors.black.withOpacity(0.3),
                    ),

                    // Foreground content with InkWell
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                feature['route'] as Widget,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
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
                                const SizedBox(width: 7),
                                Text(
                                  feature['title']
                                      as String,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight:
                                        FontWeight.w700,
                                    color: Colors.white,
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
    );
  }
}
