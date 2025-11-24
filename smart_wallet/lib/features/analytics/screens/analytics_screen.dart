import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/features/analytics/widgets/category_breakdown.dart';
import 'package:smart_wallet/features/analytics/widgets/chart_widget.dart';
import 'package:smart_wallet/features/analytics/screens/reports_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const String routeName = '/analytics';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insert_drive_file_outlined),
            onPressed: () => Navigator.pushNamed(context, ReportsScreen.routeName),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ChartWidget(),
            SizedBox(height: 24),
            Text('Distribucion de gastos'),
            SizedBox(height: 12),
            CategoryBreakdown(),
          ],
        ),
      ),
    );
  }
}

