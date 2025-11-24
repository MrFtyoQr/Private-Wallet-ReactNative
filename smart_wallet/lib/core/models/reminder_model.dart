class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.isRecurring,
  });

  final String id;
  final String title;
  final DateTime date;
  final String description;
  final bool isRecurring;

  static List<ReminderModel> sampleReminder() => <ReminderModel>[
        ReminderModel(
          id: 'r1',
          title: 'Pagar tarjeta de credito',
          date: DateTime.now().add(const Duration(days: 3)),
          description: 'Evita intereses pagando antes del 28',
          isRecurring: true,
        ),
        ReminderModel(
          id: 'r2',
          title: 'Recibo de luz',
          date: DateTime.now().add(const Duration(days: 10)),
          description: 'Factura mensual de energia',
          isRecurring: true,
        ),
      ];
}
