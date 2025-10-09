import 'package:cloud_firestore/cloud_firestore.dart';

class FileCardModel {
  final String fileName;
  final String fileUrl;
  final DateTime? timestamp;
  final String? description;
  final String? fileText;
  final Map<String, dynamic>? summaryJson;

  FileCardModel({
    required this.fileName,
    required this.fileUrl,
    this.timestamp,
    this.description,
    this.fileText,
    this.summaryJson,
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
      fileText: data['fileText'],
      summaryJson: data['summaryJson'] != null
          ? Map<String, dynamic>.from(data['summaryJson'])
          : null,
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
      'fileText': fileText,
      'summaryJson': summaryJson,
    };
  }

  FileCardModel copyWith({
    String? fileName,
    String? fileUrl,
    String? description,
    String? fileText,
    Map<String, dynamic>? summaryJson,
  }) {
    return FileCardModel(
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      description: description ?? this.description,
      fileText: fileText ?? this.fileText,
      summaryJson: summaryJson ?? this.summaryJson,
    );
  }
}
