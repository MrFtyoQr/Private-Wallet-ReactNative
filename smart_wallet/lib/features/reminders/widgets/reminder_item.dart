import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/reminder_model.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import '../../../core/utils/helpers.dart';
import '../screens/add_reminder_screen.dart';

class ReminderItem extends StatefulWidget {
  const ReminderItem({
    super.key,
    required this.model,
    this.onComplete,
  });

  final ReminderModel model;
  final VoidCallback? onComplete;

  @override
  State<ReminderItem> createState() => _ReminderItemState();
}

class _ReminderItemState extends State<ReminderItem> {
  final ApiService _apiService = ApiService();
  bool _isDeleting = false;

  Future<void> _markAsComplete() async {
    try {
      await _apiService.markReminderComplete(widget.model.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recordatorio ${widget.model.title} completado')),
        );
        widget.onComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al completar recordatorio: $e')),
        );
      }
    }
  }

  Future<void> _deleteReminder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar recordatorio'),
        content: const Text('¿Estás seguro de que deseas eliminar este recordatorio? Esta acción no se puede deshacer.'),
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
      // Necesitamos agregar deleteReminder al ApiService
      final response = await _apiService.deleteReminder(widget.model.id);
      
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recordatorio eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onComplete?.call();
      } else {
        throw Exception('Error al eliminar recordatorio');
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

  Future<void> _editReminder() async {
    final result = await Navigator.pushNamed(
      context,
      AddReminderScreen.routeName,
      arguments: widget.model, // Pasar el recordatorio para editar
    );
    
    if (result == true && mounted) {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.model.status == 'completed';
    final isOverdue = widget.model.isOverdue == true;
    
    return Card(
      color: isOverdue 
          ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.3)
          : null,
      child: ListTile(
        leading: Icon(
          widget.model.isRecurring ? Icons.refresh : Icons.event,
          color: isOverdue 
              ? Theme.of(context).colorScheme.error
              : null,
        ),
        title: Text(
          widget.model.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${Helpers.formatDate(widget.model.date)} - ${widget.model.description}'),
            if (widget.model.amount != null)
              Text(
                '\$${widget.model.amount!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (widget.model.daysRemaining != null)
              Text(
                widget.model.daysRemaining! < 0
                    ? 'Vencido hace ${widget.model.daysRemaining!.abs()} días'
                    : 'Faltan ${widget.model.daysRemaining} días',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isOverdue
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCompleted) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: _editReminder,
                tooltip: 'Editar',
              ),
              IconButton(
                icon: _isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline, size: 20),
                onPressed: _isDeleting ? null : _deleteReminder,
                tooltip: 'Eliminar',
              ),
            ],
            Switch(
              value: isCompleted,
              onChanged: isCompleted
                  ? null
                  : (_) => _markAsComplete(),
            ),
          ],
        ),
      ),
    );
  }
}


