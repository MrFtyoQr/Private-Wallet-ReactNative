import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/features/auth/widgets/auth_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 24),
          child: const AuthForm(type: AuthFormType.register),
        ),
      ),
    );
  }
}

