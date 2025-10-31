import 'package:flutter/material.dart';
import 'package:easemester_app/controllers/home_controller.dart';
import 'package:easemester_app/controllers/notes_controller.dart';
import 'package:easemester_app/controllers/checklist_controller.dart';
import 'package:easemester_app/views/pages/notes%20page/notes_page.dart';
import 'package:easemester_app/views/pages/checklist_page.dart';
import 'package:easemester_app/data/notifiers.dart';
import 'package:easemester_app/data/constant.dart';
import 'package:easemester_app/routes/navigation_helper.dart';

class CustomFAB extends StatelessWidget {
  final HomeController homeController;
  final NotesController notesController;
  final ChecklistController checklistController;
  final GlobalKey<NotesPageState>? notesPageKey;
  final GlobalKey<ChecklistPageState>? checklistPageKey;

  const CustomFAB({
    super.key,
    required this.homeController,
    required this.notesController,
    required this.checklistController,
    this.notesPageKey,
    this.checklistPageKey,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, _) {
        if (selectedPage == 0) {
          // HomePage FAB
          return _buildFab(() async {
            final tabIndex =
                homeController.tabController?.index ?? 0;

            if (tabIndex == 0) {
              // Study Hub tab → add file to Study Hub subcollection
              await homeController.pickAndUploadFile(
                isStudyHub: true,
              );
            } else if (tabIndex == 1) {
              // Files tab → add file to Files tab subcollection
              await homeController.pickAndUploadFile(
                isStudyHub: false,
              );
            }
          });
        } else if (selectedPage == 1) {
          // NotesPage FAB
          return _buildFab(() {
            NavigationHelper.goToAddNote(
              context,
              notesController,
            );
          });
        } else if (selectedPage == 2) {
          // ChecklistPage FAB
          return _buildFab(() {
            checklistPageKey?.currentState
                ?.addChecklistCardDialog();
          });
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFab(VoidCallback onPressed) {
    return SizedBox(
      width: 70,
      height: 70,
      child: FloatingActionButton(
        onPressed: onPressed,
        shape: const CircleBorder(),
        backgroundColor: AppColor.whiteBackground,
        child: const Icon(
          Icons.add,
          size: 42,
          color: Colors.black,
        ),
      ),
    );
  }
}
