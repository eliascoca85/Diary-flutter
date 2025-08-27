import 'package:flutter/material.dart';
import '../main.dart';
import '../services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final NotificationService _notificationService = NotificationService();

  bool _dailyReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  List<bool> _selectedDays = List.filled(7, false);
  bool _motivationalQuotes = true;
  bool _streakReminders = true;
  bool _weeklyReview = false;

  final List<String> _dayNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  final List<String> _motivationalMessages = [
    "💭 Es hora de reflexionar sobre tu día",
    "✨ Un momento perfecto para escribir",
    "📝 Captura tus pensamientos del día",
    "🌟 Documenta este momento especial",
    "💡 ¿Qué aprendiste hoy?",
    "🌙 Termina el día con una reflexión",
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final settings = _notificationService.getReminderSettings();
    setState(() {
      _dailyReminder = settings['enabled'] ?? false;
      final time = settings['time'] ?? {'hour': 20, 'minute': 0};
      _reminderTime = TimeOfDay(hour: time['hour'], minute: time['minute']);
      _selectedDays =
          List<bool>.from(settings['days'] ?? List.filled(7, false));
      _motivationalQuotes = settings['motivationalQuotes'] ?? true;
      _streakReminders = settings['streakReminders'] ?? true;
      _weeklyReview = settings['weeklyReview'] ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        actions: [
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recordatorio Principal
            _buildReminderCard(
              'Recordatorio Diario',
              'Recibe una notificación para escribir en tu diario',
              Icons.notifications_active,
              Column(
                children: [
                  SwitchListTile(
                    title: const Text('Activar recordatorio diario'),
                    subtitle: Text(_dailyReminder
                        ? 'Recordatorio activo a las ${_reminderTime.format(context)}'
                        : 'Toca para activar'),
                    value: _dailyReminder,
                    onChanged: (value) {
                      setState(() {
                        _dailyReminder = value;
                      });
                      if (value) {
                        _showTimePickerDialog();
                      }
                    },
                    activeThumbColor: const Color(0xFF007C91),
                  ),
                  if (_dailyReminder) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.access_time,
                          color: Color(0xFF007C91)),
                      title: const Text('Hora del recordatorio'),
                      subtitle: Text(_reminderTime.format(context)),
                      trailing: const Icon(Icons.edit),
                      onTap: _showTimePickerDialog,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Días de la Semana
            if (_dailyReminder) ...[
              _buildReminderCard(
                'Días de la Semana',
                'Selecciona en qué días quieres recibir recordatorios',
                Icons.calendar_today,
                Column(
                  children: [
                    for (int i = 0; i < _dayNames.length; i++)
                      CheckboxListTile(
                        title: Text(_dayNames[i]),
                        value: _selectedDays[i],
                        onChanged: (value) {
                          setState(() {
                            _selectedDays[i] = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF007C91),
                        dense: true,
                      ),
                    if (!_selectedDays.contains(true))
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning,
                                color: Colors.orange[700], size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Selecciona al menos un día para recibir recordatorios',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tipos de Recordatorios
            _buildReminderCard(
              'Tipos de Recordatorios',
              'Personaliza el tipo de notificaciones que recibes',
              Icons.tune,
              Column(
                children: [
                  SwitchListTile(
                    title: const Text('Frases motivacionales'),
                    subtitle: const Text('Incluir mensajes inspiradores'),
                    value: _motivationalQuotes,
                    onChanged: (value) {
                      setState(() {
                        _motivationalQuotes = value;
                      });
                    },
                    activeThumbColor: const Color(0xFF007C91),
                  ),
                  SwitchListTile(
                    title: const Text('Recordatorios de racha'),
                    subtitle:
                        const Text('Notificaciones sobre tu racha actual'),
                    value: _streakReminders,
                    onChanged: (value) {
                      setState(() {
                        _streakReminders = value;
                      });
                    },
                    activeThumbColor: const Color(0xFF007C91),
                  ),
                  SwitchListTile(
                    title: const Text('Resumen semanal'),
                    subtitle: const Text('Recordatorio para revisar tu semana'),
                    value: _weeklyReview,
                    onChanged: (value) {
                      setState(() {
                        _weeklyReview = value;
                      });
                    },
                    activeThumbColor: const Color(0xFF007C91),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Vista Previa
            if (_dailyReminder && _motivationalQuotes) ...[
              _buildReminderCard(
                'Vista Previa',
                'Así se verán tus notificaciones',
                Icons.preview,
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007C91).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF007C91).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007C91),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diario Personal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Hace 2 minutos',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _motivationalMessages[DateTime.now().second %
                            _motivationalMessages.length],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botones de Acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showTestNotification();
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Probar Notificación'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF007C91)),
                      foregroundColor: const Color(0xFF007C91),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007C91),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Información Adicional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Información sobre Recordatorios',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Los recordatorios te ayudan a mantener el hábito de escribir\n'
                    '• Puedes desactivarlos en cualquier momento\n'
                    '• Las notificaciones aparecerán solo cuando tengas la app instalada\n'
                    '• El resumen semanal se envía los domingos por la noche',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(
      String title, String subtitle, IconData icon, Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF007C91), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  void _showTimePickerDialog() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF007C91),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _showTestNotification() async {
    try {
      await _notificationService.showTestNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('¡Notificación de prueba enviada!'),
              ],
            ),
            backgroundColor: Color(0xFF007C91),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar notificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveSettings() async {
    // Validar configuración
    if (_dailyReminder && !_selectedDays.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor selecciona al menos un día para los recordatorios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Crear configuración
      final settings = {
        'enabled': _dailyReminder,
        'time': {'hour': _reminderTime.hour, 'minute': _reminderTime.minute},
        'days': _selectedDays,
        'motivationalQuotes': _motivationalQuotes,
        'streakReminders': _streakReminders,
        'weeklyReview': _weeklyReview,
      };

      // Guardar configuración y programar notificaciones
      await _notificationService.saveReminderSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(_dailyReminder
                    ? 'Recordatorios configurados correctamente'
                    : 'Recordatorios desactivados'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Mostrar información adicional si se activaron
        if (_dailyReminder) {
          final activeDays = _selectedDays.where((day) => day).length;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Se programaron recordatorios para $activeDays ${activeDays == 1 ? 'día' : 'días'} a las ${_reminderTime.format(context)}'),
              backgroundColor: const Color(0xFF007C91),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar configuración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
