import 'package:flutter/material.dart';
import 'package:easemester_app/models/file_card_model.dart';
import 'package:easemester_app/data/constant.dart';

class SummaryPage extends StatelessWidget {
  final FileCardModel file;

  const SummaryPage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final summaryText = file.aiFeatures?['summary'] ?? "No summary available.";
    final extractedText = file.fileText ?? "No extracted text found.";

    return Scaffold(
      appBar: AppBar(
        title: Text(file.fileName, style: AppFonts.heading3),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Section
              Text(
                "📘 Summary",
                style: AppFonts.heading2.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summaryText,
                style: AppFonts.paragraph,
              ),

              const Divider(height: 32, thickness: 1),

              // Extracted Text Section
              Text(
                "📄 Original Text",
                style: AppFonts.heading2.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                extractedText,
                style: AppFonts.paragraph.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
