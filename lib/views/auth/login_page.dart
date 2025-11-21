import 'package:easemester_app/views/auth/verification_page.dart';
import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = AuthController();

  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Check empty fields
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔥 MARKED CHANGE: use loginAndCheckVerification instead of login()
      final user = await _authController
          .loginAndCheckVerification(
            email: email,
            password: password,
          );

      if (!mounted) return;

      // 🔥 MARKED CHANGE: user exists but NOT verified
      if (user == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationPage(
              uid: FirebaseAuth.instance.currentUser!.uid,
              email: email,
              name: "User",
            ),
          ),
        );
        return;
      }

      // 🔥 MARKED CHANGE: Verified → proceed to home
      Navigator.pushReplacementNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email';
          break;
        case 'invalid-email':
          message = 'Invalid email';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Wrong password, try again';
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
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 48,
              ),
              physics:
                  const AlwaysScrollableScrollPhysics(),

              // allows content to expand but not overflow
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),

                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1565C0),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --------------------
                      // EMAIL TEXTFIELD
                      // --------------------
                      TextField(
                        controller: _emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                          floatingLabelStyle:
                              const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(
                              12.0,
                            ),
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
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color:
                              theme.colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --------------------
                      // PASSWORD TEXTFIELD
                      // --------------------
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                          floatingLabelStyle:
                              const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(
                              12.0,
                            ),
                            child: Image.asset(
                              'assets/images/icons/password_icon.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: theme.iconTheme.color,
                            ),
                            onPressed: () {
                              setState(
                                () => _isPasswordVisible =
                                    !_isPasswordVisible,
                              );
                            },
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey[850]
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color:
                              theme.colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --------------------
                      // LOGIN BUTTON
                      // --------------------
                      SizedBox(
                        width: width,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF1565C0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: theme
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/register',
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: theme
                                    .colorScheme
                                    .primary,
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
          },
        ),
      ),
    );
  }
}
