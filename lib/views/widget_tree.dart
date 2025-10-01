import 'package:easemester_app/repositories/checklist_repository.dart';
import 'package:easemester_app/repositories/notes_repository.dart';
import 'package:easemester_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../controllers/notes_controller.dart';
import '../controllers/checklist_controller.dart';
import '../views/pages/home_page.dart';
import 'pages/notes page/notes_page.dart';
import '../views/pages/checklist_page.dart';
import 'pages/profile page/profile_page.dart';
import '../views/widgets/custom_appbar.dart';
import 'widgets/navbar_widget.dart';
import 'widgets/app_drawer.dart';
import 'widgets/fab_widget.dart';
import '../data/notifiers.dart';

final GlobalKey<NotesPageState> notesPageKey =
    GlobalKey<NotesPageState>();
final GlobalKey<ChecklistPageState> checklistPageKey =
    GlobalKey<ChecklistPageState>();

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final HomeController _homeController;
  late final NotesController _notesController;
  late final ChecklistController _checklistController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _homeController = HomeController(
      tabController: _tabController,
    );
    final currentUid =
        FirebaseAuth.instance.currentUser!.uid;

    _notesController = NotesController(
      repository: NotesRepository(
        firestoreService: FirestoreService(),
      ),
      uid: currentUid,
    );
    _checklistController = ChecklistController(
      repository: ChecklistRepository(
        firestoreService: FirestoreService(),
      ),
      uid: currentUid,
    );

    selectedPageNotifier.value = 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(controller: _homeController),
      NotesPage(
        key: notesPageKey,
        controller: _notesController,
      ),
      ChecklistPage(
        key: checklistPageKey,
        controller: _checklistController,
      ),
      ProfilePage(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(),
      endDrawer: const AppDrawer(),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return IndexedStack(
            index: selectedPage,
            children: pages,
          );
        },
      ),
      floatingActionButton: CustomFAB(
        homeController: _homeController,
        notesController: _notesController,
        checklistController: _checklistController,
        notesPageKey: notesPageKey,
        checklistPageKey: checklistPageKey,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
