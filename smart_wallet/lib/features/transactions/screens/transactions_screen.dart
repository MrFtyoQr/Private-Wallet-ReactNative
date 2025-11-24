import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_wallet/core/models/transaction_model.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/core/services/auth_service.dart';
import 'package:smart_wallet/features/transactions/widgets/transaction_item.dart';
import 'package:smart_wallet/features/transactions/screens/add_transaction_screen.dart';
import 'package:smart_wallet/features/transactions/screens/transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  static const String routeName = '/transactions';

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Transacciones')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay transacciones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primera transacción',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return TransactionItem(
                    model: transaction,
                    onTap: () => Navigator.pushNamed(
                      context,
                      TransactionDetailScreen.routeName,
                      arguments: transaction,
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: _transactions.length,
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AddTransactionScreen.routeName,
          );
          if (result == true) {
            _loadTransactions();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}
