import 'package:flutter/material.dart';
import '../main.dart';

class HomepageScreen extends StatelessWidget {
  final VoidCallback onPuzzle;
  final VoidCallback onHome;
  final VoidCallback? onLogout;
  final VoidCallback? onLogin;

  const HomepageScreen({
    Key? key,
    required this.onPuzzle,
    required this.onHome,
    this.onLogout,
    this.onLogin,
  }) : super(key: key);

  bool get _isGuest {
    final username = AppPreferences.currentUsername;
    return username == 'Guest' || AppPreferences.currentUserId == null;
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = _isGuest;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title Section
            Column(
              children: [
                const Text(
                  'PuRe:',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -0.03,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Puzzle & Reasoning',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF757575),
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Button Group
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Puzzle Button
                ElevatedButton(
                  onPressed: onPuzzle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE3E3E3),
                    foregroundColor: const Color(0xFF1E1E1E),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Puzzle',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                // Home Button
                ElevatedButton(
                  onPressed: onHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: const Color(0xFFF5F5F5),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Home',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
          // Logout/Login Button di pojok kanan atas
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  onPressed: isGuest ? onLogin : onLogout,
                  icon: Icon(
                    isGuest ? Icons.login : Icons.logout,
                    color: const Color(0xFF1E1E1E),
                    size: 28,
                  ),
                  tooltip: isGuest ? 'Login' : 'Logout',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

