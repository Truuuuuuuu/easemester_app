import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easemester_app/repositories/achivement_repository.dart';
import 'package:easemester_app/services/openai_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/file_card_model.dart';
import '../repositories/file_repository.dart';
import '../services/cloudinary_service.dart';
import '../services/file_extractor_service.dart';

class HomeController extends ChangeNotifier {
  final TabController? tabController;

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
  final AchievementRepository _achievementRepository =
      AchievementRepository(
        firestore: FirebaseFirestore.instance,
      );

  HomeController({required this.tabController}) {
    _initStreams();
  }

  // Lightweight constructor for AI-only operations (no TabController, no streams)
  HomeController.aiTools() : tabController = null;

  int get totalFilesCount =>
      studyHubCards.length + filesCards.length;

  void _initStreams() {
    if (tabController == null) {
      // Streams are only relevant when a TabController is present
      return;
    }
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

  /// Pick and upload file (metadata only for both StudyHub and Files)
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
      // Firestore doc (studyHubFiles or files)
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection(
            isStudyHub ? 'studyHubFiles' : 'files',
          )
          .doc();
      final fileCard = FileCardModel(
        id: docRef.id,
        fileName: result.files.first.name,
        fileUrl: fileUrl,
        publicId: publicId,
        description:
            "Uploaded on ${DateTime.now().toLocal()}",
      );
      if (isStudyHub) {
        await _fileRepository.addStudyHubFile(
          uid,
          fileCard,
          docRef.id,
        );
      } else {
        await _fileRepository.addFilesTabFile(
          uid,
          fileCard,
          docRef.id,
        );
      }
      await _achievementRepository.incrementFilesUploaded(
        uid,
      );

      print(
        "✅ Uploaded file with ${isStudyHub ? 'StudyHub' : 'Files'} ID: ${docRef.id}",
      );
    } catch (e) {
      print("⚠️ Error uploading file: $e");
    }
  }

  /// Extract and run AI features on a file (Files tab on demand)
  Future<FileCardModel?> runExtractionAndAI(
    FileCardModel file, {
    bool isStudyHub = false,
  }) async {
    try {
      final path = file.fileUrl;
      String? extractedText =
          await FileExtractor.pickAndExtractFromPath(
            path,
            fileId: file.id,
            isStudyHub: isStudyHub,
          );
      if (extractedText == null || extractedText.isEmpty)
        return null;
      final openAIService = OpenAIService();
      final summary = await openAIService.generateSummary(
        extractedText,
      );
      final quiz = await openAIService.generateShortQuiz(
        summary,
      );
      final flashcards = await openAIService
          .generateFlashcards(extractedText);
      final aiFeatures = {
        "summary": summary,
        "quiz": quiz,
        "flashcards": flashcards,
        "quizAnswers": {
          "userAnswers": {},
          "isCompleted": false,
          "score": 0,
        },
      };
      final updatedFile = file.copyWith(
        fileText: extractedText,
        aiFeatures: aiFeatures,
      );
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await _achievementRepository.incrementAllFeatures(
        uid: uid,
        generatedSummary: true,
        generatedFlashcards: true,
        generatedQuiz: true,
      );

      if (isStudyHub) {
        // Only update studyHubFiles collection for StudyHub items
        await _fileRepository.addStudyHubFile(
          uid,
          updatedFile,
          updatedFile.id,
        );
        // Update local state (for reactivity)
        final index = studyHubCards.indexWhere(
          (f) => f.id == file.id,
        );
        if (index >= 0) {
          studyHubCards[index] = updatedFile;
          notifyListeners();
        }
      } else {
        // Only update the files collection and local state for Files tab, never from StudyHub flow!
        final index = filesCards.indexWhere(
          (f) => f.id == file.id,
        );
        if (index >= 0) {
          filesCards[index] = updatedFile;
          notifyListeners();
        }
      }
      return updatedFile;
    } catch (e) {
      print("❌ Error running extraction & AI: $e");
      return null;
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
