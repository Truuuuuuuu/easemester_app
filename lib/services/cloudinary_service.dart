import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  late final String cloudName;
  late final String apiKey;
  late final String apiSecret;
  late final String uploadPreset;

  final Dio _dio = Dio();

  CloudinaryService() {
    cloudName = dotenv.env['CD_NAME'] ?? '';
    apiKey = dotenv.env['CD_API_KEY'] ?? '';
    apiSecret = dotenv.env['CD_API_SECRET'] ?? '';
    uploadPreset = dotenv.env['CD_UPLOAD_PRESET'] ?? '';
  }

  /// Generates SHA-1 signature string for signed Cloudinary operations
  String _generateSignature(String toSign) {
    return sha1.convert(utf8.encode(toSign)).toString();
  }

  /// 🔼 Upload file to Cloudinary (returns url + public_id)
  Future<Map<String, dynamic>?> uploadFile(
    File file,
  ) async {
    try {
      final timestamp =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signatureString =
          'timestamp=$timestamp&upload_preset=$uploadPreset$apiSecret';
      final signature = _generateSignature(signatureString);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'api_key': apiKey,
        'timestamp': timestamp,
        'upload_preset': uploadPreset,
        'signature': signature,
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
        data: formData,
      );

      return {
        'url': response.data['secure_url'],
        'public_id': response.data['public_id'],
      };
    } catch (e) {
      print('❌ Cloudinary upload error: $e');
      return null;
    }
  }

  /// ❌ Delete file from Cloudinary (uses the public_id)
  Future<void> deleteFileByPublicId(String publicId) async {
    try {
      if (cloudName.isEmpty ||
          apiKey.isEmpty ||
          apiSecret.isEmpty) {
        throw Exception("Missing Cloudinary credentials");
      }

      final timestamp =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signatureRaw =
          'public_id=$publicId&timestamp=$timestamp$apiSecret';
      final signature = sha1
          .convert(utf8.encode(signatureRaw))
          .toString();

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/raw/destroy',
        data: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        print("✅ Cloudinary file deleted: $publicId");
      } else {
        print(
          "⚠️ Cloudinary deletion failed: ${response.data}",
        );
      }
    } catch (e) {
      print("❌ Cloudinary delete error: $e");
    }
  }
}
