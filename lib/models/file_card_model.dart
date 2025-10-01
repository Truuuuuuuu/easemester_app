import 'package:cloud_firestore/cloud_firestore.dart';

class FileCardModel {
  final String fileName;
  final String fileUrl;
  final DateTime? timestamp;
  final String? description;

  FileCardModel({
    required this.fileName,
    required this.fileUrl,
    this.timestamp,
    this.description,
  });

  // Convert Firestore document to FileCardModel
  factory FileCardModel.fromMap(Map<String, dynamic> data) {
    return FileCardModel(
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
      description: data['description'],
    );
  }

  // Convert to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'timestamp':
          timestamp ?? FieldValue.serverTimestamp(),
      'description': description,
    };
  }
}
