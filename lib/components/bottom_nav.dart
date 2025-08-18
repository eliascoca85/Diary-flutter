import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavCircleIcon(
            icon: Icons.favorite_border,
            onTap: () {},
            color: Color(0xFF007C91),
          ),
          _NavCircleIcon(
            icon: Icons.add,
            onTap: () {},
            color: Color(0xFF4F8CFF),
            isMain: true,
          ),
          _NavCircleIcon(
            icon: Icons.person_outline,
            onTap: () {},
            color: Color(0xFF007C91),
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
  const _NavCircleIcon({
    required this.icon,
    required this.onTap,
    required this.color,
    this.isMain = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMain ? 60 : 48,
        height: isMain ? 60 : 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: isMain
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

