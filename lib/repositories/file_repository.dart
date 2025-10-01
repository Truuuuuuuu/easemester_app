import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/file_card_model.dart';

class FileRepository {
  final FirebaseFirestore firestore;

  FileRepository({required this.firestore});

  // Add file to Study Hub
  Future<void> addStudyHubFile(
    String uid,
    FileCardModel file,
  ) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('studyHubFiles')
        .add(file.toMap());
  }

  // Add file to Files tab
  Future<void> addFilesTabFile(
    String uid,
    FileCardModel file,
  ) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('files')
        .add(file.toMap());
  }

  // Get Study Hub files
  Future<List<FileCardModel>> getStudyHubFiles(
    String uid,
  ) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('studyHubFiles')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FileCardModel.fromMap(doc.data()))
        .toList();
  }

  // Get Files tab files
  Future<List<FileCardModel>> getFilesTabFiles(
    String uid,
  ) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('files')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FileCardModel.fromMap(doc.data()))
        .toList();
  }
}
