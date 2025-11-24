import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/goal_model.dart';
import 'package:smart_wallet/features/goals/widgets/progress_bar.dart';

class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key, required this.goal});

  static const String routeName = '/goals/detail';

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de meta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ProgressBar(progress: goal.progress),
            const SizedBox(height: 12),
            Text('Meta: ${goal.targetAmount.toStringAsFixed(2)}'),
            Text('Ahorro actual: ${goal.currentAmount.toStringAsFixed(2)}'),
            Text('Fecha objetivo: ${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}'),
            const SizedBox(height: 24),
            const Text('Sugerencia AI'),
            const SizedBox(height: 12),
            const Text('Aparta 150 MXN cada semana para alcanzar tu meta en el tiempo establecido.'),
          ],
        ),
      ),
    );
  }
}

