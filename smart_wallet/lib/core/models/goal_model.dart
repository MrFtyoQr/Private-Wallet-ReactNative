class GoalModel {
  const GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.description,
    this.status,
    this.progress,
    this.daysRemaining,
    this.isOverdue,
  });

  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String? description;
  final String? status;
  final double? progress;
  final int? daysRemaining;
  final bool? isOverdue;

  double get calculatedProgress =>
      targetAmount > 0 ? (currentAmount / targetAmount) : 0.0;

  /// 🔥 Función segura para convertir cualquier valor a double
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.parse(value.toString());
  }

  /// 🔥 Función segura para convertir cualquier valor a int
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    return int.parse(value.toString());
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      targetAmount: _parseToDouble(json['target_amount']),
      currentAmount: _parseToDouble(json['current_amount']),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'].toString())
          : DateTime.now(),
      description: json['description'],
      status: json['status'],
      progress: json['progress'] != null
          ? _parseToDouble(json['progress'])
          : null,
      daysRemaining: _parseToInt(json['daysRemaining']),
      isOverdue: json['isOverdue'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline.toIso8601String().split('T')[0],
      'description': description,
      'status': status,
    };
  }
}
