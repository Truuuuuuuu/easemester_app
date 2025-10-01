import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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

      // Upload to Cloudinary
      final secureUrl = await _cloudinaryService.uploadFile(
        file,
      );
      if (secureUrl == null) return;

      final newFile = FileCardModel(
        fileName: result.files.first.name,
        fileUrl: secureUrl,
        description: "Uploaded on ${DateTime.now().toLocal()}",
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;

      if (isStudyHub) {
        await _fileRepository.addStudyHubFile(uid, newFile);
        studyHubCards.add(newFile);
      } else {
        await _fileRepository.addFilesTabFile(uid, newFile);
        filesCards.add(newFile);
      }

      notifyListeners();
    } catch (e) {
      print('Error picking/uploading file: $e');
    }
  }
}
