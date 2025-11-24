import 'package:flutter/material.dart';

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <_CategoryData>[
      const _CategoryData(name: 'Hogar', value: 35),
      const _CategoryData(name: 'Transporte', value: 18),
      const _CategoryData(name: 'Ocio', value: 22),
      const _CategoryData(name: 'Salud', value: 10),
      const _CategoryData(name: 'Otros', value: 15),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories
          .map(
            (category) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: category.value,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2 + category.value / 100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(width: 90, child: Text(category.name)),
                  Text('${category.value}%'),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CategoryData {
  const _CategoryData({required this.name, required this.value});
  final String name;
  final int value;
}


