import 'package:flutter/material.dart';
import 'app_lock_wrapper.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar la base de datos SharedPreferences
  // No necesita inicialización explícita

  // Inicializar el servicio de notificaciones
  await NotificationService().initialize();

  // Solicitar permisos de notificación
  await NotificationService().requestPermissions();

  runApp(DiaryApp());
}

class DiaryApp extends StatefulWidget {
  static final GlobalKey<_DiaryAppState> appKey = GlobalKey<_DiaryAppState>();

  DiaryApp() : super(key: appKey);

  @override
  State<DiaryApp> createState() => _DiaryAppState();

  static _DiaryAppState? of(BuildContext context) {
    return appKey.currentState;
  }
}

class _DiaryAppState extends State<DiaryApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() {
      setState(() {});
    });
  }

  void toggleTheme() {
    _themeProvider.toggleTheme();
  }

  bool get isDarkMode => _themeProvider.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIARY',
      debugShowCheckedModeBanner: false,
      theme: _themeProvider.currentTheme,
      themeMode: _themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppLockWrapper(),
    );
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }
}
