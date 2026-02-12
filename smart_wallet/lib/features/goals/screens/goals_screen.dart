import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/goal_model.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/features/goals/widgets/goal_card.dart';
import 'package:smart_wallet/features/goals/screens/add_goal_screen.dart';
import 'package:smart_wallet/features/goals/screens/goal_detail_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  static const String routeName = '/goals';

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final ApiService _apiService = ApiService();
  List<GoalModel> _goals = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getGoals();
      print('📊 Respuesta de metas: ${response.statusCode}');
      print('📦 Data: ${response.data}');

      if (response.statusCode == 200) {
        // Formato dummy: {'statusCode': 200, 'data': [...]}
        // O backend: {'success': true, 'data': {'goals': [...]}}
        dynamic goalsData;

        if (response.data['data'] != null) {
          if (response.data['data'] is List) {
            // Formato dummy directo
            goalsData = response.data['data'] as List<dynamic>;
          } else if (response.data['data']['goals'] != null) {
            // Formato backend con 'goals'
            goalsData = response.data['data']['goals'] as List<dynamic>;
          } else {
            goalsData = [];
          }
        } else {
          goalsData = [];
        }

        print('✅ Metas parseadas: ${goalsData.length}');

        // Cargar resumen de metas en paralelo
        final summaryResponse = await _apiService.getGoalsSummary();

        setState(() {
          _goals = goalsData
              .map((json) {
                try {
                  return GoalModel.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('❌ Error parseando meta: $e');
                  print('📄 JSON: $json');
                  return null;
                }
              })
              .whereType<GoalModel>()
              .toList();
          if (summaryResponse.statusCode == 200) {
            _summary = summaryResponse.data['data'] ?? summaryResponse.data;
          } else {
            _summary = null;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Error al cargar las metas (status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando metas: $e');
      setState(() {
        _errorMessage = 'Error de conexión. Intenta nuevamente.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGoals),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadGoals,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes metas aún',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primera meta para empezar',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadGoals,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _goals.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildSummaryCard(context);
                  }
                  final goal = _goals[index - 1];
                  return GoalCard(
                    goal: goal,
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        GoalDetailScreen.routeName,
                        arguments: goal,
                      );
                      if (result == true) {
                        _loadGoals();
                      }
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AddGoalScreen.routeName,
          );
          if (result == true) {
            _loadGoals();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva meta'),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    if (_summary == null) {
      return const SizedBox.shrink();
    }

    final totalTarget = (_summary!['totalTarget'] ?? 0.0) as double;
    final totalCurrent = (_summary!['totalCurrent'] ?? 0.0) as double;
    final goalsCount = (_summary!['goalsCount'] ?? 0) as int;
    final completedCount = (_summary!['completedCount'] ?? 0) as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de metas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Metas totales: $goalsCount'),
            Text('Metas completadas: $completedCount'),
            Text('Objetivo total: ${totalTarget.toStringAsFixed(0)}'),
            Text('Ahorro actual: ${totalCurrent.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }
}
