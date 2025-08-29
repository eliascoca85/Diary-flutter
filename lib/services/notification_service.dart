import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _reminderKey = 'diary_reminder_settings';

  // Configuración de recordatorios
  Map<String, dynamic> _reminderSettings = {
    'enabled': false,
    'time': {'hour': 20, 'minute': 0},
    'days': [false, false, false, false, false, false, false], // Lun-Dom
    'motivationalQuotes': true,
    'streakReminders': true,
    'weeklyReview': false,
  };

  final List<String> _motivationalMessages = [
    "💭 Es hora de reflexionar sobre tu día",
    "✨ Un momento perfecto para escribir",
    "📝 Captura tus pensamientos del día",
    "🌟 Documenta este momento especial",
    "💡 ¿Qué aprendiste hoy?",
    "🌙 Termina el día con una reflexión",
    "🎯 Mantén tu racha de escritura",
    "📖 Tu diario te está esperando",
    "🌅 Comparte tus experiencias del día",
    "💖 Un pequeño momento para ti",
  ];

  Future<void> initialize() async {
    // Inicializar zonas horarias
    tz.initializeTimeZones();

    // Configuración para Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configuración para Windows
    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Abrir Diario');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canales de notificación
    await _createNotificationChannels();

    // Solicitar permisos explícitamente
    await requestPermissions();

    // Cargar configuración guardada
    await _loadReminderSettings();
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
      'main_channel',
      'Recordatorios Principales',
      description: 'Notificaciones para recordatorios de escribir en el diario',
      importance: Importance.high,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFF6200EA),
    );

    const AndroidNotificationChannel motivationalChannel =
        AndroidNotificationChannel(
      'motivational_channel',
      'Mensajes Motivacionales',
      description: 'Mensajes motivacionales para escribir en el diario',
      importance: Importance.defaultImportance,
      enableVibration: true,
    );

    const AndroidNotificationChannel weeklyChannel = AndroidNotificationChannel(
      'weekly_channel',
      'Resúmenes Semanales',
      description: 'Recordatorios para revisar la semana',
      importance: Importance.high,
      enableVibration: true,
    );

    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(mainChannel);
      await androidImplementation
          .createNotificationChannel(motivationalChannel);
      await androidImplementation.createNotificationChannel(weeklyChannel);
    }
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    // Manejar cuando el usuario toca la notificación
    print('Notificación tocada: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    // Para Android 13+
    if (await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false) {
      return true;
    }

    // Para iOS
    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final result = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    return true; // Para desktop asumimos que está permitido
  }

  Future<void> _loadReminderSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_reminderKey);

      if (settingsJson != null) {
        _reminderSettings = json.decode(settingsJson);
      }
    } catch (e) {
      print('Error cargando configuración de recordatorios: $e');
    }
  }

  Future<void> saveReminderSettings(Map<String, dynamic> settings) async {
    try {
      _reminderSettings = settings;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_reminderKey, json.encode(settings));

      // Reprogramar notificaciones
      await _scheduleReminders();
    } catch (e) {
      print('Error guardando configuración de recordatorios: $e');
    }
  }

  Map<String, dynamic> getReminderSettings() {
    return Map<String, dynamic>.from(_reminderSettings);
  }

  Future<void> _scheduleReminders() async {
    // Cancelar todas las notificaciones existentes
    await _notifications.cancelAll();

    if (!_reminderSettings['enabled']) {
      return;
    }

    final time = _reminderSettings['time'];
    final days = List<bool>.from(_reminderSettings['days']);

    // Programar notificaciones para cada día seleccionado
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        await _scheduleDailyNotification(
          i + 1, // 1=Lunes, 7=Domingo
          time['hour'],
          time['minute'],
        );
      }
    }

    // Programar resumen semanal si está habilitado
    if (_reminderSettings['weeklyReview']) {
      await _scheduleWeeklyReview();
    }
  }

  Future<void> _scheduleDailyNotification(
      int weekday, int hour, int minute) async {
    try {
      final scheduledDate = _nextInstanceOfWeekday(weekday, hour, minute);

      print(
          'Programando notificación para: $scheduledDate (día $weekday, hora $hour:$minute)');

      String message = _getRandomMotivationalMessage();

      if (_reminderSettings['streakReminders']) {
        // Aquí podrías agregar lógica para obtener la racha actual
        // message += "\n🔥 Mantén tu racha de escritura";
      }

      await _notifications.zonedSchedule(
        weekday, // ID único para cada día
        'Diario Personal',
        message,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'main_channel',
            'Recordatorios Principales',
            channelDescription:
                'Notificaciones para recordatorios de escribir en el diario',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            enableLights: true,
            autoCancel: false,
            fullScreenIntent: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'daily_reminder',
      );

      print(
          'Notificación programada exitosamente para el día $weekday a las $hour:$minute');
    } catch (e) {
      print('Error programando notificación diaria: $e');
    }
  }

  Future<void> _scheduleWeeklyReview() async {
    try {
      // Programar para domingo a las 19:00
      final nextSunday = _nextInstanceOfWeekday(7, 19, 0);

      await _notifications.zonedSchedule(
        100, // ID único para resumen semanal
        'Resumen Semanal - Diario',
        '📊 Revisa tu semana de escritura y reflexiona sobre tus experiencias',
        tz.TZDateTime.from(nextSunday, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'diary_weekly',
            'Resumen Semanal',
            channelDescription: 'Notificación semanal para revisar tu progreso',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'weekly_review',
      );
    } catch (e) {
      print('Error programando resumen semanal: $e');
    }
  }

  DateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = DateTime.now();
    final currentWeekday = now.weekday;

    int daysToAdd = weekday - currentWeekday;
    if (daysToAdd <= 0) {
      daysToAdd += 7; // Próxima semana
    }

    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day + daysToAdd,
      hour,
      minute,
    );

    // Si es el mismo día pero ya pasó la hora, programar para la próxima semana
    if (weekday == currentWeekday && scheduledDate.isBefore(now)) {
      return scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  // Método para probar notificaciones inmediatamente
  Future<void> testNotification() async {
    try {
      await _notifications.show(
        999, // ID único para prueba
        'Prueba de Notificación',
        'Esta es una notificación de prueba para verificar que funciona correctamente 📱',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'main_channel',
            'Recordatorios Principales',
            channelDescription:
                'Notificaciones para recordatorios de escribir en el diario',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            enableLights: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'test_notification',
      );
      print('Notificación de prueba enviada');
    } catch (e) {
      print('Error enviando notificación de prueba: $e');
    }
  }

  String _getRandomMotivationalMessage() {
    if (!_reminderSettings['motivationalQuotes']) {
      return "Es hora de escribir en tu diario";
    }

    final random =
        DateTime.now().millisecondsSinceEpoch % _motivationalMessages.length;
    return _motivationalMessages[random];
  }

  Future<void> showTestNotification() async {
    try {
      await _notifications.show(
        999, // ID temporal para prueba
        'Diario Personal - Prueba',
        _getRandomMotivationalMessage(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'diary_test',
            'Notificaciones de Prueba',
            channelDescription: 'Notificación de prueba',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'test_notification',
      );
    } catch (e) {
      print('Error mostrando notificación de prueba: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
