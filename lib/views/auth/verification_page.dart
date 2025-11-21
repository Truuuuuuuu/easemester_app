import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easemester_app/services/auth_service.dart';
import 'package:easemester_app/services/firestore_service.dart';
import 'package:easemester_app/models/profile_model.dart';
import 'package:easemester_app/data/notifiers.dart';

class EmailVerificationPage extends StatefulWidget {
  final String name;
  final String email;
  final String uid;

  const EmailVerificationPage({
    super.key,
    required this.name,
    required this.email,
    required this.uid,
  });

  @override
  State<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState
    extends State<EmailVerificationPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _message;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startEmailVerificationPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      final isVerified = await _authService
          .isEmailVerified();
      if (isVerified && mounted) {
        timer.cancel();
        await _saveVerifiedUser();
        _navigateToHome();
      }
    });
  }

  Future<void> _saveVerifiedUser() async {
    final newUser = UserModel(
      uid: widget.uid,
      name: widget.name,
      email: widget.email,
      profileImageUrl: '',
    );
    await FirestoreService().saveUser(newUser);
    currentUserNotifier.value = newUser;
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verification"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: Image.asset(
                            'assets/images/icons/gmail_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          "Verify Your Email",
                          style: theme.textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "A verification email has been sent to",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : _sendVerificationEmail,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Resend Email"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(
                                  255,
                                  12,
                                  125,
                                  216,
                                ),
                            minimumSize:
                                const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (_message != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _message!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  _message!.startsWith(
                                    "Error",
                                  )
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text(
                            "Back to Registration",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
