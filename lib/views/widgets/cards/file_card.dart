import 'package:easemester_app/models/file_card_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileCardWidget extends StatelessWidget {
  final FileCardModel fileCard;
  final VoidCallback onTap;

  const FileCardWidget({
    super.key,
    required this.fileCard,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.insert_drive_file,
          size: 40,
        ),
        title: Text(
          fileCard.fileName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: fileCard.timestamp != null
            ? Text(
                DateFormat('MMM dd, yyyy – HH:mm')
                    .format(fileCard.timestamp!),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
