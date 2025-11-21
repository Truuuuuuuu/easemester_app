import 'package:easemester_app/data/constant.dart';
import 'package:flutter/material.dart';
import 'package:easemester_app/models/file_card_model.dart';
import 'dart:math' as math;

class FlashCardPage extends StatefulWidget {
  final FileCardModel file;

  const FlashCardPage({super.key, required this.file});

  @override
  State<FlashCardPage> createState() =>
      _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashCardPage>
    with TickerProviderStateMixin {
  late List<Map<String, String>> _flashcards;
  int _currentIndex = 0;
  bool _showDefinition = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();

    final raw = widget.file.aiFeatures?['flashcards'];

    if (raw is List) {
      _flashcards = raw
          .whereType<Map>()
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

    // Initialize flip animation
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1)
        .animate(
          CurvedAnimation(
            parent: _flipController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _nextCard() {
    setState(() {
      if (_currentIndex < _flashcards.length - 1) {
        _currentIndex++;
        _showDefinition = false;
        _flipController.reset();
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        _showDefinition = false;
        _flipController.reset();
      }
    });
  }

  void _flipCard() {
    if (_flipController.isAnimating) return;
    if (_showDefinition) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showDefinition = !_showDefinition;
    });
  }

  Widget _buildCard(
    bool isFront,
    Map<String, String> currentCard,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: isFront
            ? Theme.of(context).colorScheme.surface
            : Theme.of(
                context,
              ).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          // ✅ FIXED: Removed extra Transform to prevent mirrored text
          child: Text(
            isFront
                ? (currentCard["definition"] ?? "")
                : (currentCard["term"] ?? ""),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isFront ? 24 : 20,
              fontWeight: isFront
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isFront
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.file.fileName,
            style: AppFonts.heading3,
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary,
          foregroundColor: Theme.of(
            context,
          ).colorScheme.onPrimary,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.library_books,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No flashcards available.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = _flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
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
              'Flashcards',
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
                    'Tap the card to flip between term and definition.\nSwipe left or right to navigate cards.',
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
        child: GestureDetector(
          onTap: _flipCard,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              _nextCard();
            } else if (details.primaryVelocity! > 0) {
              _previousCard();
            }
          },
          child: Center(
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final isFront = _flipAnimation.value < 0.5;
                final rotationY =
                    _flipAnimation.value * math.pi;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(rotationY),
                  alignment: Alignment.center,
                  child: isFront
                      ? _buildCard(true, currentCard)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(
                            math.pi,
                          ),
                          child: _buildCard(
                            false,
                            currentCard,
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _currentIndex > 0
                  ? _previousCard
                  : null,
              icon: Icon(
                Icons.arrow_back_ios,
                color: _currentIndex > 0
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value:
                        (_currentIndex + 1) /
                        _flashcards.length,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                          Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentIndex + 1} / ${_flashcards.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed:
                  _currentIndex < _flashcards.length - 1
                  ? _nextCard
                  : null,
              icon: Icon(
                Icons.arrow_forward_ios,
                color:
                    _currentIndex < _flashcards.length - 1
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
