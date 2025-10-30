import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FileViewerPage extends StatelessWidget {
  final String fileUrl;
  final String fileName;

  const FileViewerPage({super.key, required this.fileUrl, required this.fileName});

  bool get _isTxt => fileUrl.toLowerCase().endsWith('.txt');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        centerTitle: true,
      ),
      body: _isTxt
          ? FutureBuilder<http.Response>(
              future: http.get(Uri.parse(fileUrl)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Failed to load file: ${snapshot.error}'));
                }
                final body = snapshot.data?.body ?? '';
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(body),
                  ),
                );
              },
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('In-app viewing is only available for .txt files. Use "Open with another app" to view this file.'),
              ),
            ),
    );
  }
}
