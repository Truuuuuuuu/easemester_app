import 'package:easemester_app/services/huggingface_service.dart';

class SummaryService {
  static final HuggingFaceService _hfService =
      HuggingFaceService();

  static Future<Map<String, dynamic>> summarizeText(
    String text,
  ) async {
    final summary = await _hfService.summarizeLongText(text);
    print("🧠 Summary in terminal: $summary");
    return {'summary_text': summary};
  }
}



