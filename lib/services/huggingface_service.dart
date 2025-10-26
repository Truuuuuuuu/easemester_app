import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HuggingFaceService {
  final String modelId = 'facebook/bart-large-cnn';
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
          'https://router.huggingface.co/hf-inference/models/$modelId',
        ),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': text,
          'parameters': {
            'max_length': 200,
            'min_length': 50,
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
}
