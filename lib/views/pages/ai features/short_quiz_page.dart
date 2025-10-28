import 'package:easemester_app/models/file_card_model.dart';
import 'package:flutter/material.dart';

class ShortQuizPage extends StatelessWidget {
  final FileCardModel file;

  const ShortQuizPage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Short Quiz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Short Quiz Page',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'File received: $file',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
