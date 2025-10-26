import 'package:easemester_app/data/notifiers.dart';
import 'package:easemester_app/models/profile_model.dart';
import 'package:easemester_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController _authController = AuthController();

  final TextEditingController _nameController =
      TextEditingController();
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate name
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
        ),
      );
      return;
    }

    // Enforce Gmail-only emails
    if (!RegExp(r'^[\w.+-]+@gmail\.com$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid Gmail address',
          ),
        ),
      );
      return;
    }
    // Enforce strong password: min 6 characters, at least 1 uppercase, 1 number
    if (!RegExp(
      r'^(?=.*[A-Z])(?=.*\d).{6,}$',
    ).hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 6 characters, include 1 uppercase letter and 1 number',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authController.register(
        name: name,
        email: email,
        password: password,
      );

      if (user != null && mounted) {
        // Build a UserModel right after registration
        final newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          profileImageUrl: '', // empty by default
        );

        // Save to Firestore
        await FirestoreService().saveUser(newUser);

        // Update notifier immediately so AppBar shows correct data
        currentUserNotifier.value = newUser;

        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message =
              'Password should be at least 6 characters.';
          break;
        default:
          message = 'Authentication error: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context); // ✅ Get current theme
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme
          .scaffoldBackgroundColor, // ✅ Theme-aware background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme
                      .colorScheme
                      .onSurface, // ✅ Theme-aware text color
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign up to continue",
                style: TextStyle(
                  color: theme.colorScheme.onSurface
                      .withOpacity(
                        0.7,
                      ), // ✅ Theme-aware secondary text
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  prefixIcon: Icon(
                    Icons.person,
                    color: theme
                        .iconTheme
                        .color, // ✅ Theme-aware icon color
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.grey[850]
                      : Colors
                            .grey[100], // ✅ Conditional fill color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: theme
                      .colorScheme
                      .onSurface, // ✅ Theme-aware text input color
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(
                    Icons.email,
                    color: theme
                        .iconTheme
                        .color, // ✅ Theme-aware icon color
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.grey[850]
                      : Colors
                            .grey[100], // ✅ Conditional fill color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: theme
                      .colorScheme
                      .onSurface, // ✅ Theme-aware text input color
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: theme
                        .iconTheme
                        .color, // ✅ Theme-aware icon color
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.grey[850]
                      : Colors
                            .grey[100], // ✅ Conditional fill color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: theme
                      .colorScheme
                      .onSurface, // ✅ Theme-aware text input color
                ),
              ),
              const SizedBox(height: 32),

              // Register button
              SizedBox(
                width: width,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme
                        .colorScheme
                        .primary, // ✅ Theme-aware button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme
                                .colorScheme
                                .onPrimary, // ✅ Theme-aware button text color
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: theme
                          .colorScheme
                          .onSurface, // ✅ Theme-aware text color
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/login',
                      );
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .primary, // ✅ Theme-aware link color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
