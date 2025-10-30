import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easemester_app/services/openai_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/file_card_model.dart';
import '../repositories/file_repository.dart';
import '../services/cloudinary_service.dart';
import '../services/file_extractor_service.dart';

class HomeController extends ChangeNotifier {
  final TabController tabController;

  List<FileCardModel> studyHubCards = [];
  List<FileCardModel> filesCards = [];

  StreamSubscription<List<FileCardModel>>? _studyHubSub;
  StreamSubscription<List<FileCardModel>>? _filesSub;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService =
      CloudinaryService();
  final FileRepository _fileRepository = FileRepository(
    firestore: FirebaseFirestore.instance,
  );

  HomeController({required this.tabController}) {
    _initStreams();
  }

  int get totalFilesCount =>
      studyHubCards.length + filesCards.length;

  void _initStreams() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    _studyHubSub = _fileRepository
        .studyHubFilesStream(uid)
        .listen((items) {
          studyHubCards = items;
          notifyListeners();
        });

    _filesSub = _fileRepository
        .filesTabFilesStream(uid)
        .listen((items) {
          filesCards = items;
          notifyListeners();
        });
  }

  /// Pick and upload file
  Future<void> pickAndUploadFile({
    required bool isStudyHub,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
      );

      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) return;

      final file = File(path);
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 1️⃣ Upload to Cloudinary
      final uploadResult = await _cloudinaryService
          .uploadFile(file);
      if (uploadResult == null) return;

      final fileUrl = uploadResult['url'];
      final publicId = uploadResult['public_id'];

      // 2️⃣ Create Firestore reference
      final studyHubDocRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('studyHubFiles')
          .doc(); // random ID

      final tempFile = FileCardModel(
        id: studyHubDocRef.id,
        fileName: result.files.first.name,
        fileUrl: fileUrl,
        publicId: publicId,
        description:
            "Uploaded on ${DateTime.now().toLocal()}",
      );

      String? extractedText;
      Map<String, dynamic>? aiFeatures;

      // 3️⃣ Extract text + generate AI content (summary + quiz)
      if (isStudyHub) {
        extractedText =
            await FileExtractor.pickAndExtractFromPath(
              path,
              fileId: studyHubDocRef.id,
            );

        if (extractedText != null &&
            extractedText.isNotEmpty) {
          final openAIService = OpenAIService();

          print("🧠 Generating summary using OpenAI...");
          final summary = await openAIService
              .generateSummary(extractedText);

          print("🚀 Generating short quiz using OpenAI...");
          final quiz = await openAIService
              .generateShortQuiz(summary);

          aiFeatures = {"summary": summary, "quiz": quiz};
        }
      }

      // 4️⃣ Save to Firestore
      final fullFile = tempFile.copyWith(
        fileText: extractedText,
        aiFeatures: aiFeatures,
      );

      await _fileRepository.addStudyHubFile(
        uid,
        fullFile,
        studyHubDocRef.id,
      );

      // 5️⃣ Add to "Files" tab (metadata only)
      final metadataFile = FileCardModel(
        id: studyHubDocRef.id,
        fileName: result.files.first.name,
        fileUrl: fileUrl,
        publicId: publicId,
        description:
            "Uploaded on ${DateTime.now().toLocal()}",
        fileText: null,
        aiFeatures: null,
      );

      await _fileRepository.addFilesTabFile(
        uid,
        metadataFile,
        metadataFile.id,
      );

      print(
        "✅ Uploaded file with StudyHub ID: ${studyHubDocRef.id}",
      );
    } catch (e) {
      print("⚠️ Error uploading file: $e");
    }
  }

  @override
  void dispose() {
    _studyHubSub?.cancel();
    _filesSub?.cancel();
    super.dispose();
  }

  /// Delete file (Cloudinary + Firestore)
  Future<void> deleteFile(
    FileCardModel file,
    BuildContext context,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // 1️⃣ Delete from Cloudinary
      if (file.publicId.isNotEmpty) {
        try {
          await _cloudinaryService.deleteFileByPublicId(
            file.publicId,
          );
          print(
            "✅ Cloudinary file deleted: ${file.fileName}",
          );
        } catch (e) {
          print("⚠️ Cloudinary delete error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Cloudinary delete failed: $e"),
            ),
          );
        }
      }

      // 2️⃣ Delete from Firestore
      await _fileRepository.firestore
          .collection('users')
          .doc(uid)
          .collection('files')
          .doc(file.id)
          .delete();

      await _fileRepository.firestore
          .collection('users')
          .doc(uid)
          .collection('studyHubFiles')
          .doc(file.id)
          .delete();

      print("✅ Firestore file deleted: ${file.fileName}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File deleted successfully"),
        ),
      );

      // 3️⃣ Update local state
      filesCards.removeWhere((f) => f.id == file.id);
      studyHubCards.removeWhere((f) => f.id == file.id);
      notifyListeners();
    } catch (e) {
      print("❌ Error deleting file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete file: $e"),
        ),
      );
    }
  }
}
