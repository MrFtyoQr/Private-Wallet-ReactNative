import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/core/utils/validators.dart';
import 'package:smart_wallet/features/auth/screens/reset_password_screen.dart';
import 'package:smart_wallet/shared/widgets/custom_button.dart';
import 'package:smart_wallet/shared/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String routeName = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.forgotPassword(_emailController.text.trim());

      if (!mounted) return;

      if (response.statusCode == 200) {
        final message = response.data['message'] as String? ??
            'Si el correo está registrado, recibirás instrucciones para restablecer tu contraseña.';
        setState(() {
          _submitted = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        // En desarrollo el backend puede devolver el token en data.token
        final token = response.data['data']?['token'] as String?;
        if (token != null && token.isNotEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Código (solo dev): $token'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        final message = response.data['message'] as String? ?? 'Error al enviar la solicitud.';
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión. Revisa tu red e intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar acceso')),
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
                  'Ingresa el correo con el que te registraste. Te enviaremos un enlace o código para restablecer tu contraseña.',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Correo',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  readOnly: _submitted,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: _isLoading
                      ? 'Enviando…'
                      : _submitted
                          ? 'Correo enviado'
                          : 'Enviar instrucciones',
                  onPressed: (_isLoading || _submitted) ? null : _submit,
                  icon: _submitted ? Icons.check : Icons.email_outlined,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    ResetPasswordScreen.routeName,
                  ),
                  child: const Text('Ya tengo el código de restablecimiento'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver al inicio de sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
