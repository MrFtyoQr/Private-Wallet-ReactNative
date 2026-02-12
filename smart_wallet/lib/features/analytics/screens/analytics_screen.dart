import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/features/analytics/widgets/category_breakdown.dart';
import 'package:smart_wallet/features/analytics/widgets/chart_widget.dart';
import 'package:smart_wallet/features/analytics/screens/reports_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  static const String routeName = '/analytics';

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _dashboard;
  bool _isLoadingDashboard = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoadingDashboard = true);
    try {
      final response = await _apiService.getDashboardSummary();
      if (response.statusCode == 200) {
        setState(() {
          _dashboard = response.data['data'] ?? response.data;
          _isLoadingDashboard = false;
        });
      } else {
        setState(() => _isLoadingDashboard = false);
      }
    } catch (_) {
      setState(() => _isLoadingDashboard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analíticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insert_drive_file_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, ReportsScreen.routeName),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDashboardSummary(context),
              const SizedBox(height: 24),
              const ChartWidget(),
              const SizedBox(height: 24),
              const Text('Distribución de gastos'),
              const SizedBox(height: 12),
              const CategoryBreakdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSummary(BuildContext context) {
    if (_isLoadingDashboard) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_dashboard == null) return const SizedBox.shrink();

    final income = (_dashboard!['income'] ?? 0.0) as double;
    final expenses = (_dashboard!['expenses'] ?? 0.0) as double;
    final balance = (_dashboard!['balance'] ?? 0.0) as double;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen (últimos 30 días)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Ingresos: ${income.toStringAsFixed(2)}'),
            Text('Gastos: ${expenses.toStringAsFixed(2)}'),
            Text('Balance: ${balance.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

