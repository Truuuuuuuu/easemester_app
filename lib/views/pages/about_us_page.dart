import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('About Us'),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 9, 35, 64),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/easemester_logo.png',
                height: 120,
              ),
            ),
            const SizedBox(height: 20),

            // Page Title
            Text(
              'About Easemester',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Description
            const Text(
              'StudyHub is an AI-powered learning mobile application designed to help students understand, memorize, and review learning materials efficiently. '
              'Our platform allows students to upload documents, generate summaries, flashcards, and quizzes automatically, '
              'making studying smarter and more engaging.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Mission Section
            Text(
              'Our Mission',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'To empower students with AI powered tools that simplify learning, improves memory, and promote self-paced study.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            // Vision Section
            Text(
              'Our Vision',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'To create a learning app where students can easily understand, retain, and gain knowledge through smart, automated study solutions.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            // Contact Info
            Text(
              'Contact Us',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.email, size: 20),
                SizedBox(width: 8),
                Text(
                  "easemester@gmail.com",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.language, size: 20),
                SizedBox(width: 8),
                Text(
                  "www.studyhub.com",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),

            /* TEAM MEMBERS */
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                const Text(
                  "Our Team",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // ===== FIRST ROW =====
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                          'assets/images/aguilar.jpg',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Jethruel Aguilar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Lead Developer/Programmer",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ===== SECOND ROW =====
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    // Member 2
                    Column(
                      children: const [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(
                            'assets/images/estera.jpg',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Jake Estera",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "System Analyst",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    // Member 3
                    Column(
                      children: const [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(
                            'assets/images/farenas.jpg',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "John Mark Farenas",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "UI/UX Designer",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ===== THIRD ROW =====
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    // Member 4
                    Column(
                      children: const [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(
                            'assets/images/formento.jpg',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Ronnie Formento",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "UI/UX Designer",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    // Member 5
                    Column(
                      children: const [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(
                            'assets/images/gallego.jpg',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Nhel Jhon Gallego",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "QA Tester",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
