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
  bool _isLoading = true;
  String? _errorMessage;

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
      if (response.statusCode == 200 && response.data['success'] == true) {
        final remindersData = response.data['data']['reminders'] as List<dynamic>;
        setState(() {
          _reminders = remindersData
              .map((json) => ReminderModel.fromJson(json as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar los recordatorios';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando recordatorios: $e');
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
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
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
                        itemCount: _reminders.length,
                        itemBuilder: (context, index) => ReminderItem(
                          model: _reminders[index],
                          onComplete: () => _loadReminders(),
                        ),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AddReminderScreen.routeName);
          if (result == true) {
            _loadReminders();
          }
        },
        icon: const Icon(Icons.add_alert),
        label: const Text('Nuevo recordatorio'),
      ),
    );
  }
}

