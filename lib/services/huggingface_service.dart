import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HuggingFaceService {
  final String modelId = 'sshleifer/distilbart-cnn-12-6';
  late final String apiKey;

  HuggingFaceService() {
    apiKey = dotenv.env['HF_API_KEY'] ?? '';
  }

  Future<String> generateSummary(String text) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://api-inference.huggingface.co/models/$modelId',
        ),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': text,
          'parameters': {
            'max_length': 400,
            'min_length': 100,
          },
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Hugging Face response format: [{"summary_text": "..."}]
        if (decoded is List && decoded.isNotEmpty) {
          final summary = decoded[0]['summary_text'];
          return summary ?? "No summary generated.";
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
}
