import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/access_code_service.dart';

class AccessCodeSetupScreen extends StatefulWidget {
  final bool isChanging;

  const AccessCodeSetupScreen({Key? key, this.isChanging = false})
      : super(key: key);

  @override
  State<AccessCodeSetupScreen> createState() => _AccessCodeSetupScreenState();
}

class _AccessCodeSetupScreenState extends State<AccessCodeSetupScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _confirmControllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _confirmFocusNodes =
      List.generate(4, (index) => FocusNode());

  bool _isLoading = false;
  bool _showConfirmation = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    for (var controller in _confirmControllers) {
      controller.dispose();
    }
    for (var focusNode in _confirmFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _getCurrentInputCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  String _getCurrentConfirmCode() {
    return _confirmControllers.map((controller) => controller.text).join();
  }

  void _onCodeInput(String value, int index, bool isConfirm) {
    final controllers = isConfirm ? _confirmControllers : _controllers;
    final focusNodes = isConfirm ? _confirmFocusNodes : _focusNodes;

    if (value.isNotEmpty && index < 3) {
      focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onBackspace(int index, bool isConfirm) {
    final controllers = isConfirm ? _confirmControllers : _controllers;
    final focusNodes = isConfirm ? _confirmFocusNodes : _focusNodes;

    if (index > 0) {
      controllers[index - 1].clear();
      focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _clearCode() {
    for (var controller
        in (_showConfirmation ? _confirmControllers : _controllers)) {
      controller.clear();
    }
    (_showConfirmation ? _confirmFocusNodes : _focusNodes)[0].requestFocus();
    setState(() {});
  }

  Future<void> _setupCode() async {
    if (!_showConfirmation) {
      // Primera vez: mostrar confirmación
      setState(() {
        _showConfirmation = true;
      });
      _confirmFocusNodes[0].requestFocus();
      return;
    }

    // Segunda vez: verificar y guardar
    final code = _getCurrentInputCode();
    final confirmCode = _getCurrentConfirmCode();

    if (code != confirmCode) {
      _showErrorSnackBar('Los códigos no coinciden. Inténtalo de nuevo.');
      setState(() {
        _showConfirmation = false;
      });
      _clearAllCodes();
      _focusNodes[0].requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AccessCodeService.setAccessCode(code);
      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isChanging
                  ? 'Código cambiado exitosamente'
                  : 'Código configurado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showErrorSnackBar(
            'Error al configurar el código. Inténtalo de nuevo.');
      }
    } catch (e) {
      _showErrorSnackBar('Error inesperado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearAllCodes() {
    for (var controller in _controllers) {
      controller.clear();
    }
    for (var controller in _confirmControllers) {
      controller.clear();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isChanging ? 'Cambiar PIN' : 'Configurar PIN'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.security,
                  size: 80,
                  color: Color(0xFF007C91),
                ),
                const SizedBox(height: 32),
                Text(
                  _showConfirmation
                      ? 'Confirma tu PIN'
                      : 'Crea tu PIN de 4 dígitos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF007C91),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _showConfirmation
                      ? 'Ingresa nuevamente tu PIN para confirmarlo'
                      : 'Este PIN protegerá el acceso a tu diario',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    final controllers =
                        _showConfirmation ? _confirmControllers : _controllers;
                    final focusNodes =
                        _showConfirmation ? _confirmFocusNodes : _focusNodes;

                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
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
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF007C91),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) =>
                            _onCodeInput(value, index, _showConfirmation),
                        onTap: () {
                          controllers[index].selection =
                              TextSelection.fromPosition(
                            TextPosition(
                                offset: controllers[index].text.length),
                          );
                        },
                        onSubmitted: (value) {
                          if (value.isEmpty && index > 0) {
                            _onBackspace(index, _showConfirmation);
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
                        onPressed: (_showConfirmation
                                ? _getCurrentConfirmCode().length == 4
                                : _getCurrentInputCode().length == 4)
                            ? _setupCode
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                            _showConfirmation ? 'Confirmar PIN' : 'Continuar'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _clearCode,
                        child: const Text('Limpiar'),
                      ),
                      if (_showConfirmation) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showConfirmation = false;
                            });
                            _clearAllCodes();
                            _focusNodes[0].requestFocus();
                          },
                          child: const Text('Volver'),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
