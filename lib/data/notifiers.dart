import 'package:easemester_app/models/profile_model.dart';
import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0); //which page
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false); //theme
// ValueNotifier<int> tabIndexNotifier = ValueNotifier(0); //in homepage tabs

ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier<UserModel?>(null);