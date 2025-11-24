import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_wallet/core/models/transaction_model.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/core/services/auth_service.dart';
import 'package:smart_wallet/core/utils/helpers.dart';

class RecentTransactions extends StatefulWidget {
  const RecentTransactions({super.key});

  @override
  State<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<RecentTransactions> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final auth = context.read<AuthService>();
    final userId = auth.currentUser?.id;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final apiService = ApiService();
      final response = await apiService.getTransactions(userId);

      if (response.statusCode == 200 && mounted) {
        // El backend devuelve el array directamente, no dentro de 'data'
        final data = response.data is List<dynamic>
            ? response.data as List<dynamic>
            : response.data['data'] as List<dynamic>;

        print('✅ Transacciones recibidas: ${data.length}');

        setState(() {
          _transactions = data.map((item) {
            return TransactionModel(
              id: item['id'].toString(),
              title: item['title'] ?? 'Sin título',
              amount: item['amount'] is String
                  ? double.parse(item['amount'])
                  : (item['amount'] ?? 0.0).toDouble(),
              date: DateTime.parse(item['created_at']),
              category: item['category'] ?? 'Otros',
              type: item['type'] == 'income'
                  ? TransactionType.income
                  : TransactionType.expense,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando transacciones: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transacciones recientes',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_transactions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No hay transacciones recientes',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          )
        else
          ..._transactions
              .take(5)
              .map((transaction) => _TransactionTile(model: transaction)),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.model});
  final TransactionModel model;

  @override
  Widget build(BuildContext context) {
    final color = model.type == TransactionType.income
        ? Colors.green
        : Colors.red;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(Icons.account_balance_wallet, color: color),
        ),
        title: Text(model.title),
        subtitle: Text(Helpers.formatDate(model.date)),
        trailing: Text(
          (model.type == TransactionType.income ? '+ ' : '- ') +
              Helpers.formatCurrency(model.amount),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
