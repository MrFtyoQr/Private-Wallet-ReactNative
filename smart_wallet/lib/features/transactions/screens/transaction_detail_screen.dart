import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/transaction_model.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/core/utils/helpers.dart';
import 'package:smart_wallet/features/transactions/screens/add_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.model});

  static const String routeName = '/transactions/detail';

  final TransactionModel model;

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isDeleting = false;

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('¿Estás seguro de que deseas eliminar esta transacción? Esta acción no se puede deshacer.'),
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
      final response = await _apiService.deleteTransaction(widget.model.id);
      
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacción eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true para indicar que se eliminó
      } else {
        throw Exception('Error al eliminar transacción');
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

  @override
  Widget build(BuildContext context) {
    final color = widget.model.type == TransactionType.income ? Colors.green : Colors.red;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de transacción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _isDeleting
                ? null
                : () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AddTransactionScreen.routeName,
                      arguments: widget.model,
                    );
                    if (result == true && mounted) {
                      Navigator.pop(context, true);
                    }
                  },
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
            onPressed: _isDeleting ? null : _deleteTransaction,
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
              widget.model.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Monto: ${Helpers.formatCurrency(widget.model.amount)}',
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Categoría: ${widget.model.category}'),
            const SizedBox(height: 8),
            Text('Fecha: ${Helpers.formatDate(widget.model.date)}'),
            const SizedBox(height: 8),
            Text(
              'Tipo: ${widget.model.type == TransactionType.income ? 'Ingreso' : 'Gasto'}',
            ),
            const SizedBox(height: 24),
            const Text('Notas rápidas'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: const Text(
                'Puedes convertir esta transacción en un recordatorio o asociarla a una meta.',
              ),
            ),
            const Spacer(),
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

