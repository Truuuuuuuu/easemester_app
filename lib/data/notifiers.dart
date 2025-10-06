import 'package:easemester_app/controllers/checklist_controller.dart';
import 'package:easemester_app/models/profile_model.dart';
import 'package:easemester_app/repositories/checklist_repository.dart';
import 'package:easemester_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0); //which page
// ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false); //theme
// ValueNotifier<int> tabIndexNotifier = ValueNotifier(0); //in homepage tabs

ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier<UserModel?>(null);

//darkmode
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

Future<void> initTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getBool('isDarkMode') ?? false;
  isDarkModeNotifier.value = savedTheme;
}

Future<void> toggleTheme() async {
  final prefs = await SharedPreferences.getInstance();
  isDarkModeNotifier.value = !isDarkModeNotifier.value;
  await prefs.setBool('isDarkMode', isDarkModeNotifier.value);
}


//pending task 
final checklistControllerNotifier = ChecklistController(
    repository: ChecklistRepository(
      firestoreService: FirestoreService(),
    ),
    uid: FirebaseAuth.instance.currentUser?.uid ?? "",
);

