import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/goal_model.dart';
import 'progress_bar.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, this.onTap});

  final GoalModel goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ProgressBar(progress: goal.progress ?? goal.calculatedProgress),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Meta: ${goal.targetAmount.toStringAsFixed(0)}'),
                  Text('Ahorro: ${goal.currentAmount.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Fecha objetivo: ${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
