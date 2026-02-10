import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/models/goal_model.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/core/utils/validators.dart';
import 'package:smart_wallet/shared/widgets/custom_button.dart';
import 'package:smart_wallet/shared/widgets/custom_text_field.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  static const String routeName = '/goals/add';

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  DateTime? _selectedDeadline;
  GoalModel? _editingGoal; // Meta que se está editando (null si es nueva)

  @override
  void initState() {
    super.initState();
    // Verificar si se pasó una meta para editar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is GoalModel) {
        _editingGoal = args;
        _loadGoalData(_editingGoal!);
      } else {
        // Establecer fecha por defecto (30 días desde hoy) solo si es nueva meta
        _selectedDeadline = DateTime.now().add(const Duration(days: 30));
        _deadlineController.text = _formatDate(_selectedDeadline!);
      }
    });
  }

  void _loadGoalData(GoalModel goal) {
    _titleController.text = goal.title;
    _amountController.text = goal.targetAmount.toStringAsFixed(0);
    _selectedDeadline = goal.deadline;
    _deadlineController.text = _formatDate(goal.deadline);
    if (goal.description != null && goal.description!.isNotEmpty) {
      _descriptionController.text = goal.description!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _deadlineController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
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
      final goalData = {
        'title': _titleController.text.trim(),
        'target_amount': double.parse(_amountController.text.trim()),
        'deadline': _selectedDeadline!.toIso8601String().split('T')[0],
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'status': _editingGoal?.status ?? 'active',
      };

      Response response;

      if (_editingGoal != null) {
        // Actualizar meta existente
        goalData['current_amount'] =
            _editingGoal!.currentAmount; // Mantener el monto actual
        response = await _apiService.updateGoal(_editingGoal!.id, goalData);

        if (response.statusCode == 200 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Error al actualizar meta');
        }
      } else {
        // Crear nueva meta
        goalData['current_amount'] = 0.0;
        response = await _apiService.createGoal(goalData);

        if (response.statusCode == 201 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta guardada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Error al crear meta');
        }
      }
    } catch (e) {
      print(
        'Error ${_editingGoal != null ? "actualizando" : "creando"} meta: $e',
      );
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
      appBar: AppBar(
        title: Text(_editingGoal != null ? 'Editar meta' : 'Nueva meta'),
      ),
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
                  label: 'Meta',
                  validator: (value) =>
                      Validators.requiredField(value, fieldName: 'Meta'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _amountController,
                  label: 'Monto objetivo',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Monto requerido';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _deadlineController,
                  label: 'Fecha objetivo',
                  readOnly: true,
                  onTap: _selectDeadline,
                  validator: (value) => Validators.requiredField(
                    value,
                    fieldName: 'Fecha objetivo',
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descripción (opcional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Guardar',
                  onPressed: _isLoading ? null : _submit,
                  icon: Icons.flag_outlined,
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
