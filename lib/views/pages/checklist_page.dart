import 'package:easemester_app/data/constant.dart';
import 'package:easemester_app/helpers/dialog_helpers.dart';
import 'package:easemester_app/views/widgets/cards/checklist_card.dart';
import 'package:flutter/material.dart';
import 'package:easemester_app/controllers/checklist_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChecklistPage extends StatefulWidget {
  final ChecklistController controller;

  const ChecklistPage({
    super.key,
    required this.controller,
  });

  @override
  ChecklistPageState createState() => ChecklistPageState();
}

class ChecklistPageState extends State<ChecklistPage> {
  ChecklistController get controller => widget.controller;

  // Track which item is being edited
  String? _editingItemId;
  final Map<String, TextEditingController>
  _editingControllers = {};

  /// Called from FAB to add a new checklist item
  Future<void> addChecklistCardDialog() async {
    final dialogController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Checklist Item'),
        content: TextField(
          controller: dialogController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter item title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, dialogController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white, 
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      controller.addItem(result.trim());
    }
  }

  /// Save changes for a checklist item
  Future<void> _saveItem(String id) async {
    final controllerText =
        _editingControllers[id]?.text ?? "";
    if (controllerText.trim().isEmpty) {
      await controller.deleteItem(id);

      // Exit selection mode if item deleted
      setState(() {
        controller.clearSelection();
        _editingItemId = null;
      });
    } else {
      final item = controller.items.firstWhere(
        (element) => element.id == id,
      );
      final updatedItem = item.copyWith(
        title: controllerText,
        updatedAt: DateTime.now(),
      );
      await controller.repository.updateItem(
        controller.uid,
        updatedItem,
      );

      setState(() {
        _editingItemId = null;
      });
    }
  }

  @override
  void dispose() {
    for (var c in _editingControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top label + selection info
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text("Checklist", style: AppFonts.title),
          ),
        ),

        //selection mode info (only visible when selectionMode active)
        if (controller.selectionMode &&
            controller.selectedTasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.selectedTasks.length} selected',
                ),
                Row(
                  children: [
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.trashCan,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        await confirmDeleteTasks(
                          context,
                          controller,
                        );
                        setState(() {
                          controller.clearSelection();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          controller.clearSelection();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Checklist items
        Expanded(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final items = controller.items;

              if (items.isEmpty) {
                // Auto exit selection mode if no items
                if (controller.selectionMode) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) {
                        setState(() {
                          controller.selectionMode = false;
                        });
                      });
                }
                return const Center(
                  child: Text("No checklist items yet"),
                );
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  _editingControllers.putIfAbsent(
                    item.id,
                    () => TextEditingController(
                      text: item.title,
                    ),
                  );

                  final isEditing =
                      _editingItemId == item.id;
                  final isSelected = controller
                      .selectedTasks
                      .contains(item.id);

                  return ChecklistCard(
                    title: item.title,
                    description: null,
                    done: item.completed,
                    selectionMode: controller.selectionMode,
                    isSelected: isSelected,
                    editingController: isEditing
                        ? _editingControllers[item.id]
                        : null,
                    isEditing: isEditing,
                    onEditingComplete: () =>
                        _saveItem(item.id),
                    onChanged: controller.selectionMode
                        ? (_) {}
                        : (_) => controller.toggleCompleted(
                            item,
                          ),
                    onTap: () {
                      if (controller.selectionMode) {
                        setState(() {
                          if (isSelected) {
                            controller.selectedTasks.remove(
                              item.id,
                            );
                          } else {
                            controller.selectedTasks.add(
                              item.id,
                            );
                          }
                          if (controller
                              .selectedTasks
                              .isEmpty) {
                            controller.selectionMode =
                                false;
                          }
                        });
                      } else {
                        setState(() {
                          _editingItemId = item.id;
                        });
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        controller.startSelection(item.id);
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
