import 'package:easemester_app/data/constant.dart';
import 'package:flutter/material.dart';
import '../../../controllers/notes_controller.dart';
import '../../widgets/cards/note_card.dart';
import 'note_detail.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../helpers/dialog_helpers.dart';

class NotesPage extends StatefulWidget {
  final NotesController controller;

  const NotesPage({super.key, required this.controller});

  @override
  NotesPageState createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  NotesController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final filteredNotes = controller.filteredNotes;

        final hasSelection =
            controller.selectionMode &&
            controller.selectedNotes.isNotEmpty;

        // no Scaffold to prevent keyboard overlap
        return SafeArea(
          child: Column(
            children: [
              // Title always visible
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Notes",
                    style: AppFonts.title,
                  ),
                ),
              ),

              // Selection bar
              if (hasSelection)
                Container(
                  
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.selectedNotes.length} selected',
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.trashCan,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                confirmDeleteNotes(
                                  context,
                                  controller,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              controller.clearSelection();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Search bar (only when not in selection mode)
              if (!controller.selectionMode)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: (value) {
                      controller.setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search notes...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(
                        0.05,
                      ),
                    ),
                  ),
                ),

              // Notes grid
              Expanded(
                child: filteredNotes.isEmpty
                    ? Center(
                        child: Text(
                          controller.searchQuery.isNotEmpty
                              ? "Couldn’t find any notes"
                              : "No notes yet. Tap + to add one!",
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredNotes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          final isSelected = controller
                              .selectedNotes
                              .contains(note.id);

                          return GestureDetector(
                            onLongPress: () {
                              if (!controller
                                  .selectionMode) {
                                controller.startSelection(
                                  note.id,
                                );
                              }
                            },
                            onTap: () {
                              if (controller
                                  .selectionMode) {
                                controller.toggleSelection(
                                  note.id,
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NoteDetailPage(
                                          note: note,
                                          controller:
                                              controller,
                                        ),
                                  ),
                                );
                              }
                            },
                            child: NoteCard(
                              note: note,
                              isSelected: isSelected,
                              selectionMode:
                                  controller.selectionMode,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
