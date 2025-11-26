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
      if (response.statusCode == 200 && response.data['success'] == true) {
        final goalsData = response.data['data']['goals'] as List<dynamic>;
        setState(() {
          _goals = goalsData
              .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar las metas';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando metas: $e');
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGoals,
          ),
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
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
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
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
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
          final result = await Navigator.pushNamed(context, AddGoalScreen.routeName);
          if (result == true) {
            _loadGoals();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva meta'),
      ),
    );
  }
}

