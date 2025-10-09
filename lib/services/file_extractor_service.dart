import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FileExtractor {
  /// 🔹 Extract text from a local path or remote URL
  /// Avoids re-extracting if text is already saved in Firestore.
  static Future<String?> pickAndExtractFromPath(
    String filePath,
  ) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('No logged-in user');

      // ✅ Get filename (same key used in Firestore)
      final fileName = filePath.split('/').last;

      // ✅ Check if text already stored in Firestore
      final existingDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('files')
          .doc(fileName)
          .get();

      if (existingDoc.exists &&
          existingDoc.data() != null &&
          existingDoc.data()!['fileText'] != null &&
          (existingDoc.data()!['fileText'] as String)
              .isNotEmpty) {
        print(
          "⚡ Using cached extracted text for $fileName",
        );
        return existingDoc.data()!['fileText'];
      }

      // 🔽 If file is from the web, download it first
      if (filePath.startsWith('http')) {
        filePath = await _downloadFile(filePath);
      }

      // 🔹 Extract text based on file type
      final extension = filePath
          .split('.')
          .last
          .toLowerCase();
      String text;

      switch (extension) {
        case 'pdf':
          text = await _extractPdf(filePath);
          break;
        case 'docx':
          text = await _extractDocx(filePath);
          break;
        case 'txt':
          text = await _extractTxt(filePath);
          break;
        default:
          print("❌ Unsupported file type: $extension");
          return null;
      }

      // ✅ Cache extracted text back to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('files')
          .doc(fileName)
          .set({'fileText': text}, SetOptions(merge: true));

      print(
        "💾 Saved extracted text for $fileName to Firestore",
      );
      return text;
    } catch (e) {
      print("❌ Error extracting file text: $e");
      return null;
    }
  }

  /// 🔹 Download remote file to temp directory
  static Future<String> _downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to download file: $url');
    }

    final tempDir = await getTemporaryDirectory();
    final fileName = url.split('/').last;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(response.bodyBytes);
    print('📥 Downloaded to: ${file.path}');
    return file.path;
  }

  /// 🔹 Extract PDF text (Syncfusion)
  static Future<String> _extractPdf(String filePath) async {
    try {
      final bytes = File(filePath).readAsBytesSync();
      final document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText();
      document.dispose();
      print("📄 Extracted PDF text successfully");
      return text;
    } catch (e) {
      print("❌ Error extracting PDF: $e");
      return '';
    }
  }

  /// 🔹 Extract DOCX text
  static Future<String> _extractDocx(
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      return docxToText(bytes);
    } catch (e) {
      print("❌ Error extracting DOCX: $e");
      return '';
    }
  }

  /// 🔹 Extract TXT text
  static Future<String> _extractTxt(String filePath) async {
    try {
      return await File(filePath).readAsString();
    } catch (e) {
      print("❌ Error reading TXT: $e");
      return '';
    }
  }
}
