import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easemester_app/services/file_extractor_service.dart';
import 'package:easemester_app/services/summary_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/file_card_model.dart';
import '../repositories/file_repository.dart';
import '../services/cloudinary_service.dart';

class HomeController extends ChangeNotifier {
  final TabController tabController;

  List<FileCardModel> studyHubCards = [];
  List<FileCardModel> filesCards = [];

  final CloudinaryService _cloudinaryService =
      CloudinaryService();
  final FileRepository _fileRepository = FileRepository(
    firestore: FirebaseFirestore.instance,
  );

  HomeController({required this.tabController}) {
    fetchFilesFromFirestore();
  }

  // Total files counter
  int get totalFilesCount =>
      studyHubCards.length + filesCards.length;

  Future<void> fetchFilesFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    studyHubCards = await _fileRepository.getStudyHubFiles(
      uid,
    );
    filesCards = await _fileRepository.getFilesTabFiles(
      uid,
    );
    notifyListeners();
  }

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

      // Extract text from file
      final extractedText =
          await FileExtractor.pickAndExtractFromPath(path);
      print("📝 Extracted text:\n$extractedText");

      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Check for duplicates
      List<FileCardModel> existingFiles = isStudyHub
          ? await _fileRepository.getStudyHubFiles(uid)
          : await _fileRepository.getFilesTabFiles(uid);

      FileCardModel? existingFile;
      try {
        existingFile = existingFiles.firstWhere(
          (f) => f.fileName == result.files.first.name,
        );
      } catch (_) {
        existingFile = null;
      }

      // Summarize only if needed
      Map<String, dynamic>? summaryJson;
      if (existingFile != null &&
          existingFile.summaryJson != null) {
        summaryJson = existingFile.summaryJson;
      } else if (extractedText != null) {
        summaryJson = await SummaryService.summarizeText(
          extractedText,
        );
      }

      print("🧠 Summary JSON:\n$summaryJson");

      // Upload to Cloudinary
      final secureUrl = await _cloudinaryService.uploadFile(
        file,
      );
      if (secureUrl == null) return;

      // Create FileCardModel
      final newFile = FileCardModel(
        fileName: result.files.first.name,
        fileUrl: secureUrl,
        description:
            "Uploaded on ${DateTime.now().toLocal()}",
        fileText: extractedText,
        summaryJson: summaryJson,
      );

      // Save to Firestore
      if (isStudyHub) {
        await _fileRepository.addStudyHubFile(uid, newFile);
        studyHubCards.add(newFile);
      } else {
        await _fileRepository.addFilesTabFile(uid, newFile);
        filesCards.add(newFile);
      }

      notifyListeners();
    } catch (e) {
      print('⚠️ Error picking/uploading file: $e');
    }
  }

  /// ✅ New: Trigger summarization from StudyCard onTap()
  Future<String?> summarizeAndSave(
    FileCardModel file,
  ) async {
    try {
      print(
        "📄 Starting summarization for: ${file.fileName}",
      );

      // Extract text (if not already available)
      final text =
          file.fileText ??
          await FileExtractor.pickAndExtractFromPath(
            file.fileUrl,
          );

      if (text == null || text.isEmpty) {
        print("⚠️ No text to summarize");
        return "No text found in file.";
      }

      // Summarize
      final summaryJson =
          await SummaryService.summarizeText(text);
      print("✅ Summary result: $summaryJson");

      // Save summary to Firestore
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _fileRepository.updateFileSummary(
        uid,
        file.fileName,
        summaryJson,
      );

      // Update local state
      final updatedFile = file.copyWith(
        summaryJson: summaryJson,
      );
      final index = studyHubCards.indexWhere(
        (f) => f.fileName == file.fileName,
      );
      if (index != -1) studyHubCards[index] = updatedFile;

      notifyListeners();

      return summaryJson['summary'] ?? 'No summary found';
    } catch (e) {
      print("⚠️ Error during summarization: $e");
      return null;
    }
  }
}
