import 'package:easemester_app/controllers/checklist_controller.dart';
import 'package:easemester_app/controllers/home_controller.dart';
import 'package:easemester_app/models/profile_model.dart';
import 'package:easemester_app/repositories/checklist_repository.dart';
import 'package:easemester_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0); //which page
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false); //theme
// ValueNotifier<int> tabIndexNotifier = ValueNotifier(0); //in homepage tabs

ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier<UserModel?>(null);

//pending task 
final checklistControllerNotifier = ChecklistController(
    repository: ChecklistRepository(
      firestoreService: FirestoreService(),
    ),
    uid: FirebaseAuth.instance.currentUser?.uid ?? "",
);

