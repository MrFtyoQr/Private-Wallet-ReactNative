import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const String routeName = '/analytics/reports';

  @override
  Widget build(BuildContext context) {
    final reports = <String>[
      'Reporte mensual PDF',
      'Exportar CSV',
      'Resumen anual PDF',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(reports[index]),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Generando ${reports[index]}...')),
          ),
        ),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: reports.length,
      ),
    );
  }
}

