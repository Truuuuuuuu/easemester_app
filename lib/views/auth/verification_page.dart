import 'dart:async';
import 'package:easemester_app/services/auth_service.dart';
import 'package:easemester_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:easemester_app/models/profile_model.dart';
import 'package:easemester_app/data/notifiers.dart';

class EmailVerificationPage extends StatefulWidget {
  final String
  name; // ✅ CHANGED: pass user name from registration
  final String
  email; // ✅ CHANGED: pass user email from registration
  final String uid; // ✅ CHANGED: pass Firebase UID
  const EmailVerificationPage({
    super.key,
    required this.name,
    required this.email,
    required this.uid,
  });

  @override
  State<EmailVerificationPage> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends State<EmailVerificationPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _message;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    //Polling for email verification
    _timer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      final isVerified = await _authService
          .isEmailVerified();
      if (isVerified && mounted) {
        timer.cancel();

        // Write to Firestore only AFTER verification
        final newUser = UserModel(
          uid: widget.uid,
          name: widget.name,
          email: widget.email,
          profileImageUrl: '',
        );
        await FirestoreService().saveUser(newUser);

        currentUserNotifier.value = newUser;

        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _authService.sendEmailVerification();
      setState(() {
        _message =
            "Verification email sent! Please check your inbox.";
      });
    } catch (e) {
      setState(() {
        _message = "Error sending verification email: $e";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
            ); // ✅ CHANGED: Back to registration page
          },
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Text(
                      "A verification email has been sent to your email address. "
                      "Please check your inbox and verify your email before logging in.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _sendVerificationEmail,
                      child: const Text(
                        "Resend Verification Email",
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              _message!.startsWith("Error")
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
