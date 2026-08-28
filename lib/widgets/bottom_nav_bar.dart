import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onPuzzle;
  final VoidCallback onMenu;
  final bool puzzleMode;
  final VoidCallback? onSkip;

  const BottomNavBar({
    Key? key,
    required this.onBack,
    required this.onPuzzle,
    required this.onMenu,
    this.puzzleMode = false,
    this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double baseHeight = 67;
    const double circleSize = 89;
    const double iconSize = 48;

    Widget buildIconButton(IconData icon, VoidCallback onTap) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon, color: const Color(0xFFE6E6E6), size: iconSize),
          onPressed: onTap,
        ),
      );
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: circleSize,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: baseHeight,
                width: double.infinity,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            Positioned(
              left: 20,
              bottom: (baseHeight - iconSize) / 2,
              child: buildIconButton(Icons.arrow_left, onBack),
            ),
            Positioned(
              right: 20,
              bottom: (baseHeight - iconSize) / 2,
              child: buildIconButton(
                puzzleMode ? Icons.play_arrow : Icons.list,
                puzzleMode ? (onSkip ?? onMenu) : onMenu,
              ),
            ),
            Positioned(
              bottom: 4,
              child: GestureDetector(
                onTap: onPuzzle,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C2C2C),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.extension,
                        size: 48,
                        color: Color(0xFFE6E6E6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 10,
              child: Text(
                'PuRe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

