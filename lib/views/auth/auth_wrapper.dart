import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easemester_app/views/auth/login_page.dart';
import 'package:easemester_app/views/widget_tree.dart';
import 'package:easemester_app/data/notifiers.dart';
import 'package:easemester_app/services/firestore_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // User is logged in → fetch user data from Firestore
          FirestoreService().getCurrentUser().then((user) {
            currentUserNotifier.value = user;
          });

          return const WidgetTree();
        }

        // Not logged in → go to login page
        return const LoginPage();
      },
    );
  }
}
