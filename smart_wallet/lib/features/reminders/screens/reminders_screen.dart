import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/reminder_model.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/features/reminders/widgets/reminder_item.dart';
import 'package:smart_wallet/features/reminders/screens/add_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  static const String routeName = '/reminders';

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ApiService _apiService = ApiService();
  List<ReminderModel> _reminders = [];
  List<ReminderModel> _upcoming = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getReminders();
      print('📋 Respuesta de recordatorios: ${response.statusCode}');
      print('📦 Data: ${response.data}');

      if (response.statusCode == 200) {
        // Formato dummy: {'statusCode': 200, 'data': [...]}
        // O backend: {'success': true, 'data': {'reminders': [...]}}
        dynamic remindersData;

        if (response.data['data'] != null) {
          if (response.data['data'] is List) {
            // Formato dummy directo
            remindersData = response.data['data'] as List<dynamic>;
          } else if (response.data['data']['reminders'] != null) {
            // Formato backend con 'reminders'
            remindersData = response.data['data']['reminders'] as List<dynamic>;
          } else {
            remindersData = [];
          }
        } else {
          remindersData = [];
        }

        print('✅ Recordatorios parseados: ${remindersData.length}');

        final upcomingResponse = await _apiService.getUpcomingReminders();
        final summaryResponse = await _apiService.getRemindersSummary();

        setState(() {
          _reminders = remindersData
              .map((json) {
                try {
                  return ReminderModel.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('❌ Error parseando recordatorio: $e');
                  print('📄 JSON: $json');
                  return null;
                }
              })
              .whereType<ReminderModel>()
              .toList();
          if (upcomingResponse.statusCode == 200 &&
              upcomingResponse.data['data'] != null) {
            final upcomingData = upcomingResponse.data['data'] as List<dynamic>;
            _upcoming = upcomingData
                .map((json) {
                  try {
                    return ReminderModel.fromJson(
                      json as Map<String, dynamic>,
                    );
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<ReminderModel>()
                .toList();
          } else {
            _upcoming = [];
          }
          if (summaryResponse.statusCode == 200) {
            _summary =
                summaryResponse.data['data'] ?? summaryResponse.data;
          } else {
            _summary = null;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Error al cargar los recordatorios (status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando recordatorios: $e');
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
        title: const Text('Recordatorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminders,
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
                    onPressed: _loadReminders,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes recordatorios aún',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primer recordatorio para empezar',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReminders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reminders.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(context),
                        const SizedBox(height: 16),
                        _buildUpcomingSection(context),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return ReminderItem(
                    model: _reminders[index - 1],
                    onComplete: () => _loadReminders(),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AddReminderScreen.routeName,
          );
          if (result == true) {
            _loadReminders();
          }
        },
        icon: const Icon(Icons.add_alert),
        label: const Text('Nuevo recordatorio'),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    if (_summary == null) return const SizedBox.shrink();

    final pending = (_summary!['pending'] ?? 0) as int;
    final completed = (_summary!['completed'] ?? 0) as int;
    final overdue = (_summary!['overdue'] ?? 0) as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryChip(
              context,
              label: 'Pendientes',
              value: pending,
              color: Colors.amber,
            ),
            _buildSummaryChip(
              context,
              label: 'Completados',
              value: completed,
              color: Colors.green,
            ),
            _buildSummaryChip(
              context,
              label: 'Vencidos',
              value: overdue,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: 14,
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    if (_upcoming.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximos 7 días',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ..._upcoming.take(3).map(
              (r) => ReminderItem(
                model: r,
                onComplete: () => _loadReminders(),
              ),
            ),
      ],
    );
  }
}
