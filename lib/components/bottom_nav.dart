import 'package:flutter/material.dart';
import '../screens/notes_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/home_screen.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavCircleIcon(
            icon: Icons.book,
            onTap: () {
              if (currentIndex != 1) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const NotesScreen(),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                              .chain(CurveTween(curve: Curves.ease)),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            color: Color(0xFF007C91),
            isSelected: currentIndex == 1,
          ),
          _NavCircleIcon(
            icon: Icons.home,
            onTap: () {
              if (currentIndex != 0) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const HomeScreen(),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return ScaleTransition(
                        scale: animation.drive(
                          Tween(begin: 0.8, end: 1.0)
                              .chain(CurveTween(curve: Curves.ease)),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            color: Color(0xFF4F8CFF),
            isMain: true,
            isSelected: currentIndex == 0,
          ),
          _NavCircleIcon(
            icon: Icons.person_outline,
            onTap: () {
              if (currentIndex != 2) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ProfileScreen(),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                                  begin: const Offset(-1.0, 0.0),
                                  end: Offset.zero)
                              .chain(CurveTween(curve: Curves.ease)),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            color: Color(0xFF007C91),
            isSelected: currentIndex == 2,
          ),
        ],
      ),
    );
  }
}

class _NavCircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool isMain;
  final bool isSelected;

  const _NavCircleIcon({
    required this.icon,
    required this.onTap,
    required this.color,
    this.isMain = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMain ? 60 : 48,
        height: isMain ? 60 : 48,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.7),
          shape: BoxShape.circle,
          boxShadow: isMain || isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isMain ? 32 : 28,
        ),
      ),
    );
  }
}
