import 'package:flutter/material.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() =>
      _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  final Map<String, double> achievements = {
    "Total Summaries": 75,
    "Completed Quiz": 40,
    "Completed Tasks": 65,
    "Notes Created": 50,
    "Files Uploaded": 20,
    "Review Flash Cards": 90,
    "Login Streak (Days)": 15,
    "Study Hours Logged": 60,
    "Profile Completed": 100,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Achievements",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final title = achievements.keys.elementAt(index);
          final value = achievements.values.elementAt(
            index,
          );

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.grey.shade400, 
                width: 0.5,
                
              ),
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: value / 100,
                            minHeight: 10,
                            color: Color.fromARGB(
                              255,
                              25,
                              90,
                              165,
                            ),
                            backgroundColor:
                                Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${value.toInt()} / 100",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Icon _buildIcon(String title) {
    switch (title) {
      case "Total Summaries":
        return const Icon(
          Icons.summarize,
          color: Colors.orange,
          size: 36,
        );
      case "Completed Quiz":
        return const Icon(
          Icons.quiz,
          color: Colors.blue,
          size: 36,
        );
      case "Completed Tasks":
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 36,
        );
      case "Notes Created":
        return const Icon(
          Icons.note,
          color: Colors.amber,
          size: 36,
        );
      case "Files Uploaded":
        return const Icon(
          Icons.upload_file,
          color: Colors.purple,
          size: 36,
        );
      case "Review Flash Cards":
        return const Icon(
          Icons.style,
          color: Colors.pink,
          size: 36,
        );
      case "Login Streak (Days)":
        return const Icon(
          Icons.local_fire_department,
          color: Colors.red,
          size: 36,
        );
      case "Study Hours Logged":
        return const Icon(
          Icons.timer,
          color: Colors.teal,
          size: 36,
        );
      case "Profile Completed":
        return const Icon(
          Icons.verified_user,
          color: Colors.indigo,
          size: 36,
        );
      default:
        return const Icon(
          Icons.star,
          color: Colors.grey,
          size: 36,
        );
    }
  }
}
