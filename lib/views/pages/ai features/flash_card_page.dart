import 'package:flutter/material.dart';
import 'package:easemester_app/models/file_card_model.dart';

class FlashCardPage extends StatefulWidget {
  final FileCardModel file;

  const FlashCardPage({super.key, required this.file});

  @override
  State<FlashCardPage> createState() =>
      _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashCardPage> {
  late List<Map<String, String>> _flashcards;
  int _currentIndex = 0;
  bool _showDefinition = false;

  @override
  void initState() {
    super.initState();

    final raw = widget.file.aiFeatures?['flashcards'];

    if (raw is List) {
      _flashcards = raw
          .whereType<Map>() // keep only valid maps
          .map(
            (e) => {
              "term": e["term"]?.toString() ?? "",
              "definition":
                  e["definition"]?.toString() ?? "",
            },
          )
          .toList();
    } else {
      _flashcards = [];
    }
  }

  void _nextCard() {
    setState(() {
      if (_currentIndex < _flashcards.length - 1) {
        _currentIndex++;
        _showDefinition = false;
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        _showDefinition = false;
      }
    });
  }

  void _flipCard() {
    setState(() {
      _showDefinition = !_showDefinition;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No flashcards available.'),
        ),
      );
    }

    final currentCard = _flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: _flipCard,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _nextCard();
          } else if (details.primaryVelocity! > 0) {
            _previousCard();
          }
        },
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(
                  scale: animation,
                  child: child,
                ),
            child: Container(
              key: ValueKey(_showDefinition),
              width:
                  MediaQuery.of(context).size.width * 0.85,
              height: 250,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _showDefinition
                      ? currentCard["definition"] ?? ""
                      : currentCard["term"] ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _showDefinition ? 18 : 22,
                    fontWeight: _showDefinition
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _previousCard,
              icon: const Icon(Icons.arrow_back_ios),
            ),
            Text(
              '${_currentIndex + 1} / ${_flashcards.length}',
            ),
            IconButton(
              onPressed: _nextCard,
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}
