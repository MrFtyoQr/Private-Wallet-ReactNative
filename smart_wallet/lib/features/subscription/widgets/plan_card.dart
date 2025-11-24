import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.title, required this.price, required this.features, required this.onSelect});

  final String title;
  final String price;
  final List<String> features;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(price, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...features.map((feature) => Row(
                  children: [
                    const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                )),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(onPressed: onSelect, child: const Text('Seleccionar')),
            ),
          ],
        ),
      ),
    );
  }
}

