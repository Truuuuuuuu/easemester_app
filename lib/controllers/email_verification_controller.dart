import 'package:easemester_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class EmailVerificationController extends ChangeNotifier {
  final AuthService authService;

  bool isLoading = false;

  EmailVerificationController({required this.authService});

  // Send verification email
  Future<void> sendVerificationEmail() async {
    isLoading = true;
    notifyListeners();

    try {
      await authService.sendEmailVerification();
    } catch (e) {
      debugPrint('Error sending verification email: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
