import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/services/api_service.dart';
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
  final _amountController = TextEditingController();
  final _deadlineController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isRecurring = false;
  bool _isLoading = false;
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    // Establecer fecha por defecto (7 días desde hoy)
    _selectedDeadline = DateTime.now().add(const Duration(days: 7));
    _deadlineController.text = _formatDate(_selectedDeadline!);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
        _deadlineController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.createReminder({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'due_date': _selectedDeadline!.toIso8601String().split('T')[0],
        'amount': _amountController.text.trim().isNotEmpty
            ? double.tryParse(_amountController.text.trim())
            : null,
        'is_recurring': _isRecurring ? 1 : 0,
        'recurrence_type': _isRecurring ? 'monthly' : null,
        'reminder_days': 3,
        'status': 'pending',
      });

      if (response.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recordatorio creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true para indicar que se creó
      } else {
        throw Exception('Error al crear recordatorio');
      }
    } catch (e) {
      print('Error creando recordatorio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo recordatorio')),
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
                CustomTextField(
                  controller: _titleController,
                  label: 'Título',
                  validator: (value) =>
                      Validators.requiredField(value, fieldName: 'Título'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  maxLines: 3,
                  validator: (value) =>
                      Validators.requiredField(value, fieldName: 'Descripción'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _deadlineController,
                  label: 'Fecha de vencimiento',
                  readOnly: true,
                  onTap: _selectDeadline,
                  validator: (value) => Validators.requiredField(
                    value,
                    fieldName: 'Fecha de vencimiento',
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _amountController,
                  label: 'Monto (opcional)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final amount = double.tryParse(value);
                      if (amount == null || amount < 0) {
                        return 'Ingresa un monto válido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isRecurring,
                  title: const Text('Repetir mensualmente'),
                  onChanged: (value) => setState(() => _isRecurring = value),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Guardar',
                  onPressed: _isLoading ? null : _submit,
                  icon: Icons.save_outlined,
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
