import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/goal_model.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/core/utils/helpers.dart';
import 'package:smart_wallet/features/goals/widgets/progress_bar.dart';
import 'package:smart_wallet/features/goals/screens/add_goal_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({super.key, required this.goal});

  static const String routeName = '/goals/detail';

  final GoalModel goal;

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isDeleting = false;
  bool _isUpdating = false;
  String? _planText;

  static double _parseDouble(dynamic v) => (double.tryParse(v?.toString() ?? '') ?? 0.0);
  static int? _parseInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: const Text('¿Estás seguro de que deseas eliminar esta meta? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final response = await _apiService.deleteGoal(widget.goal.id);
      
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true para indicar que se eliminó
      } else {
        throw Exception('Error al eliminar meta');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _editGoal() async {
    // Navegar a la pantalla de edición (reutilizando AddGoalScreen con datos precargados)
    final result = await Navigator.pushNamed(
      context,
      AddGoalScreen.routeName,
      arguments: widget.goal, // Pasar la meta para editar
    );
    
    if (result == true && mounted) {
      Navigator.pop(context, true); // Retornar true para refrescar la lista
    }
  }

  Future<void> _updateProgress() async {
    final amountController = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar progreso'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monto a agregar',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(amountController.text.trim());
              Navigator.pop(context, value);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (amount == null || amount <= 0) return;

    setState(() => _isUpdating = true);

    try {
      final response =
          await _apiService.updateGoalProgress(widget.goal.id, amount);
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progreso actualizado'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar progreso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _changeStatus(String status) async {
    setState(() => _isUpdating = true);
    try {
      final response =
          await _apiService.updateGoalStatus(widget.goal.id, status);
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado de la meta actualizado'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _loadPlan() async {
    setState(() => _isUpdating = true);
    try {
      final response = await _apiService.getGoalPlan(widget.goal.id);
      if (response.statusCode == 200 && mounted) {
        final raw = response.data is Map ? response.data as Map<String, dynamic> : null;
        final data = raw?['data'] as Map<String, dynamic>? ?? raw;
        // Backend devuelve data.savingsPlan; dummy devuelve data.monthlyAmount, etc.
        final savingsPlan = data?['savingsPlan'] as Map<String, dynamic>?;
        double remaining;
        int daysRemaining;
        double monthly;
        if (savingsPlan != null) {
          remaining = _parseDouble(savingsPlan['remainingAmount']);
          daysRemaining = _parseInt(savingsPlan['daysRemaining']) ?? 0;
          final suggestions = savingsPlan['suggestions'] as Map<String, dynamic>?;
          monthly = suggestions != null ? _parseDouble(suggestions['monthly']) : (daysRemaining > 0 ? remaining / daysRemaining * 30 : 0.0);
        } else {
          remaining = _parseDouble(data?['remaining']);
          daysRemaining = _parseInt(data?['daysRemaining']) ?? 0;
          monthly = _parseDouble(data?['monthlyAmount']);
        }
        setState(() {
          _planText =
              'Te faltan ${Helpers.formatCurrency(remaining)}.\n'
              'Quedan $daysRemaining días. Deberías ahorrar aproximadamente '
              '${Helpers.formatCurrency(monthly)} al mes para alcanzar tu meta.';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de meta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editGoal,
            tooltip: 'Editar',
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            onPressed: _isDeleting ? null : _deleteGoal,
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.goal.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (widget.goal.description != null && widget.goal.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.goal.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            ProgressBar(progress: widget.goal.progress ?? widget.goal.calculatedProgress),
            const SizedBox(height: 12),
            Text('Meta: ${Helpers.formatCurrency(widget.goal.targetAmount)}'),
            Text('Ahorro actual: ${Helpers.formatCurrency(widget.goal.currentAmount)}'),
            Text(
              'Fecha objetivo: ${widget.goal.deadline.day}/${widget.goal.deadline.month}/${widget.goal.deadline.year}',
            ),
            if (widget.goal.status != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  widget.goal.status == 'active'
                      ? 'Activa'
                      : widget.goal.status == 'completed'
                          ? 'Completada'
                          : 'Pausada',
                ),
                backgroundColor: widget.goal.status == 'active'
                    ? Colors.green.withOpacity(0.2)
                    : widget.goal.status == 'completed'
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Plan de ahorro'),
            const SizedBox(height: 12),
            if (_planText != null)
              Text(
                _planText!,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Text(
                'Pulsa en "Ver plan sugerido" para obtener una recomendación.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: (_isUpdating || widget.goal.status == 'completed') ? null : _updateProgress,
                  icon: const Icon(Icons.add),
                  label: const Text('Actualizar progreso'),
                ),
                ElevatedButton.icon(
                  onPressed: (_isUpdating || widget.goal.status == 'completed') ? null : () => _changeStatus('completed'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Marcar completada'),
                ),
                ElevatedButton.icon(
                  onPressed: (_isUpdating || widget.goal.status == 'completed' || widget.goal.status == 'paused') ? null : () => _changeStatus('paused'),
                  icon: const Icon(Icons.pause_circle_outline),
                  label: const Text('Pausar'),
                ),
                if (widget.goal.status == 'paused')
                  ElevatedButton.icon(
                    onPressed: _isUpdating ? null : () => _changeStatus('active'),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Reanudar'),
                  ),
                TextButton(
                  onPressed: _isUpdating ? null : _loadPlan,
                  child: const Text('Ver plan sugerido'),
                ),
              ],
            ),
            if (_isDeleting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

