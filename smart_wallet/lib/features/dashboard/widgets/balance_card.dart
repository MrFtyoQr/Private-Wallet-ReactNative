import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/core/services/auth_service.dart';
import 'package:smart_wallet/core/utils/helpers.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  double _balance = 0.0;
  double _income = 0.0;
  double _expenses = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final auth = context.read<AuthService>();
    final userId = auth.currentUser?.id;

    print('🔍 Loading balance for userId: $userId');

    if (userId == null) {
      print('❌ No userId found');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final apiService = ApiService();
      final response = await apiService.getSummary(userId);

      print('📊 Summary response: ${response.data}');

      if (response.statusCode == 200 && mounted) {
        // El backend devuelve los datos directamente, no dentro de 'data'
        final data = response.data['data'] ?? response.data;

        print(
          '✅ Balance (raw): ${data['balance']}, Income (raw): ${data['income']}, Expenses (raw): ${data['expenses']}',
        );

        // Función helper para parsear valores que pueden ser String o Number
        double parseValue(dynamic value) {
          if (value == null) return 0.0;
          if (value is String) return double.parse(value);
          if (value is num) return value.toDouble();
          return 0.0;
        }

        setState(() {
          _balance = parseValue(data['balance']);
          _income = parseValue(data['income']);
          _expenses = parseValue(data['expenses']);
          _isLoading = false;
        });

        print(
          '✅ Balance (parsed): $_balance, Income (parsed): $_income, Expenses (parsed): $_expenses',
        );
      }
    } catch (e) {
      print('❌ Error cargando balance: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance general',
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  Helpers.formatCurrency(_balance),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BalanceBadge(
                label: 'Ingresos',
                value: '+ ${Helpers.formatCurrency(_income)}',
              ),
              _BalanceBadge(
                label: 'Gastos',
                value: '- ${Helpers.formatCurrency(_expenses)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceBadge extends StatelessWidget {
  const _BalanceBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
