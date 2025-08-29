import 'package:flutter/material.dart';
import 'screens/access_code_verification_screen.dart';
import 'screens/home_screen.dart';
import 'services/access_code_service.dart';

class AppLockWrapper extends StatefulWidget {
  const AppLockWrapper({Key? key}) : super(key: key);

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Cuando la app regresa del background o se reanuda
    if (state == AppLifecycleState.resumed) {
      _checkLockStatus();
    }

    // Cuando la app se va al background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _lockApp();
    }
  }

  Future<void> _checkLockStatus() async {
    try {
      final hasAccessCode = await AccessCodeService.hasAccessCode();
      final isEnabled = await AccessCodeService.isAccessCodeEnabled();
      final isLoggedIn = await AccessCodeService.isLoggedIn();

      if (mounted) {
        setState(() {
          // Solo bloquear si hay PIN configurado, está habilitado, y no está logueado
          _isLocked = hasAccessCode && isEnabled && !isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocked = false; // En caso de error, permitir acceso
          _isLoading = false;
        });
      }
    }
  }

  void _lockApp() async {
    final hasAccessCode = await AccessCodeService.hasAccessCode();
    final isEnabled = await AccessCodeService.isAccessCodeEnabled();

    if (hasAccessCode && isEnabled) {
      // Limpiar el estado de login cuando la app se va al background
      await AccessCodeService.clearLoginState();

      if (mounted) {
        setState(() {
          _isLocked = true;
        });
      }
    }
  }

  void _onUnlocked() {
    setState(() {
      _isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isLocked) {
      return AccessCodeVerificationScreen(
        canCancel: false,
        onVerificationSuccess: _onUnlocked,
      );
    }

    return const HomeScreen();
  }
}
