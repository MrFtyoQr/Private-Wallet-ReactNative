import 'package:flutter/material.dart';
import 'package:smart_wallet/core/services/api_service.dart';

class CategoryBreakdown extends StatefulWidget {
  const CategoryBreakdown({super.key});

  @override
  State<CategoryBreakdown> createState() => _CategoryBreakdownState();
}

class _CategoryBreakdownState extends State<CategoryBreakdown> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  double _totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getCategoriesAnalysis();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final categoriesData = response.data['data']['categories'] as List<dynamic>;
        
        // Filtrar solo gastos (expenses)
        final expenses = <Map<String, dynamic>>[];
        for (final cat in categoriesData) {
          if (cat['type'] == 'expense') {
            expenses.add({
              'name': cat['category'] ?? 'Otros',
              'total': (cat['total'] ?? 0).toDouble(),
            });
          }
        }

        final total = expenses.fold<double>(0.0, (sum, cat) => sum + (cat['total'] as double));

        setState(() {
          _categories = expenses;
          _totalExpenses = total;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error cargando categorías: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categories.isEmpty || _totalExpenses == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No hay datos de gastos por categoría',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    // Ordenar por total descendente
    _categories.sort((a, b) => (b['total'] as double).compareTo(a['total'] as double));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _categories.map((category) {
        final percentage = ((category['total'] as double) / _totalExpenses * 100).round();
        final value = percentage.clamp(1, 100); // Mínimo 1 para que se vea

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                flex: value,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2 + value / 100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: Text(
                  category['name'] as String,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('$percentage%'),
            ],
          ),
        );
      }).toList(),
    );
  }
}


