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

    if (quizList == null || quizList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary,
          foregroundColor: Theme.of(
            context,
          ).colorScheme.onPrimary,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Short Quiz',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.file.fileName,
                style: AppFonts.paragraph.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withOpacity(0.9),
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('How to Use'),
                    content: const Text(
                      'Browse the quiz questions. Tap "Show All Answers" to reveal answers for all questions.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No quiz available.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary,
        foregroundColor: Theme.of(
          context,
        ).colorScheme.onPrimary,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Short Quiz',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.file.fileName,
              style: AppFonts.paragraph.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withOpacity(0.9),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Use'),
                  content: const Text(
                    'Browse the quiz questions. Tap "Show All Answers" to reveal answers for all questions.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      ...List.generate(quizList.length, (
                        index,
                      ) {
                        final item = quizList[index];
                        return AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 300,
                          ),
                          curve: Curves.easeInOut,
                          margin:
                              const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface,
                            borderRadius:
                                BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              16,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(
                                                0.1,
                                              ),
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                    context,
                                                  )
                                                  .colorScheme
                                                  .primary,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Q${index + 1}: ${item['question']}',
                                        style: AppFonts
                                            .heading3
                                            .copyWith(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_showAnswers) ...[
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.all(
                                          12,
                                        ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.green[50],
                                      borderRadius:
                                          BorderRadius.circular(
                                            8,
                                          ),
                                      border: Border.all(
                                        color: Colors
                                            .green[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .check_circle,
                                          color: Colors
                                              .green[700],
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Answer: ${item['answer']}',
                                            style: AppFonts
                                                .paragraph
                                                .copyWith(
                                                  color: Colors
                                                      .green[700],
                                                  fontWeight:
                                                      FontWeight
                                                          .w500,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
