import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/transaction_model.dart';
import 'package:smart_wallet/core/utils/helpers.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key, required this.model, this.onTap});

  final TransactionModel model;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = model.type == TransactionType.income ? Colors.green : Colors.red;
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(model.title),
        subtitle: Text('${model.category} - ${Helpers.formatDate(model.date)}'),
        trailing: Text(
          (model.type == TransactionType.income ? '+ ' : '- ') + Helpers.formatCurrency(model.amount),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


