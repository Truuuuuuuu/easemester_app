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
                  "You are a helpful assistant that summarizes text clearly and concisely.",
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
  Future<List<Map<String, String>>> generateShortQuiz(
    String text,
  ) async {
    print("🚀 Generating short quiz...");
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
              "content": """
You are a helpful tutor. Based on the input text, generate exactly 5 short quiz questions with their correct answers.
Respond *only* in pure JSON (no markdown or text outside the JSON), in this exact format:
[
  {"question": "...", "answer": "..."},
  {"question": "...", "answer": "..."}
]
""",
            },
            {"role": "user", "content": text},
          ],
          "max_tokens": 600,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        String content =
            decoded['choices'][0]['message']['content']
                .trim();

        // 🧹 Remove ```json or ``` if present
        content = content
            .replaceAll(RegExp(r'```(json)?'), '')
            .trim();

        print("📘 Cleaned quiz output: $content");

        // ✅ Try parsing JSON array
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
          // Return fallback if parsing failed
          return [
            {
              'question':
                  'Quiz could not be parsed properly.',
              'answer': content,
            },
          ];
        }
      } else {
        print(
          "❌ API Error ${response.statusCode}: ${response.body}",
        );
        return [
          {
            'question': 'Error fetching quiz.',
            'answer': response.body,
          },
        ];
      }
    } catch (e) {
      print("❌ Exception in generateShortQuiz: $e");
      return [
        {
          'question': 'Exception occurred.',
          'answer': e.toString(),
        },
      ];
    }
  }

  /// Generate flashcards (term + definition pairs)
  Future<List<Map<String, String>>> generateFlashcards(
    String text,
  ) async {
    print("📘 Generating flashcards...");
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
                  "You are a helpful assistant that creates flashcards from provided text.",
            },
            {
              "role": "user",
              "content":
                  """
Create 5 flashcards from the text below. Respond ONLY with a JSON array in this exact format (no markdown, no extra text):

[
  {"term": "Term 1", "definition": "Definition 1"},
  {"term": "Term 2", "definition": "Definition 2"}
]

Text:
$text
""",
            },
          ],
          "max_tokens": 400,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        String content =
            decoded['choices'][0]['message']['content']
                .toString()
                .trim();

        // Remove triple-backtick fences if present
        content = content
            .replaceAll(RegExp(r'```(json)?'), '')
            .trim();

        // Try parse
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
          print(
            "✅ Parsed ${flashcards.length} flashcards.",
          );
          return flashcards;
        } catch (err) {
          print("⚠️ Failed to parse flashcards JSON: $err");
          return [
            {
              'term': 'Flashcards parse error',
              'definition': content,
            },
          ];
        }
      } else {
        print(
          "❌ API Error ${response.statusCode}: ${response.body}",
        );
        return [
          {
            'term': 'API Error',
            'definition': response.body,
          },
        ];
      }
    } catch (e) {
      print("❌ Exception in generateFlashcards: $e");
      return [
        {'term': 'Exception', 'definition': e.toString()},
      ];
    }
  }
}
