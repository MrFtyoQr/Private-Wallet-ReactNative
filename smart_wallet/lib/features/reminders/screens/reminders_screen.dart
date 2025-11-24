import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/reminder_model.dart';
import 'package:smart_wallet/features/reminders/widgets/reminder_item.dart';
import 'package:smart_wallet/features/reminders/screens/add_reminder_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  static const String routeName = '/reminders';

  @override
  Widget build(BuildContext context) {
    final reminders = ReminderModel.sampleReminder();
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) => ReminderItem(model: reminders[index]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AddReminderScreen.routeName),
        icon: const Icon(Icons.add_alert),
        label: const Text('Nuevo recordatorio'),
      ),
    );
  }
}

