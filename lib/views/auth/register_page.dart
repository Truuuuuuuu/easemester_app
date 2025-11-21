import 'package:easemester_app/data/notifiers.dart';
import 'package:easemester_app/models/profile_model.dart';
import 'package:easemester_app/services/firestore_service.dart';
import 'package:easemester_app/views/auth/verification_page.dart';
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

    // Validation checks remain the same...
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
        ),
      );
      return;
    }
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationPage(
              uid: user.uid,
              name: name,
              email: email,
            ),
          ),
        );
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
          .scaffoldBackgroundColor, 
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
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 2),
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

              // NAME TEXTFIELD
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(
                    color: isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/icons/profile_icon.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.grey[850]
                      : Colors.grey[100],

                  // Default border
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),

                  // Non-focused border
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),

                  // Focused border
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/icons/email_icon.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.grey[850]
                      : Colors.grey[100],

                  // Default border
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),

                  // Not focused border
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),

                  // Focused (active) border
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/icons/password_icon.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
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
                    backgroundColor:  Color(0xFF1565C0),
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
                            color: Colors.white, // ✅ Theme-aware button text color
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
