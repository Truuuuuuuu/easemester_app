import 'package:cloud_firestore/cloud_firestore.dart';

class FileCardModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final DateTime? timestamp;
  final String? description;
  final String? fileText;
  final Map<String, dynamic>? summaryJson;
  final String? studyHubFileId; // Reference to the StudyHub file ID
  final String publicId;
 

  FileCardModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.timestamp,
    this.description,
    this.fileText,
    this.summaryJson,
    this.studyHubFileId,
    required this.publicId,

  });

  // Convert Firestore document to FileCardModel
  factory FileCardModel.fromMap(
    Map<String, dynamic> data, {
    String? id,
  }) {
    final docId = id ?? data['id'];
    if (docId == null) {
      throw Exception("Firestore document missing 'id'");
    }

    return FileCardModel(
      id: docId,
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
      studyHubFileId: data['studyHubFileId'],
      publicId: data['publicId'],
  
    );
  }

  // Convert to Map for Firestore storage
  Map<String, dynamic> toMap() {
    final map = {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'timestamp':
          timestamp ?? FieldValue.serverTimestamp(),
      'description': description,
      'fileText': fileText,
      'publicId': publicId,

    };

    if (summaryJson != null) {
      map['summaryJson'] = summaryJson;
    }

    if (studyHubFileId != null) {
      map['studyHubFileId'] = studyHubFileId;
    }


    return map;
  }

  FileCardModel copyWith({
    String? id,
    String? fileName,
    String? fileUrl,
    String? description,
    String? fileText,
    Map<String, dynamic>? summaryJson,
    String? studyHubFileId,
    String? publicId,
    String? resourceType,
  }) {
    return FileCardModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      description: description ?? this.description,
      fileText: fileText ?? this.fileText,
      summaryJson: summaryJson ?? this.summaryJson,
      studyHubFileId: studyHubFileId ?? this.studyHubFileId,
      publicId: publicId ?? this.publicId,
 
    );
  }
}
