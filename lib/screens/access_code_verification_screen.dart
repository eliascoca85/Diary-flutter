import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/access_code_service.dart';

class AccessCodeVerificationScreen extends StatefulWidget {
  final bool canCancel;
  final VoidCallback? onVerificationSuccess;

  const AccessCodeVerificationScreen({
    Key? key,
    this.canCancel = true,
    this.onVerificationSuccess,
  }) : super(key: key);

  @override
  State<AccessCodeVerificationScreen> createState() =>
      _AccessCodeVerificationScreenState();
}

class _AccessCodeVerificationScreenState
    extends State<AccessCodeVerificationScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  bool _isLoading = false;
  int _attempts = 0;
  final int _maxAttempts = 3;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));

    // Auto-focus en el primer campo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _getCurrentInputCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _onCodeInput(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-verificar cuando se completen los 4 dígitos
    if (_getCurrentInputCode().length == 4) {
      _verifyCode();
    }

    setState(() {});
  }

  void _onBackspace(int index) {
    if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  Future<void> _verifyCode() async {
    final code = _getCurrentInputCode();
    if (code.length != 4) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final isCorrect = await AccessCodeService.verifyAccessCode(code);

      if (isCorrect) {
        // Código correcto - marcar como logueado
        await AccessCodeService.setLoginState(true);

        if (mounted) {
          // Si hay callback, llamarlo en lugar de hacer pop
          if (widget.onVerificationSuccess != null) {
            widget.onVerificationSuccess!();
          } else {
            Navigator.of(context).pop(true);
          }
        }
      } else {
        // Código incorrecto
        _attempts++;

        if (_attempts >= _maxAttempts) {
          // Máximo de intentos alcanzado
          if (mounted) {
            if (widget.canCancel) {
              Navigator.of(context).pop(false);
            } else {
              // Si no se puede cancelar, cerrar la aplicación
              SystemNavigator.pop();
            }
          }
        } else {
          // Mostrar error y limpiar
          _performShakeAnimation();
          _clearCode();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Código incorrecto. Intentos restantes: ${_maxAttempts - _attempts}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al verificar código: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _performShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  void _showForgotCodeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Olvidaste tu código?'),
          content: const Text(
            'Para restablecer tu código de acceso, deberás eliminar y reinstalar la aplicación. '
            'Ten en cuenta que esto eliminará todos tus datos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.canCancel
          ? AppBar(
              title: const Text('Verificar Código'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        (widget.canCancel ? kToolbarHeight : 0) -
                        100,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 80,
                        color: Color(0xFF007C91),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        widget.canCancel
                            ? 'Ingresa tu código de acceso'
                            : 'Aplicación Bloqueada',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF007C91),
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.canCancel
                            ? 'Introduce tu código de 4 dígitos para acceder'
                            : 'Introduce tu PIN para desbloquear la aplicación',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      if (_attempts > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Text(
                            'Intentos restantes: ${_maxAttempts - _attempts}',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 60,
                            height: 60,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 1,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _attempts > 0
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _attempts > 0
                                        ? Colors.red
                                        : Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) => _onCodeInput(value, index),
                              onTap: () {
                                _controllers[index].selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: _controllers[index].text.length),
                                );
                              },
                              onSubmitted: (value) {
                                if (value.isEmpty && index > 0) {
                                  _onBackspace(index);
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: _getCurrentInputCode().length == 4
                                  ? _verifyCode
                                  : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Verificar'),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _clearCode,
                              child: const Text('Limpiar'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _showForgotCodeDialog,
                              child: Text(
                                '¿Olvidaste tu código?',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
