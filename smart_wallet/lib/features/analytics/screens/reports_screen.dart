import 'package:flutter/material.dart';

import 'package:smart_wallet/core/services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  static const String routeName = '/analytics/reports';

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _apiService = ApiService();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final reports = <String>[
      'Predicciones de gasto/ingreso',
      'Reporte mensual actual',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(reports[index]),
          trailing: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _loading ? null : () => _handleTap(context, index),
        ),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: reports.length,
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, int index) async {
    setState(() => _loading = true);
    try {
      if (index == 0) {
        await _apiService.getAnalyticsPredictions();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Predicciones generadas (dummy/backend).'),
          ),
        );
      } else if (index == 1) {
        final now = DateTime.now();
        await _apiService.getMonthlyReport(
          year: now.year,
          month: now.month,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reporte mensual ${now.month}/${now.year} generado.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generando reporte: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

