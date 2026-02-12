import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/core/utils/validators.dart';
import 'package:smart_wallet/features/auth/screens/login_screen.dart';
import 'package:smart_wallet/shared/widgets/custom_button.dart';
import 'package:smart_wallet/shared/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  static const String routeName = '/reset-password';

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.resetPassword(
        _tokenController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.data['message'] as String? ??
                  'Contraseña actualizada. Ya puedes iniciar sesión.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        );
      } else {
        final message = response.data['message'] as String? ??
            'El enlace ha expirado o no es válido. Solicita uno nuevo.';
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión. Revisa tu red e intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva contraseña')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding,
            vertical: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ingresa el código que recibiste por correo y tu nueva contraseña.',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _tokenController,
                  label: 'Código de restablecimiento',
                  validator: (v) => Validators.requiredField(v, fieldName: 'Código'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Nueva contraseña',
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: (v) => Validators.minLength(v, 6),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmController,
                  label: 'Confirmar contraseña',
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: _isLoading ? 'Guardando…' : 'Restablecer contraseña',
                  onPressed: _isLoading ? null : _submit,
                  icon: Icons.lock_reset,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
