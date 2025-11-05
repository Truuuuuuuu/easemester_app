import 'package:flutter/material.dart';

class ChecklistCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool done;
  final bool selectionMode;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isEditing;
  final TextEditingController? editingController;
  final VoidCallback? onEditingComplete;

  const ChecklistCard({
    super.key,
    required this.title,
    this.description,
    required this.done,
    required this.selectionMode,
    required this.isSelected,
    required this.onChanged,
    this.onTap,
    this.onLongPress,
    this.isEditing = false,
    this.editingController,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isSelected
                ? Colors.blue
                : Colors.grey,
            width: isSelected ? 2 : 0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 1,
        child: ListTile(
          //reflects the `done` state
          leading: Checkbox(
            value: done,
            onChanged: onChanged,
          ),
          title: isEditing
              ? TextField(
                  controller: editingController,
                  autofocus: true,
                  onEditingComplete: onEditingComplete,
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
          subtitle:
              description != null && description!.isNotEmpty
              ? Text(
                  description!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    decoration: done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
