import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/utils/validators.dart';
import 'package:smart_wallet/shared/widgets/custom_button.dart';
import 'package:smart_wallet/shared/widgets/custom_text_field.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  static const String routeName = '/reminders/add';

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isRecurring = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorio creado')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo recordatorio')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _titleController,
                  label: 'Titulo',
                  validator: (value) => Validators.requiredField(value, fieldName: 'Titulo'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descripcion',
                  validator: (value) => Validators.requiredField(value, fieldName: 'Descripcion'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isRecurring,
                  title: const Text('Repetir mensualmente'),
                  onChanged: (value) => setState(() => _isRecurring = value),
                ),
                const SizedBox(height: 24),
                CustomButton(label: 'Guardar', onPressed: _submit, icon: Icons.save_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

