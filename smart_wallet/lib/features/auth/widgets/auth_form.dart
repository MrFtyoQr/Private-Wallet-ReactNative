import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_wallet/core/services/auth_service.dart';
import 'package:smart_wallet/core/utils/validators.dart';
import 'package:smart_wallet/shared/widgets/custom_button.dart';
import 'package:smart_wallet/shared/widgets/custom_text_field.dart';

enum AuthFormType { login, register }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key, required this.type});

  final AuthFormType type;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _userIdController; // Para login
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _userIdController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final messenger = ScaffoldMessenger.of(context);

    bool success = false;
    if (widget.type == AuthFormType.login) {
      success = await auth.login(
        _userIdController.text.trim(), // Usar userId para login
        _passwordController.text.trim(),
      );
    } else {
      success = await auth.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.type == AuthFormType.login
                ? 'Inicio de sesion correcto'
                : 'Registro exitoso',
          ),
        ),
      );

      // Navegación automática después del login o registro exitoso
      // Usar AuthGate para que maneje la navegación según el estado de autenticación
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else if (auth.errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = widget.type == AuthFormType.register;
    final auth = context.watch<AuthService>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isRegister) ...[
            CustomTextField(
              controller: _nameController,
              label: 'Nombre completo',
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Nombre'),
            ),
            const SizedBox(height: 16),
          ],
          if (isRegister) ...[
            CustomTextField(
              controller: _emailController,
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
          ] else ...[
            CustomTextField(
              controller: _userIdController,
              label: 'Usuario',
              keyboardType: TextInputType.text,
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Usuario'),
            ),
          ],
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'Contrasena',
            obscureText: true,
            showPasswordToggle: true,
            validator: (value) => Validators.minLength(value, 6),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: isRegister ? 'Crear cuenta' : 'Ingresar',
            onPressed: auth.isLoading ? () {} : _submit,
          ),
          if (auth.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
