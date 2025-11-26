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
            const Text('Sugerencia AI'),
            const SizedBox(height: 12),
            const Text('Aparta 150 MXN cada semana para alcanzar tu meta en el tiempo establecido.'),
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

