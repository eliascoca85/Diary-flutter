import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../components/bottom_nav.dart';
import 'notes_screen.dart';
import 'statistics_screen.dart';
import 'reminders_screen.dart';
import 'access_code_setup_screen.dart';
import 'access_code_verification_screen.dart';
import '../main.dart';
import '../services/database_service_isar.dart';
import '../services/access_code_service.dart';
import '../services/media_service.dart';
import '../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool hasAccessCode = false;
  bool accessCodeEnabled = false;
  Map<String, int> _stats = {'total': 0, 'favorites': 0, 'consecutive_days': 0};
  String _userName = 'Usuario';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadAccessCodeStatus();
    _loadUserName();
    _loadProfileImage();
  }

  Future<void> _loadAccessCodeStatus() async {
    final hasCode = await AccessCodeService.hasAccessCode();
    final isEnabled = await AccessCodeService.isAccessCodeEnabled();
    if (mounted) {
      setState(() {
        hasAccessCode = hasCode;
        accessCodeEnabled = isEnabled;
      });
    }
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

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    if (mounted && savedName != null) {
      setState(() {
        _userName = savedName;
      });
    }
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (mounted && imagePath != null && await File(imagePath).exists()) {
      setState(() {
        _profileImagePath = imagePath;
      });
    }
  }

  Future<void> _saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', imagePath);
    if (mounted) {
      setState(() {
        _profileImagePath = imagePath;
      });
    }
  }

  void _showChangeProfileImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar foto de perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF007C91)),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF007C91)),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              if (_profileImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Eliminar foto'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final String? imagePath = await MediaService().takePhoto();
      if (imagePath != null) {
        await _saveProfileImage(imagePath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil actualizada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final String? imagePath = await MediaService().pickImageFromGallery();
      if (imagePath != null) {
        await _saveProfileImage(imagePath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil actualizada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      if (_profileImagePath != null) {
        // Eliminar el archivo físico
        await MediaService().deleteImage(_profileImagePath!);

        // Eliminar de SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profile_image_path');

        if (mounted) {
          setState(() {
            _profileImagePath = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil eliminada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditUserNameDialog() {
    final TextEditingController controller =
        TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar nombre de usuario'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
              border: OutlineInputBorder(),
            ),
            maxLength: 50,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  _saveUserName(newName);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nombre de usuario actualizado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _handleAccessCodeTap() async {
    if (!hasAccessCode) {
      // No hay código configurado, ir a la pantalla de configuración
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AccessCodeSetupScreen(),
        ),
      );

      if (result == true) {
        // Solo recargar después de configurar un nuevo código
        _loadAccessCodeStatus();
      }
    } else {
      // Hay código configurado, mostrar opciones inmediatamente
      _showAccessCodeOptions();
    }
  }

  void _showAccessCodeOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  accessCodeEnabled ? Icons.lock_open : Icons.lock,
                  color: const Color(0xFF007C91),
                ),
                title:
                    Text(accessCodeEnabled ? 'Desactivar PIN' : 'Activar PIN'),
                subtitle: Text(accessCodeEnabled
                    ? 'El PIN dejará de proteger la aplicación'
                    : 'El PIN protegerá la aplicación'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleAccessCode();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF007C91)),
                title: const Text('Cambiar PIN'),
                subtitle: const Text('Configurar un nuevo código de acceso'),
                onTap: () {
                  Navigator.pop(context);
                  _changeAccessCode();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar PIN'),
                subtitle:
                    const Text('Remover completamente el código de acceso'),
                onTap: () {
                  Navigator.pop(context);
                  _removeAccessCode();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleAccessCode() async {
    if (accessCodeEnabled) {
      // Desactivar - pedir verificación primero
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              const AccessCodeVerificationScreen(canCancel: true),
        ),
      );

      if (result == true) {
        await AccessCodeService.setAccessCodeEnabled(false);
        _loadAccessCodeStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN desactivado exitosamente'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      // Activar
      await AccessCodeService.setAccessCodeEnabled(true);
      _loadAccessCodeStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN activado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _changeAccessCode() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccessCodeSetupScreen(isChanging: true),
      ),
    );

    if (result == true) {
      _loadAccessCodeStatus();
    }
  }

  Future<void> _removeAccessCode() async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar código de acceso'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar completamente el código de acceso? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Verificar código antes de eliminar
      final verified = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              const AccessCodeVerificationScreen(canCancel: true),
        ),
      );

      if (verified == true) {
        await AccessCodeService.removeAccessCode();
        _loadAccessCodeStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código de acceso eliminado exitosamente'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
                      GestureDetector(
                        onTap: _showChangeProfileImageDialog,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                          child: _profileImagePath != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(_profileImagePath!),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Color(0xFF007C91),
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF007C91),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showChangeProfileImageDialog,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF007C91),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _showEditUserNameDialog,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ],
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
                _MenuItem(
                  icon: Icons.notification_add_outlined,
                  title: 'Probar Notificación',
                  subtitle: 'Enviar notificación de prueba',
                  onTap: () async {
                    try {
                      await NotificationService().testNotification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notificación de prueba enviada ✓'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error enviando notificación: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
                      ? (accessCodeEnabled
                          ? 'PIN activado'
                          : 'PIN configurado pero desactivado')
                      : 'Proteger app con PIN',
                  onTap: () => _handleAccessCodeTap(),
                  hasSwitch: hasAccessCode,
                  switchValue: accessCodeEnabled,
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
                            onPressed: () async {
                              Navigator.of(context).pop();

                              // Limpiar el estado de login para que pida PIN la próxima vez
                              await AccessCodeService.clearLoginState();

                              // Verificar si hay PIN activo
                              final hasActivePin = await AccessCodeService
                                      .isAccessCodeEnabled() &&
                                  await AccessCodeService.hasAccessCode();

                              if (hasActivePin) {
                                // Cerrar completamente la aplicación
                                SystemNavigator.pop();
                              } else {
                                // Si no hay PIN, solo mostrar mensaje
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sesión cerrada.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
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
