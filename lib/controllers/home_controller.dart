import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/file_card_model.dart';
import '../repositories/file_repository.dart';
import '../services/cloudinary_service.dart';
import '../services/file_extractor_service.dart';
import '../services/summary_service.dart';

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

      // Upload to Cloudinary
      final uploadResult = await _cloudinaryService
          .uploadFile(file);
      if (uploadResult == null) return;

      final fileUrl = uploadResult['url'];
      final publicId = uploadResult['public_id'];

      // ----------------------
      // StudyHubFiles: metadata + extracted + summary
      // ----------------------
      final studyHubDocRef = FirebaseFirestore.instance
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
      Map<String, dynamic>? summaryJson;

      if (isStudyHub) {
        extractedText =
            await FileExtractor.pickAndExtractFromPath(
              path,
              fileId: studyHubDocRef.id,
            );

        if (extractedText != null &&
            extractedText.isNotEmpty) {
          summaryJson = await SummaryService.summarizeText(
            extractedText,
          );
        }
      }

      final fullFile = tempFile.copyWith(
        fileText: extractedText,
        summaryJson: summaryJson,
      );

      await _fileRepository.addStudyHubFile(
        uid,
        fullFile,
        studyHubDocRef.id,
      );

      // ----------------------
      // Files: metadata only
      // ----------------------
      final metadataFile = FileCardModel(
        id: studyHubDocRef
            .id, // same ID for optional mapping or separate if desired
        fileName: result.files.first.name,
        fileUrl: fileUrl,
        publicId: publicId,
        description:
            "Uploaded on ${DateTime.now().toLocal()}",
        fileText: null,
        summaryJson: null,
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

  /// Summarize and update
  Future<String?> summarizeAndSave(
    FileCardModel file,
  ) async {
    try {
      final text =
          file.fileText ??
          await FileExtractor.pickAndExtractFromPath(
            file.fileUrl,
            fileId: file.id!,
          );

      if (text == null || text.isEmpty)
        return "No text found.";

      final summaryJson =
          await SummaryService.summarizeText(text);

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _fileRepository.updateFileSummary(
        uid,
        file.id!,
        summaryJson,
      );

      final updatedFile = file.copyWith(
        summaryJson: summaryJson,
        fileText: text,
      );

      final index = studyHubCards.indexWhere(
        (f) => f.id == file.id,
      );
      if (index != -1) studyHubCards[index] = updatedFile;

      notifyListeners();

      return summaryJson['summary'] ?? 'No summary found';
    } catch (e) {
      print("⚠️ Error summarizing file: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _studyHubSub?.cancel();
    _filesSub?.cancel();
    super.dispose();
  }

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

      // 2️Delete from Firestore
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
