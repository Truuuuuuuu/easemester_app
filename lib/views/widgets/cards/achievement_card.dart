import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final String title;
  final double value;

  const AchievementCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade400, width: 0.5),
      ),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildIcon(title),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      minHeight: 10,
                      color: const Color.fromARGB(255, 25, 90, 165),
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("${value.toInt()} / 100",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Icon _buildIcon(String title) {
    switch (title) {
      case "Files Uploaded":
        return const Icon(Icons.upload_file, color: Colors.purple, size: 36);
      case "Total Summaries":
        return const Icon(Icons.summarize, color: Colors.orange, size: 36);
      case "Completed Quiz":
        return const Icon(Icons.quiz, color: Colors.blue, size: 36);
      case "Completed Tasks":
        return const Icon(Icons.check_circle, color: Colors.green, size: 36);
      case "Notes Created":
        return const Icon(Icons.note, color: Colors.amber, size: 36);
      case "Generated Flash Cards":
        return const Icon(Icons.style, color: Colors.pink, size: 36);
      case "Login Streak (Days)":
        return const Icon(Icons.local_fire_department, color: Colors.red, size: 36);
      case "Study Hours Logged":
        return const Icon(Icons.timer, color: Colors.teal, size: 36);
      case "Profile Completed":
        return const Icon(Icons.verified_user, color: Colors.indigo, size: 36);
      default:
        return const Icon(Icons.star, color: Colors.grey, size: 36);
    }
  }
}
