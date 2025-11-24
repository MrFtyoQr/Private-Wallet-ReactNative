class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;

  // Remove sample data - use API instead
  // static List<TransactionModel> sample() => <TransactionModel>[];
}

enum TransactionType { income, expense }
