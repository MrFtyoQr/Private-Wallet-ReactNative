class GoalModel {
  const GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
  });

  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;

  double get progress => currentAmount / targetAmount;

  static List<GoalModel> sampleGoals() => <GoalModel>[
        GoalModel(
          id: 'g1',
          title: 'Fondo de emergencia',
          targetAmount: 2000,
          currentAmount: 800,
          deadline: DateTime.now().add(const Duration(days: 120)),
        ),
        GoalModel(
          id: 'g2',
          title: 'Viaje a la playa',
          targetAmount: 1500,
          currentAmount: 450,
          deadline: DateTime.now().add(const Duration(days: 210)),
        ),
      ];
}
