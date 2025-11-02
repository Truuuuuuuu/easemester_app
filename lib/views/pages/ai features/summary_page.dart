import 'package:flutter/material.dart';
import 'package:easemester_app/models/file_card_model.dart';
import 'package:easemester_app/data/constant.dart';

class SummaryPage extends StatefulWidget {
  final FileCardModel file;

  const SummaryPage({super.key, required this.file});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool _showSummary = true; // true for summary, false for original

  @override
  Widget build(BuildContext context) {
    final summaryText = widget.file.aiFeatures?['summary'] ?? "No summary available.";
    final extractedText = widget.file.fileText ?? "No extracted text found.";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.fileName, style: AppFonts.heading3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Use'),
                  content: const Text(
                    'Tap "Summary" or "Original" to switch between the summarized version and the full text.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
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
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Button Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showSummary = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showSummary
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          foregroundColor: _showSummary
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          elevation: _showSummary ? 4 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Summary'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showSummary = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_showSummary
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          foregroundColor: !_showSummary
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          elevation: !_showSummary ? 4 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Original'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Content Section
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _showSummary
                        ? _buildContentSection(
                            icon: Icons.summarize,
                            title: "Summary",
                            content: summaryText,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : _buildContentSection(
                            icon: Icons.article,
                            title: "Original Text",
                            content: extractedText,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      key: ValueKey(title), // For AnimatedSwitcher
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppFonts.heading2.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppFonts.paragraph.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
              height: 1.5, // Better line height for readability
            ),
          ),
        ],
      ),
    );
  }
}