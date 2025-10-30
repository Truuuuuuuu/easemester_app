import 'package:easemester_app/models/file_card_model.dart';
import 'package:easemester_app/data/constant.dart';
import 'package:flutter/material.dart';

class ShortQuizPage extends StatefulWidget {
  final FileCardModel file;

  const ShortQuizPage({super.key, required this.file});

  @override
  State<ShortQuizPage> createState() =>
      _ShortQuizPageState();
}

class _ShortQuizPageState extends State<ShortQuizPage> {
  bool _showAnswers = false;

  @override
  Widget build(BuildContext context) {
    final quizList = widget.file.aiFeatures?['quiz'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.file.fileName,
          style: AppFonts.heading3,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: quizList == null || quizList.isEmpty
            ? const Center(
                child: Text('No quiz available.'),
              )
            : Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🧠 Short Quiz",
                            style: AppFonts.heading2
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(quizList.length, (
                            index,
                          ) {
                            final item = quizList[index];
                            return Card(
                              elevation: 3,
                              margin:
                                  const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                      12.0,
                                    ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      'Q${index + 1}: ${item['question']}',
                                      style: AppFonts
                                          .heading3
                                          .copyWith(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    if (_showAnswers)
                                      Text(
                                        'Answer: ${item['answer']}',
                                        style: AppFonts
                                            .paragraph
                                            .copyWith(
                                              color: Colors
                                                  .green[700],
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAnswers = !_showAnswers;
                      });
                    },
                    icon: Icon(
                      _showAnswers
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    
                    label: Text(
                      _showAnswers
                          ? 'Hide All Answers'
                          : 'Show All Answers',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
