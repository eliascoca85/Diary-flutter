import 'package:flutter/material.dart';
import '../themes/app_themes.dart';
import '../components/bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  String selectedTheme = 'light'; // 'light', 'dark'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007C91)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Configuración',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 18,
            )),
        actions: [
          IconButton(
              icon: const Icon(Icons.info_outline,
                  color: Colors.black87, size: 28),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Información'),
                      content: const Text(
                          'Diary App v1.0\nDesarrollado con Flutter'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Theme Section
            _SettingsSection(
              title: 'Apariencia',
              items: [
                _ThemeSelector(
                  currentTheme: selectedTheme,
                  onThemeChanged: (theme) {
                    setState(() {
                      selectedTheme = theme;
                      isDarkMode = theme == 'dark';
                    });
                  },
                ),
                _SettingsItem(
                  icon: Icons.color_lens,
                  title: 'Colores de Acento',
                  subtitle: 'Personalizar colores principales',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Próximamente: Personalización de colores')),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.font_download,
                  title: 'Tamaño de Fuente',
                  subtitle: 'Ajustar tamaño del texto',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Próximamente: Ajuste de fuente')),
                    );
                  },
                ),
              ],
            ),

            // Preview del tema seleccionado
            if (selectedTheme == 'dark') _DarkModePreviewCard(),

            _SettingsSection(
              title: 'Notificaciones',
              items: [
                _SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Recordatorios Diarios',
                  subtitle: 'Recibir notificaciones para escribir',
                  hasSwitch: true,
                  switchValue: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Recordatorios activados/desactivados')),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.schedule,
                  title: 'Hora de Recordatorio',
                  subtitle: '20:00 PM',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Próximamente: Selector de hora')),
                    );
                  },
                ),
              ],
            ),

            _SettingsSection(
              title: 'Privacidad y Seguridad',
              items: [
                _SettingsItem(
                  icon: Icons.lock_outline,
                  title: 'Código de Acceso',
                  subtitle: 'Proteger app con PIN',
                  hasSwitch: true,
                  switchValue: false,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Código de acceso activado/desactivado')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      backgroundColor: Colors.grey[50],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool hasSwitch;
  final bool switchValue;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.hasSwitch = false,
    this.switchValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF007C91).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF007C91),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
      trailing: hasSwitch
          ? Switch(
              value: switchValue,
              onChanged: (value) => onTap(),
              activeThumbColor: const Color(0xFF007C91),
            )
          : const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
      onTap: hasSwitch ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;

  const _ThemeSelector({
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tema de la Aplicación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ThemeOption(
                  title: 'Claro',
                  icon: Icons.wb_sunny,
                  isSelected: currentTheme == 'light',
                  colors: [Colors.white, Colors.grey[100]!],
                  onTap: () => onThemeChanged('light'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ThemeOption(
                  title: 'Oscuro',
                  icon: Icons.nightlight_round,
                  isSelected: currentTheme == 'dark',
                  colors: [const Color(0xFF1E1E1E), const Color(0xFF121212)],
                  onTap: () => onThemeChanged('dark'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF007C91) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF007C91) : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF007C91) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkModePreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemes.darkModeColors['surface'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppThemes.darkModeColors['border']!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility,
                color: AppThemes.darkModeColors['textSecondary'],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Vista Previa - Modo Oscuro',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppThemes.darkModeColors['textPrimary'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: AppThemes.darkModeColors['background'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dark_mode,
                    color: AppThemes.darkModeColors['textPrimary'],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Así se verá tu diario',
                    style: TextStyle(
                      color: AppThemes.darkModeColors['textSecondary'],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
