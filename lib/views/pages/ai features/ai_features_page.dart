import 'package:easemester_app/models/file_card_model.dart';
import 'package:easemester_app/views/pages/ai%20features/flash_cards_page.dart';
import 'package:easemester_app/views/pages/ai%20features/short_quiz_page.dart';
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
        'icon': Icons.text_snippet_outlined,
        'route': SummaryPage(file: file),
      },
      {
        'title': 'Flash Cards',
        'icon': Icons.style_outlined,
        'route': FlashCardsPage(file: file),
      },
      {
        'title': 'Short Quiz',
        'icon': Icons.quiz_outlined,
        'route': ShortQuizPage(file: file),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Tools'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: features
              .map(
                (feature) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
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
                                Icon(
                                  feature['icon']
                                      as IconData,
                                  size: 32,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  feature['title']
                                      as String,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
