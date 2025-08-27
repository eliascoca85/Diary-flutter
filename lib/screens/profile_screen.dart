import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import 'notes_screen.dart';
import 'statistics_screen.dart';
import 'reminders_screen.dart';
import '../main.dart';
import '../services/database_service_isar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool hasAccessCode = false;
  Map<String, int> _stats = {'total': 0, 'favorites': 0, 'consecutive_days': 0};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await DatabaseService.instance.getStatistics();
      if (mounted) {
        setState(() {
          _stats = stats;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stats = {'total': 0, 'favorites': 0, 'consecutive_days': 0};
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(Icons.person, color: Color(0xFF007C91)),
        ),
        title: const Text('Mi Perfil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit, size: 28),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Editar perfil')),
                );
              }),
          IconButton(
              icon: Icon(
                DiaryApp.appKey.currentState?.isDarkMode == true
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
                size: 28,
              ),
              onPressed: () {
                DiaryApp.appKey.currentState?.toggleTheme();
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF007C91),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F8CFF),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.white,
                                width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Usuario Diario',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'usuario@email.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotesScreen(),
                            ),
                          );
                        },
                        child: _ProfileStat('${_stats['total']}', 'Entradas'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StatisticsScreen(),
                            ),
                          );
                        },
                        child: _ProfileStat(
                            '${_stats['consecutive_days']}', 'Días seguidos'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NotesScreen(initialFilter: 'Favoritas'),
                            ),
                          );
                        },
                        child:
                            _ProfileStat('${_stats['favorites']}', 'Favoritas'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu Options
            _MenuSection(
              title: 'Mi Diario',
              items: [
                _MenuItem(
                  icon: Icons.book_outlined,
                  title: 'Mis Entradas',
                  subtitle: 'Ver todas las entradas del diario',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotesScreen()),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.favorite_border,
                  title: 'Favoritas',
                  subtitle: 'Entradas marcadas como favoritas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const NotesScreen(initialFilter: 'Favoritas')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.analytics_outlined,
                  title: 'Estadísticas',
                  subtitle: 'Análisis de tu actividad',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StatisticsScreen()),
                    );
                  },
                ),
              ],
            ),

            _MenuSection(
              title: 'Apariencia',
              items: [
                _MenuItem(
                  icon: Icons.nightlight_round,
                  title: 'Modo Oscuro',
                  subtitle: 'Activar tema oscuro',
                  onTap: () {
                    DiaryApp.appKey.currentState?.toggleTheme();
                  },
                  hasSwitch: true,
                  switchValue:
                      DiaryApp.appKey.currentState?.isDarkMode ?? false,
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Recordatorios',
                  subtitle: 'Configurar notificaciones',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RemindersScreen()),
                    );
                  },
                ),
              ],
            ),

            _MenuSection(
              title: 'Privacidad y Seguridad',
              items: [
                _MenuItem(
                  icon: Icons.lock_outline,
                  title: 'Código de Acceso',
                  subtitle: hasAccessCode
                      ? 'PIN configurado'
                      : 'Proteger app con PIN',
                  onTap: () {
                    setState(() {
                      hasAccessCode = !hasAccessCode;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(hasAccessCode
                            ? 'Código de acceso activado'
                            : 'Código de acceso desactivado'),
                      ),
                    );
                  },
                  hasSwitch: true,
                  switchValue: hasAccessCode,
                ),
                _MenuItem(
                  icon: Icons.shield_outlined,
                  title: 'Privacidad',
                  subtitle: 'Configurar opciones de privacidad',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Próximamente: Configuración de privacidad')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text(
                            '¿Estás seguro que deseas cerrar sesión?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sesión cerrada')),
                              );
                            },
                            child: const Text('Cerrar Sesión'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007C91),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool hasSwitch;
  final bool switchValue;

  const _MenuItem({
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.titleMedium?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      trailing: hasSwitch
          ? Switch(
              value: switchValue,
              onChanged: (value) => onTap(),
              activeThumbColor: const Color(0xFF007C91),
            )
          : Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
      onTap: hasSwitch ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
