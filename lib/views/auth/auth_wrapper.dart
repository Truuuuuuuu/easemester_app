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
          return FutureBuilder(
            future: FirestoreService().getCurrentUser(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (userSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text(
                      "Error: ${userSnapshot.error}",
                    ),
                  ),
                );
              }

              if (userSnapshot.hasData) {
                // Update notifier only if different
                if (currentUserNotifier.value?.uid !=
                    userSnapshot.data?.uid) {
                  currentUserNotifier.value =
                      userSnapshot.data;
                }
                return const WidgetTree();
              }

              return const LoginPage();
            },
          );
        }

        // Not logged in → go to login page
        return const LoginPage();
      },
    );
  }
}
