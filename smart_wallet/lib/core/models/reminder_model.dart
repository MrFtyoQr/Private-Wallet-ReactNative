class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.isRecurring,
    this.amount,
    this.reminderDays,
    this.recurrenceType,
    this.status,
    this.daysRemaining,
    this.isOverdue,
    this.shouldNotify,
  });

  final String id;
  final String title;
  final DateTime date;
  final String description;
  final bool isRecurring;
  final double? amount;
  final int? reminderDays;
  final String? recurrenceType;
  final String? status;
  final int? daysRemaining;
  final bool? isOverdue;
  final bool? shouldNotify;

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      date: json['due_date'] != null 
          ? DateTime.parse(json['due_date'].toString())
          : DateTime.now(),
      description: json['description'] ?? '',
      isRecurring: json['is_recurring'] == 1 || json['is_recurring'] == true,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      reminderDays: json['reminder_days'] != null ? json['reminder_days'] as int : null,
      recurrenceType: json['recurrence_type'],
      status: json['status'],
      daysRemaining: json['daysRemaining'] != null ? json['daysRemaining'] as int : null,
      isOverdue: json['isOverdue'] as bool?,
      shouldNotify: json['shouldNotify'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'due_date': date.toIso8601String().split('T')[0],
      'description': description,
      'is_recurring': isRecurring,
      'amount': amount,
      'reminder_days': reminderDays ?? 3,
      'recurrence_type': recurrenceType,
    };
  }
}
