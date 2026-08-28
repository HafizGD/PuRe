import 'package:flutter/material.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onGuestLogin;

  const LoginScreen({
    Key? key,
    required this.onLoginSuccess,
    required this.onGuestLogin,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Text controllers for input fields
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoggingIn = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi: username dan password harus diisi
    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Username dan Password harus diisi!');
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      // Validasi dengan database
      final result = await AppPreferences.validateLogin(username, password);
      if (result['success'] == true) {
        // Login berhasil
        widget.onLoginSuccess();
      } else {
        // Login gagal
        if (mounted) {
          _showSnackBar(result['message'] ?? 'Username atau Password salah!');
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        _showSnackBar('Error saat login: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  void _handleRegister() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi: username dan password harus diisi
    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Username dan Password harus diisi!');
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      // Simpan data user ke database
      final result = await AppPreferences.registerUser(username, password);
      if (result['success'] == true) {
        if (mounted) {
          _showSuccessSnackBar(result['message'] ?? 'Registrasi berhasil! Silakan login.');
          // Clear password field setelah registrasi
          _passwordController.clear();
        }
      } else {
        if (mounted) {
          _showSnackBar(result['message'] ?? 'Registrasi gagal!');
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        _showSnackBar('Error saat registrasi: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            // Padding sesuai CSS: 160px top/bottom, 24px left/right
            padding: const EdgeInsets.only(top: 160, bottom: 160, left: 24, right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text Content Title - sesuai CSS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title: "PuRe:" - sesuai gambar
                    SizedBox(
                      width: 296,
                      child: const Text(
                        'PuRe:',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 72,
                          fontWeight: FontWeight.w700,
                          height: 1.2, // line-height 120%
                          letterSpacing: -0.03,
                          color: Color(0xFF1E1E1E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8), // gap 8px sesuai CSS
                    // Subtitle: "Puzzle & Reasoning" - sesuai gambar
                    SizedBox(
                      width: 296,
                      child: const Text(
                        'Puzzle & Reasoning',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          height: 1.2, // line-height 120%
                          color: Color(0xFF757575),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32), // gap 32px sesuai CSS
                // Username Input Field
                Container(
                  width: 233,
                  height: 41,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3E3),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _usernameController,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      color: Color(0xFF1E1E1E),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // spacing antara input fields
                // Password Input Field
                Container(
                  width: 233,
                  height: 41,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3E3),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      color: Color(0xFF1E1E1E),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 32), // spacing sebelum tombol
                // Buttons: Login dan Register bersebelahan (horizontal)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Login Button (light grey)
                    GestureDetector(
                      onTap: (_isLoggingIn || _isRegistering) ? null : _handleLogin,
                      child: Container(
                        width: 110, // Lebar disesuaikan agar 2 tombol muat
                        height: 41,
                        decoration: BoxDecoration(
                          color: (_isLoggingIn || _isRegistering) 
                              ? const Color(0xFF9E9E9E) 
                              : const Color(0xFFE3E3E3),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoggingIn
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E1E1E)),
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    height: 1.0,
                                    color: Color(0xFF1E1E1E),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 13), // spacing antara Login dan Register
                    // Register Button (light grey)
                    GestureDetector(
                      onTap: (_isLoggingIn || _isRegistering) ? null : _handleRegister,
                      child: Container(
                        width: 110, // Lebar disesuaikan agar 2 tombol muat
                        height: 41,
                        decoration: BoxDecoration(
                          color: (_isLoggingIn || _isRegistering) 
                              ? const Color(0xFF9E9E9E) 
                              : const Color(0xFFE3E3E3),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isRegistering
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E1E1E)),
                                  ),
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    height: 1.0,
                                    color: Color(0xFF1E1E1E),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // spacing sebelum Guest button
                // Guest Button (dark grey - di bawah Login dan Register)
                GestureDetector(
                  onTap: widget.onGuestLogin,
                  child: Container(
                    width: 233,
                    height: 41,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Guest',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                          color: Color(0xFFF5F5F5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

