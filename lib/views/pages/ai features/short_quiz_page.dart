import 'package:easemester_app/models/file_card_model.dart';
import 'package:easemester_app/data/constant.dart';
import 'package:easemester_app/controllers/quiz_controller.dart';
import 'package:easemester_app/repositories/achivement_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShortQuizPage extends StatefulWidget {
  final FileCardModel file;
  final AchievementRepository achievementRepository;
  const ShortQuizPage({
    super.key,
    required this.file,
    required this.achievementRepository,
  });

  @override
  State<ShortQuizPage> createState() =>
      _ShortQuizPageState();
}

class _ShortQuizPageState extends State<ShortQuizPage> {
  final QuizController _controller = QuizController();
  final Map<int, TextEditingController> _textControllers =
      {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadData(widget.file.id);

    setState(() {
      for (final entry in _controller.userAnswers.entries) {
        _textControllers[entry.key] = TextEditingController(
          text: entry.value,
        );
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizList = widget.file.aiFeatures?['quiz'];

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (quizList == null || quizList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Short Quiz')),
        body: const Center(
          child: Text('No quiz available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary,
        foregroundColor: Theme.of(
          context,
        ).colorScheme.onPrimary,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Short Quiz',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.file.fileName,
              style: AppFonts.paragraph.copyWith(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (_controller.isCompleted)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'You’ve already completed this quiz.\nScore: ${_controller.score}/${quizList.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: quizList.length,
                itemBuilder: (context, index) {
                  final item = quizList[index];
                  final question = item['question'];
                  final correctAnswer =
                      item['answer']
                          ?.toString()
                          .trim()
                          .toLowerCase() ??
                      '';
                  final userAnswer =
                      _controller.userAnswers[index]
                          ?.trim()
                          .toLowerCase() ??
                      '';
                  final isCorrect =
                      _controller.submitted &&
                      userAnswer == correctAnswer;

                  _textControllers.putIfAbsent(index, () {
                    final c = TextEditingController(
                      text:
                          _controller.userAnswers[index] ??
                          '',
                    );
                    c.addListener(() {
                      _controller.updateAnswer(
                        index,
                        c.text,
                      );
                    });
                    return c;
                  });

                  // Determine TextField border color
                  Color getBorderColor() {
                    if (!_controller.submitted) {
                      return Theme.of(context).dividerColor;
                    }
                    return isCorrect
                        ? Colors.green
                        : Theme.of(
                            context,
                          ).colorScheme.error;
                  }

                  // Determine TextField fill color
                  Color getFillColor() {
                    if (!_controller.submitted)
                      return Theme.of(
                        context,
                      ).colorScheme.surface;
                    return isCorrect
                        ? Colors.green[50]!
                        : Colors.red[50]!;
                  }

                  // Determine display text
                  String displayAnswer() {
                    if (!_controller.submitted)
                      return _controller
                              .userAnswers[index] ??
                          '';
                    if (userAnswer.isEmpty)
                      return 'No Answer';
                    return _controller.userAnswers[index] ??
                        '';
                  }

                  // Update TextField text after submission
                  _textControllers[index]!.text =
                      displayAnswer();

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.05,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${index + 1}: $question',
                          style: AppFonts.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller:
                              _textControllers[index],
                          enabled: !_controller.submitted,
                          style: TextStyle(
                            color: !_controller.submitted
                                ? Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color
                                : isCorrect
                                ? Colors.green[800]
                                : (userAnswer.isEmpty
                                      ? Colors.grey[600]
                                      : Colors.red[800]),
                          ),
                          decoration: InputDecoration(
                            hintText: "Your answer here",
                            filled: true,
                            fillColor: getFillColor(),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: getBorderColor(),
                              ),
                            ),
                            enabledBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: getBorderColor(),
                                  ),
                                ),
                            focusedBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: getBorderColor(),
                                    width: 2,
                                  ),
                                ),
                          ),
                        ),
                        if (_controller.submitted)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                            ),
                            child: Text(
                              'Correct Answer: ${item['answer']}',
                              style: TextStyle(
                                color: isCorrect
                                    ? Colors.green[800]
                                    : Colors.green[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _controller.submitted
                    ? null
                    : () async {
                        _controller.markSubmitted();
                        _controller.calculateScore();
                        await _controller.saveAnswers(
                          widget.file.id,
                          isCompleted: true,
                        );
                        // Update Completed Quiz achievement
                        await widget.achievementRepository
                            .incrementCompletedQuiz(
                              FirebaseAuth
                                  .instance
                                  .currentUser!
                                  .uid,
                            );

                        setState(() {});
                      },
                icon: const Icon(Icons.check),
                label: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green, // Green background
                  foregroundColor:
                      Colors.white, // White text & icon
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
