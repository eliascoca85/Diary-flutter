import 'package:flutter/material.dart';

class AppThemes {
  // Colores principales de la app
  static const Color primaryColor = Color(0xFF007C91);
  static const Color secondaryColor = Color(0xFF4F8CFF);
  static const Color accentColor = Color(0xFFc6e6f7);

  // Tema Claro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.teal,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.grey[50],
    fontFamily: 'Roboto',

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontSize: 18,
      ),
      iconTheme: IconThemeData(color: Colors.black87),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
    ),

    // Bottom Navigation Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      elevation: 8,
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.black45,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      filled: true,
      fillColor: Colors.white,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  // Tema Oscuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: 'Roboto',

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 2,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 18,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.black.withOpacity(0.3),
    ),

    // Bottom Navigation Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      elevation: 8,
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white70,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.white60,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  // Colores personalizados para modo oscuro
  static const darkModeColors = {
    'background': Color(0xFF121212),
    'surface': Color(0xFF1E1E1E),
    'card': Color(0xFF2D2D2D),
    'border': Color(0xFF404040),
    'textPrimary': Colors.white,
    'textSecondary': Color(0xFFB3B3B3),
    'textTertiary': Color(0xFF808080),
  };

  // Colores personalizados para modo claro
  static const lightModeColors = {
    'background': Color(0xFFFAFAFA),
    'surface': Colors.white,
    'card': Colors.white,
    'border': Color(0xFFE0E0E0),
    'textPrimary': Color(0xFF212121),
    'textSecondary': Color(0xFF757575),
    'textTertiary': Color(0xFF9E9E9E),
  };
}

// Widget para preview del modo oscuro (solo visual)
class DarkModePreview extends StatelessWidget {
  const DarkModePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.darkModeColors['background'],
      appBar: AppBar(
        backgroundColor: AppThemes.darkModeColors['surface'],
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(Icons.phone_iphone, color: AppThemes.primaryColor),
        ),
        title: Text('Mi Diario - Modo Oscuro',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppThemes.darkModeColors['textPrimary'],
              fontSize: 18,
            )),
        actions: [
          IconButton(
              icon: Icon(Icons.search,
                  color: AppThemes.darkModeColors['textPrimary'], size: 28),
              onPressed: () {}),
          IconButton(
              icon: Icon(Icons.wb_sunny,
                  color: AppThemes.darkModeColors['textPrimary'], size: 28),
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Card en modo oscuro
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D4A5C), Color(0xFF3A5F73)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MIÉRCOLES',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppThemes.darkModeColors['textSecondary'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '24/08/2025',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppThemes.darkModeColors['textSecondary'],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud, size: 80, color: Colors.white70),
                      const SizedBox(width: 24),
                      Text(
                        '22°C',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: AppThemes.darkModeColors['textPrimary'],
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      'NUBLADO',
                      style: TextStyle(
                        color: AppThemes.darkModeColors['textSecondary'],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Entradas Recientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppThemes.darkModeColors['textPrimary'],
              ),
            ),

            const SizedBox(height: 16),

            // Note Cards en modo oscuro
            ...List.generate(
                3,
                (index) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppThemes.darkModeColors['surface'],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppThemes.darkModeColors['border']!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mi entrada ${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppThemes.darkModeColors['textPrimary'],
                                ),
                              ),
                              Icon(
                                Icons.favorite_border,
                                color:
                                    AppThemes.darkModeColors['textSecondary'],
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Esta es una entrada de ejemplo en modo oscuro...',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppThemes.darkModeColors['textSecondary'],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '24 Ago 2025',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppThemes.darkModeColors['textTertiary'],
                            ),
                          ),
                        ],
                      ),
                    )),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        decoration: BoxDecoration(
          color: AppThemes.darkModeColors['surface'],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DarkNavIcon(Icons.book, AppThemes.primaryColor),
            _DarkNavIcon(Icons.home, AppThemes.secondaryColor, isMain: true),
            _DarkNavIcon(Icons.person_outline, AppThemes.primaryColor),
          ],
        ),
      ),
    );
  }
}

class _DarkNavIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isMain;

  const _DarkNavIcon(this.icon, this.color, {this.isMain = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMain ? 60 : 48,
      height: isMain ? 60 : 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isMain
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: isMain ? 32 : 28,
      ),
    );
  }
}
