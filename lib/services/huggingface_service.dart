import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HuggingFaceService {
  final String summaryModelId = 'facebook/bart-large-cnn';
  final String shortQuizModelId =
      'valhalla/t5-small-qg-prepend';
  late final String apiKey;

  HuggingFaceService() {
    apiKey = dotenv.env['HF_API_KEY'] ?? '';
  }

  ///Split long text into manageable chunks
  List<String> _chunkText(
    String text, {
    int chunkSize = 200,
  }) {
    final words = text.split(' ');
    List<String> chunks = [];
    for (int i = 0; i < words.length; i += chunkSize) {
      final chunk = words.skip(i).take(chunkSize).join(' ');
      chunks.add(chunk);
    }
    return chunks;
  }

  ///Basic summarization for a single text chunk
  Future<String> generateSummary(String text) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://api-inference.huggingface.co/models/$summaryModelId',
          //'https://api-inference.huggingface.co/models/$summaryModelId',
        ),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': text,
          'parameters': {
            "min_length": 30,
            "max_length": 130,
            "do_sample": false,
          },
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List && decoded.isNotEmpty) {
          final first = decoded[0];
          if (first is Map &&
              first.containsKey('summary_text')) {
            return first['summary_text'] ??
                "No summary generated.";
          } else if (first is Map &&
              first.containsKey('error')) {
            print(
              "❌ API returned error: ${first['error']}",
            );
            return "API Error: ${first['error']}";
          }
        } else if (decoded is Map &&
            decoded.containsKey('error')) {
          // When Hugging Face returns an error object instead of a list
          print(
            "❌ API returned error: ${decoded['error']}",
          );
          return "API Error: ${decoded['error']}";
        }
        return "Invalid response format.";
      } else {
        print(
          "❌ API Error ${response.statusCode}: ${response.body}",
        );
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      print("❌ Exception: $e");
      return "Exception: $e";
    }
  }

  /// High-level function that handles large text by chunking
  Future<String> summarizeLongText(String fullText) async {
    final chunks = _chunkText(fullText);
    List<String> summaries = [];

    for (final chunk in chunks) {
      if (chunk.trim().isEmpty) continue;
      final summary = await generateSummary(chunk);
      summaries.add(summary);
    }

    // Combine all partial summaries
    final combined = summaries.join(' ');

    // Optionally, run one final summarization pass to condense further
    print("🧠 Combining all partial summaries...");
    final finalSummary = await generateSummary(combined);

    return finalSummary;
  }

  /// Generate a 10-item short quiz (question + answer)
  Future<List<Map<String, String>>> generateShortQuiz(
    String text,
  ) async {
    print("🚀 Starting generateShortQuiz...");
    print(
      "📘 Input text: ${text.substring(0, text.length > 100 ? 100 : text.length)}...",
    );
    print("🔑 Using model: $shortQuizModelId");
    print("🔐 API Key present: ${apiKey.isNotEmpty}");

    try {
      print("🌐 Sending request to Hugging Face API...");
      final response = await http.post(
        Uri.parse(
          'https://api-inference.huggingface.co/models/$shortQuizModelId',
        ),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': text,
          'parameters': {
            'max_length': 180,
            'num_return_sequences': 10,
            'temperature': 0.9,
          },
        }),
      );

      print(
        "📩 Response received. Status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        print("✅ Successful response. Decoding JSON...");
        final decoded = jsonDecode(response.body);

        print("🧩 Decoded type: ${decoded.runtimeType}");
        print(
          "🔍 Decoded content preview: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}",
        );

        if (decoded is List && decoded.isNotEmpty) {
          print(
            "📄 Response is a non-empty list. Parsing generated questions...",
          );
          final result = decoded
              .map<Map<String, String>>((e) {
                final raw =
                    e['generated_text']?.toString() ??
                    e.toString();
                print("✏️ Raw generated text: $raw");
                final parts = raw.split('?');
                final question = parts.first.trim() + '?';
                final answer = parts.length > 1
                    ? parts.last.trim()
                    : 'N/A';
                print(
                  "🧠 Parsed Q: $question | A: $answer",
                );
                return {
                  'question': question,
                  'answer': answer,
                };
              })
              .take(10)
              .toList();
          print(
            "✅ Successfully parsed ${result.length} quiz items.",
          );
          return result;
        } else {
          print(
            "⚠️ Unexpected response structure. Decoded: $decoded",
          );
          return [
            {
              'question': 'Unexpected response format.',
              'answer': decoded.toString(),
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
            'answer':
                'Status ${response.statusCode}: ${response.body}',
          },
        ];
      }
    } catch (e, stack) {
      print("💥 Exception in generateShortQuiz: $e");
      print("🧾 Stack trace:\n$stack");
      return [
        {
          'question': 'Exception occurred.',
          'answer': e.toString(),
        },
      ];
    }

  }
}
