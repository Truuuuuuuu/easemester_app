import 'package:easemester_app/controllers/notes_controller.dart';
import 'package:easemester_app/models/note_model.dart';
import 'package:flutter/material.dart';

class NoteDetailPage extends StatefulWidget {
  final NoteModel note;
  final NotesController controller;

  const NoteDetailPage({
    super.key,
    required this.note,
    required this.controller,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  // Automatically save note when user leaves or presses back
  void _saveNote() {
    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      updatedAt: DateTime.now(),
    );

    widget.controller.updateNote(updatedNote);
  }

  @override
  void dispose() {
    _saveNote(); //ensure note saves even if widget disposes unexpectedly
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveNote(); // Save automatically when pressing back
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color,
              size: 20,
            ),
            onPressed: () {
              _saveNote(); //Save before popping
              Navigator.pop(context);
            },
          ),
          title: Hero(
            tag: widget.note.title,
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Title", // MARKED: hint for clarity
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Hero(
              tag: '${widget.note.title}-content',
              child: Material(
                type: MaterialType.transparency,
                child: TextField(
                  controller: _contentController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: null,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter a note", // placeholder when empty
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
