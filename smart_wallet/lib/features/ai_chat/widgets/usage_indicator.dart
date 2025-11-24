import 'package:flutter/material.dart';

class UsageIndicator extends StatelessWidget {
  const UsageIndicator({super.key, required this.used, required this.limit});

  final int used;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final ratio = limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Uso de IA: $used / $limit'),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: ratio),
      ],
    );
  }
}
