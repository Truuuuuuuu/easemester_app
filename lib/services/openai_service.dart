import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String baseUrl =
      'https://api.openai.com/v1/chat/completions';
  late final String apiKey;

  OpenAIService() {
    apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  }

  /// Generate a summary of the text
  Future<String> generateSummary(String text) async {
    print("🧠 Generating summary...");
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a helpful assistant that summarizes text in a way that students can fully understand. Include key concepts, explanations, and examples if necessary. Make it detailed but clear.",
            },
            {
              "role": "user",
              "content": "Summarize this:\n$text",
            },
          ],
          "max_tokens": 300,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final summary =
            decoded['choices'][0]['message']['content'];
        print("✅ Summary generated.");
        return summary;
      } else {
        print(
          "❌ API Error ${response.statusCode}: ${response.body}",
        );
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      print("❌ Exception in generateSummary: $e");
      return "Exception: $e";
    }
  }

  /// Generate a short quiz (question + answer pairs)
  Future<List<Map<String, String>>> generateShortQuiz(String text) async {
    print("🚀 Generating short quiz...");
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4o",
          "messages": [
            {
              "role": "system",
              "content": """
You are a helpful tutor. Ignore any instructor or university info. 
Generate exactly 10 identification quiz questions from the input text. 
Each answer must be **short and concise**, preferably a **single word or phrase**, not a full sentence. 
Respond ONLY with valid JSON in this exact format:

[
  {"question": "Question 1", "answer": "Answer 1"},
  {"question": "Question 2", "answer": "Answer 2"}
]

Do NOT include markdown, backticks, or extra text. Escape any quotes inside values.
"""
            },
            {"role": "user", "content": text},
          ],
          "max_completion_tokens": 700,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        String content = decoded['choices'][0]['message']['content'].trim();

        // Remove code fences if present
        content = content.replaceAll(RegExp(r'```(json)?'), '').trim();

        // Empty response check
        if (content.isEmpty) {
          print("⚠️ Empty API response");
          return [
            {'question': 'Error', 'answer': 'API returned empty response'}
          ];
        }

        // Try parsing JSON
        try {
          final List<dynamic> parsed = jsonDecode(content);
          final quizList = parsed
              .map<Map<String, String>>(
                (e) => {
                  'question': e['question'].toString(),
                  'answer': e['answer'].toString(),
                },
              )
              .toList();
          print("✅ Parsed ${quizList.length} quiz items.");
          return quizList;
        } catch (err) {
          print("⚠️ JSON parse failed: $err");
          return [
            {'question': 'Quiz parse error', 'answer': content}
          ];
        }
      } else {
        print("❌ API Error ${response.statusCode}: ${response.body}");
        return [
          {'question': 'API Error', 'answer': response.body}
        ];
      }
    } catch (e) {
      print("❌ Exception in generateShortQuiz: $e");
      return [
        {'question': 'Exception', 'answer': e.toString()}
      ];
    }
  }

  /// Generate flashcards (term + definition pairs)
  Future<List<Map<String, String>>> generateFlashcards(String text) async {
    print("📘 Generating flashcards...");
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4o",
          "messages": [
            {
              "role": "system",
              "content": """
You are a helpful assistant that creates 10 educational flashcards from the text.
Ignore instructor/university info. Focus only on key concepts and definitions.
Respond ONLY in valid JSON like this:

[
  {"term": "Term 1", "definition": "Definition 1"},
  {"term": "Term 2", "definition": "Definition 2"}
]

Do NOT include markdown, backticks, or extra text. Escape quotes inside values.
"""
            },
            {"role": "user", "content": text},
          ],
          "max_completion_tokens": 800,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        String content = decoded['choices'][0]['message']['content'].trim();

        // Remove code fences
        content = content.replaceAll(RegExp(r'```(json)?'), '').trim();

        // Empty response check
        if (content.isEmpty) {
          print("⚠️ Empty API response");
          return [
            {'term': 'Error', 'definition': 'API returned empty response'}
          ];
        }

        // Parse JSON safely
        try {
          final List<dynamic> parsed = jsonDecode(content);
          final flashcards = parsed
              .map<Map<String, String>>(
                (e) => {
                  'term': e['term'].toString(),
                  'definition': e['definition'].toString(),
                },
              )
              .toList();
          print("✅ Parsed ${flashcards.length} flashcards.");
          return flashcards;
        } catch (err) {
          print("⚠️ JSON parse failed: $err");
          return [
            {'term': 'Flashcards parse error', 'definition': content}
          ];
        }
      } else {
        print("❌ API Error ${response.statusCode}: ${response.body}");
        return [
          {'term': 'API Error', 'definition': response.body}
        ];
      }
    } catch (e) {
      print("❌ Exception in generateFlashcards: $e");
      return [
        {'term': 'Exception', 'definition': e.toString()}
      ];
    }
  }
}
