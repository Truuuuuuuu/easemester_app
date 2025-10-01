import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryService {
  final String cloudName = 'truuuu';
  final String uploadPreset = 'unsigned_upload';

  Future<String?> uploadFile(File file) async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': uploadPreset,
      });

      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
        data: formData,
      );

      return response.data['secure_url'] as String?;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}
