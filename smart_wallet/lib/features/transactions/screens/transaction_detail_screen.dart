import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/transaction_model.dart';
import 'package:smart_wallet/core/utils/helpers.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.model});

  static const String routeName = '/transactions/detail';

  final TransactionModel model;

  @override
  Widget build(BuildContext context) {
    final color = model.type == TransactionType.income ? Colors.green : Colors.red;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de transaccion')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(model.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Monto: ${Helpers.formatCurrency(model.amount)}', style: TextStyle(color: color, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Categoria: ${model.category}'),
            const SizedBox(height: 8),
            Text('Fecha: ${Helpers.formatDate(model.date)}'),
            const SizedBox(height: 24),
            const Text('Notas rapidas'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: const Text('Puedes convertir esta transaccion en un recordatorio o asociarla a una meta.'),
            ),
          ],
        ),
      ),
    );
  }
}

