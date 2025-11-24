import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/goal_model.dart';
import 'package:smart_wallet/features/goals/widgets/goal_card.dart';
import 'package:smart_wallet/features/goals/screens/add_goal_screen.dart';
import 'package:smart_wallet/features/goals/screens/goal_detail_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  static const String routeName = '/goals';

  @override
  Widget build(BuildContext context) {
    final goals = GoalModel.sampleGoals();
    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return GoalCard(
            goal: goal,
            onTap: () => Navigator.pushNamed(
              context,
              GoalDetailScreen.routeName,
              arguments: goal,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AddGoalScreen.routeName),
        icon: const Icon(Icons.add),
        label: const Text('Nueva meta'),
      ),
    );
  }
}

