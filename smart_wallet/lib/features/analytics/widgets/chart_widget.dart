import 'package:flutter/material.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends StatefulWidget {
  const ChartWidget({super.key});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _trendData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrends();
  }

  Future<void> _loadTrends() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getTrends('month');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final trends = response.data['data']['trends'] as List<dynamic>;
        setState(() {
          _trendData = trends.map((item) => {
            'date': item['period'] ?? '',
            'income': (item['income'] ?? 0).toDouble(),
            'expenses': (item['expenses'] ?? 0).toDouble(),
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error cargando tendencias: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_trendData.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Text(
            'No hay datos disponibles',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final maxValue = _trendData.fold<double>(
      0.0,
      (max, item) => (item['income'] + item['expenses']) > max
          ? (item['income'] + item['expenses'])
          : max,
    );

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            Theme.of(context).colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _trendData.asMap().entries.map((entry) {
                final index = entry.key.toDouble();
                final item = entry.value;
                return FlSpot(index, (item['income'] / (maxValue > 0 ? maxValue : 1)) * 100);
              }).toList(),
              isCurved: true,
              color: Colors.green.shade300,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: _trendData.asMap().entries.map((entry) {
                final index = entry.key.toDouble();
                final item = entry.value;
                return FlSpot(index, (item['expenses'] / (maxValue > 0 ? maxValue : 1)) * 100);
              }).toList(),
              isCurved: true,
              color: Colors.red.shade300,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}


