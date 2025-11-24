import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/reminder_model.dart';
import '../../../core/utils/helpers.dart';

class ReminderItem extends StatelessWidget {
  const ReminderItem({super.key, required this.model});

  final ReminderModel model;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(model.isRecurring ? Icons.refresh : Icons.event),
        title: Text(model.title),
        subtitle: Text('${Helpers.formatDate(model.date)} - ${model.description}'),
        trailing: Switch(
          value: true,
          onChanged: (_) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recordatorio ${model.title} actualizado')),
          ),
        ),
      ),
    );
  }
}


