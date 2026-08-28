import 'package:flutter/material.dart';

class BookshelfScreen extends StatelessWidget {
  final VoidCallback onBookmarks;
  final VoidCallback onRecent;

  const BookshelfScreen({
    Key? key,
    required this.onBookmarks,
    required this.onRecent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PuRe:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Puzzle & Reasoning',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF757575),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 65, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'PuRe:',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -0.03,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Menu Cards Container
            Container(
              width: 394,
              height: 240,
              margin: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 19),
                  // Bookmarks Card
                  GestureDetector(
                    onTap: onBookmarks,
                    child: Container(
                      width: 378,
                      height: 93,
                      margin: const EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 67,
                            height: 67,
                            margin: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.bookmark,
                              color: Color(0xFF2C2C2C),
                              size: 67,
                            ),
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Text(
                                'Bookmarks',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Recent Opened News Card
                  GestureDetector(
                    onTap: onRecent,
                    child: Container(
                      width: 378,
                      height: 93,
                      margin: const EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.all(24.5),
                            child: const Icon(
                              Icons.access_time,
                              color: Color(0xFF2C2C2C),
                              size: 44,
                            ),
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Text(
                                'Recent Opened News',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 67), // Space for bottom nav
          ],
        ),
      ),
    );
  }
}

