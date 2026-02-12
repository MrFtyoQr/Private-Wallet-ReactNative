import 'dart:math';

import 'local_database_service.dart';

/// Servicio de datos dummy para funcionar sin conexión al backend
/// Usa SQLite para persistir los datos localmente
class DummyDataService {
  static final DummyDataService _instance = DummyDataService._internal();
  factory DummyDataService() => _instance;
  DummyDataService._internal();

  final Random _random = Random();
  final LocalDatabaseService _db = LocalDatabaseService();
  bool _initialized = false;

  // Inicializar base de datos SQLite (sin datos dummy)
  Future<void> initialize() async {
    if (_initialized) return;
    
    print('🗄️ Inicializando base de datos SQLite...');
    
    // Solo inicializar la base de datos, NO crear datos dummy
    // Los datos se crearán cuando el usuario los agregue manualmente
    await _db.getCounts(); // Esto asegura que la BD esté inicializada
    
    _initialized = true;
    print('✅ Base de datos SQLite lista (sin datos dummy)');
  }

  // Métodos de inicialización dummy eliminados - ahora todo se guarda directamente en SQLite

  // Auth endpoints (no cambian, no necesitan persistencia)
  Map<String, dynamic> login(String userId, String password) {
    final accessToken = 'dummy_access_token_${DateTime.now().millisecondsSinceEpoch}';
    final refreshToken = 'dummy_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
    
    return {
      'statusCode': 200,
      'data': {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': {
          'id': userId,
          'userId': userId,
          'email': '$userId@example.com',
          'subscriptionType': 'Free',
        },
      },
    };
  }

  Map<String, dynamic> register(String userId, String email, String password) {
    final accessToken = 'dummy_access_token_${DateTime.now().millisecondsSinceEpoch}';
    final refreshToken = 'dummy_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
    
    return {
      'statusCode': 201,
      'data': {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': {
          'id': userId,
          'userId': userId,
          'email': email,
          'subscriptionType': 'Free',
        },
      },
    };
  }

  Map<String, dynamic> refreshToken(String refreshToken) {
    final newAccessToken = 'dummy_access_token_${DateTime.now().millisecondsSinceEpoch}';
    final newRefreshToken = 'dummy_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
    
    return {
      'statusCode': 200,
      'data': {
        'accessToken': newAccessToken,
        'refreshToken': newRefreshToken,
      },
    };
  }

  // Transactions endpoints - Ahora usan SQLite
  Future<Map<String, dynamic>> getTransactions() async {
    final transactions = await _db.getAllTransactions();
    return {
      'statusCode': 200,
      'data': transactions,
    };
  }

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> transaction) async {
    final newTransaction = {
      'id': 'transaction_${DateTime.now().millisecondsSinceEpoch}',
      'title': transaction['title'] ?? 'Nueva transacción',
      'amount': transaction['amount']?.toString() ?? '0.0',
      'type': transaction['type'] ?? 'expense',
      'category': transaction['category'] ?? 'Otros',
      'created_at': DateTime.now().toIso8601String(),
    };
    
    await _db.insertTransaction(newTransaction);
    
    return {
      'statusCode': 201,
      'data': newTransaction,
    };
  }

  Future<Map<String, dynamic>> updateTransaction(String id, Map<String, dynamic> transaction) async {
    final existing = await _db.getTransaction(id);
    if (existing == null) {
      return {
        'statusCode': 404,
        'message': 'Transacción no encontrada',
      };
    }
    
    // Actualizar solo los campos proporcionados
    final updated = Map<String, dynamic>.from(existing);
    transaction.forEach((key, value) {
      if (value != null) {
        updated[key] = value;
      }
    });
    
    await _db.updateTransaction(id, updated);
    
    return {
      'statusCode': 200,
      'data': updated,
    };
  }

  Future<Map<String, dynamic>> deleteTransaction(String id) async {
    final deleted = await _db.deleteTransaction(id);
    if (deleted > 0) {
      return {
        'statusCode': 200,
        'message': 'Transacción eliminada',
      };
    }
    return {
      'statusCode': 404,
      'message': 'Transacción no encontrada',
    };
  }

  Future<Map<String, dynamic>> getSummary() async {
    final summary = await _db.getTransactionsSummary();
    return {
      'statusCode': 200,
      'data': summary,
    };
  }

  // Goals endpoints - Ahora usan SQLite
  Future<Map<String, dynamic>> getGoals() async {
    final goals = await _db.getAllGoals();
    return {
      'statusCode': 200,
      'data': goals,
    };
  }

  Future<Map<String, dynamic>> getGoalsSummary() async {
    final goals = await _db.getAllGoals();
    double targetTotal = 0.0;
    double currentTotal = 0.0;
    int completed = 0;

    for (final goal in goals) {
      final target = (goal['target_amount'] ?? 0.0) as double;
      final current = (goal['current_amount'] ?? 0.0) as double;
      targetTotal += target;
      currentTotal += current;
      if (goal['status'] == 'completed') {
        completed++;
      }
    }

    return {
      'statusCode': 200,
      'data': {
        'totalTarget': targetTotal,
        'totalCurrent': currentTotal,
        'goalsCount': goals.length,
        'completedCount': completed,
      },
    };
  }

  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> goal) async {
    final newGoal = {
      'id': 'goal_${DateTime.now().millisecondsSinceEpoch}',
      'title': goal['title'] ?? 'Nueva meta',
      'target_amount': goal['target_amount'] ?? 0.0,
      'current_amount': goal['current_amount'] ?? 0.0,
      'deadline': goal['deadline'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
      'description': goal['description'],
      'status': goal['status'] ?? 'active',
    };
    
    await _db.insertGoal(newGoal);
    
    return {
      'statusCode': 201,
      'data': newGoal,
    };
  }

  Future<Map<String, dynamic>> updateGoal(String id, Map<String, dynamic> goal) async {
    final existing = await _db.getGoal(id);
    if (existing == null) {
      return {
        'statusCode': 404,
        'message': 'Meta no encontrada',
      };
    }
    
    final updated = Map<String, dynamic>.from(existing);
    goal.forEach((key, value) {
      if (value != null) {
        updated[key] = value;
      }
    });
    
    await _db.updateGoal(id, updated);
    
    return {
      'statusCode': 200,
      'data': updated,
    };
  }

  Future<Map<String, dynamic>> deleteGoal(String id) async {
    final deleted = await _db.deleteGoal(id);
    if (deleted > 0) {
      return {
        'statusCode': 200,
        'message': 'Meta eliminada',
      };
    }
    return {
      'statusCode': 404,
      'message': 'Meta no encontrada',
    };
  }

  Future<Map<String, dynamic>> getGoalPlan(String id) async {
    final goal = await _db.getGoal(id);
    
    if (goal == null) {
      return {
        'statusCode': 404,
        'message': 'Meta no encontrada',
      };
    }
    
    final targetAmount = (goal['target_amount'] ?? 0.0) as double;
    final currentAmount = (goal['current_amount'] ?? 0.0) as double;
    final remaining = targetAmount - currentAmount;
    final deadline = DateTime.parse(goal['deadline']);
    final daysRemaining = deadline.difference(DateTime.now()).inDays;
    final dailyAmount = daysRemaining > 0 ? remaining / daysRemaining : 0.0;
    
    return {
      'statusCode': 200,
      'data': {
        'goal': goal,
        'remaining': remaining,
        'daysRemaining': daysRemaining,
        'dailyAmount': dailyAmount,
        'monthlyAmount': dailyAmount * 30,
      },
    };
  }

  Future<Map<String, dynamic>> updateGoalProgress(String id, double amount) async {
    final goal = await _db.getGoal(id);
    if (goal == null) {
      return {
        'statusCode': 404,
        'message': 'Meta no encontrada',
      };
    }

    final current = (goal['current_amount'] ?? 0.0) as double;
    final target = (goal['target_amount'] ?? 0.0) as double;
    final newCurrent = current + amount;

    goal['current_amount'] = newCurrent > target ? target : newCurrent;
    await _db.updateGoal(id, goal);

    return {
      'statusCode': 200,
      'data': goal,
    };
  }

  Future<Map<String, dynamic>> updateGoalStatus(String id, String status) async {
    final goal = await _db.getGoal(id);
    if (goal == null) {
      return {
        'statusCode': 404,
        'message': 'Meta no encontrada',
      };
    }

    goal['status'] = status;
    await _db.updateGoal(id, goal);

    return {
      'statusCode': 200,
      'data': goal,
    };
  }

  // Reminders endpoints - Ahora usan SQLite
  Future<Map<String, dynamic>> getReminders() async {
    final reminders = await _db.getAllReminders();
    return {
      'statusCode': 200,
      'data': reminders,
    };
  }

  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> reminder) async {
    final newReminder = {
      'id': 'reminder_${DateTime.now().millisecondsSinceEpoch}',
      'title': reminder['title'] ?? 'Nuevo recordatorio',
      'description': reminder['description'] ?? '',
      'due_date': reminder['due_date'] ?? DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
      'amount': reminder['amount'],
      'is_recurring': reminder['is_recurring'] ?? 0,
      'recurrence_type': reminder['recurrence_type'],
      'reminder_days': reminder['reminder_days'] ?? 3,
      'status': 'pending',
    };
    
    await _db.insertReminder(newReminder);
    
    return {
      'statusCode': 201,
      'data': newReminder,
    };
  }

  Future<Map<String, dynamic>> markReminderComplete(String id) async {
    final reminder = await _db.getReminder(id);
    if (reminder == null) {
      return {
        'statusCode': 404,
        'message': 'Recordatorio no encontrado',
      };
    }
    
    reminder['status'] = 'completed';
    await _db.updateReminder(id, reminder);
    
    return {
      'statusCode': 200,
      'data': reminder,
    };
  }

  Future<Map<String, dynamic>> updateReminder(String id, Map<String, dynamic> reminder) async {
    final existing = await _db.getReminder(id);
    if (existing == null) {
      return {
        'statusCode': 404,
        'message': 'Recordatorio no encontrado',
      };
    }
    
    final updated = Map<String, dynamic>.from(existing);
    reminder.forEach((key, value) {
      if (value != null) {
        updated[key] = value;
      }
    });
    
    await _db.updateReminder(id, updated);
    
    return {
      'statusCode': 200,
      'data': updated,
    };
  }

  Future<Map<String, dynamic>> deleteReminder(String id) async {
    final deleted = await _db.deleteReminder(id);
    if (deleted > 0) {
      return {
        'statusCode': 200,
        'message': 'Recordatorio eliminado',
      };
    }
    return {
      'statusCode': 404,
      'message': 'Recordatorio no encontrado',
    };
  }

  Future<Map<String, dynamic>> getUpcomingReminders() async {
    final reminders = await _db.getUpcomingReminders();
    return {
      'statusCode': 200,
      'data': reminders,
    };
  }

  Future<Map<String, dynamic>> getRemindersSummary() async {
    final reminders = await _db.getAllReminders();
    int pending = 0;
    int completed = 0;
    int overdue = 0;
    final today = DateTime.now();

    for (final r in reminders) {
      final status = r['status'] as String? ?? 'pending';
      if (status == 'completed') {
        completed++;
      } else {
        final dueDate = DateTime.parse(r['due_date'] as String);
        if (dueDate.isBefore(today)) {
          overdue++;
        } else {
          pending++;
        }
      }
    }

    return {
      'statusCode': 200,
      'data': {
        'pending': pending,
        'completed': completed,
        'overdue': overdue,
        'total': reminders.length,
      },
    };
  }

  Future<Map<String, dynamic>> getRemindersNotifications() async {
    // Para modo dummy, reutilizamos los próximos recordatorios
    final upcoming = await getUpcomingReminders();
    return {
      'statusCode': 200,
      'data': {
        'notifications': upcoming['data'],
      },
    };
  }

  // Market endpoints (no cambian, son datos simulados en tiempo real)
  Map<String, dynamic> getCryptoData() {
    return {
      'statusCode': 200,
      'data': [
        {'symbol': 'BTC', 'price': 45000 + _random.nextDouble() * 5000, 'change': 2.5 + _random.nextDouble() * 5},
        {'symbol': 'ETH', 'price': 2500 + _random.nextDouble() * 500, 'change': 1.8 + _random.nextDouble() * 4},
        {'symbol': 'BNB', 'price': 300 + _random.nextDouble() * 50, 'change': -0.5 + _random.nextDouble() * 2},
        {'symbol': 'SOL', 'price': 100 + _random.nextDouble() * 20, 'change': 3.2 + _random.nextDouble() * 3},
        {'symbol': 'ADA', 'price': 0.5 + _random.nextDouble() * 0.2, 'change': 1.5 + _random.nextDouble() * 2},
      ],
    };
  }

  Map<String, dynamic> getStocksData() {
    return {
      'statusCode': 200,
      'data': [
        {'symbol': 'AAPL', 'price': 175 + _random.nextDouble() * 10, 'change': 0.8 + _random.nextDouble() * 2},
        {'symbol': 'GOOGL', 'price': 140 + _random.nextDouble() * 10, 'change': 1.2 + _random.nextDouble() * 2},
        {'symbol': 'MSFT', 'price': 380 + _random.nextDouble() * 20, 'change': 0.5 + _random.nextDouble() * 2},
        {'symbol': 'AMZN', 'price': 150 + _random.nextDouble() * 10, 'change': -0.3 + _random.nextDouble() * 2},
        {'symbol': 'TSLA', 'price': 250 + _random.nextDouble() * 20, 'change': 2.5 + _random.nextDouble() * 3},
      ],
    };
  }

  Map<String, dynamic> getMarketAnalysis() {
    return {
      'statusCode': 200,
      'data': {
        'summary': 'Mercado en tendencia alcista. Bitcoin muestra resistencia en \$45,000. Se recomienda diversificación.',
        'recommendations': [
          'Mantener posición en BTC',
          'Considerar ETH para diversificación',
          'Evitar operaciones de alto riesgo esta semana',
        ],
        'trend': 'bullish',
      },
    };
  }

  Map<String, dynamic> getPersonalizedAnalysis() {
    return {
      'statusCode': 200,
      'data': {
        'analysis': 'Basado en tu perfil de riesgo moderado, te recomendamos una cartera equilibrada con 60% acciones y 40% bonos.',
        'riskLevel': 'moderate',
        'recommendations': [
          'Invertir en fondos indexados',
          'Mantener liquidez para emergencias',
          'Revisar cartera trimestralmente',
        ],
      },
    };
  }

  // Analytics endpoints - Ahora usan SQLite
  Future<Map<String, dynamic>> getDashboardSummary() async {
    final summary = await getSummary();
    final counts = await _db.getCounts();
    
    return {
      'statusCode': 200,
      'data': {
        'balance': summary['data']['balance'],
        'income': summary['data']['income'],
        'expenses': summary['data']['expenses'],
        'transactionsCount': counts['transactions'] ?? 0,
        'goalsCount': counts['goals'] ?? 0,
        'remindersCount': counts['reminders'] ?? 0,
      },
    };
  }

  Map<String, dynamic> getTrends(String period) {
    return {
      'statusCode': 200,
      'data': {
        'period': period,
        'income': List.generate(12, (i) => {
          'date': DateTime.now().subtract(Duration(days: (12 - i) * 30)).toIso8601String().split('T')[0],
          'amount': 1000 + _random.nextDouble() * 500,
        }),
        'expenses': List.generate(12, (i) => {
          'date': DateTime.now().subtract(Duration(days: (12 - i) * 30)).toIso8601String().split('T')[0],
          'amount': 800 + _random.nextDouble() * 300,
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getCategoriesAnalysis() async {
    final transactions = await _db.getAllTransactions();
    final categories = <String, double>{};
    
    for (var transaction in transactions) {
      if (transaction['type'] == 'expense') {
        final category = transaction['category'] ?? 'Otros';
        final amount = double.tryParse(transaction['amount'].toString()) ?? 0.0;
        categories[category] = (categories[category] ?? 0.0) + amount;
      }
    }
    
    final total = categories.values.fold(0.0, (a, b) => a + b);
    
    return {
      'statusCode': 200,
      'data': categories.entries.map((e) => {
        'category': e.key,
        'amount': e.value,
        'percentage': total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0.0',
      }).toList(),
    };
  }

  Map<String, dynamic> getAnalyticsPredictions() {
    return {
      'statusCode': 200,
      'data': {
        'summary': 'Se espera que tus gastos aumenten un 5% el próximo mes.',
        'details': [
          {
            'category': 'Alimentación',
            'projectedIncrease': 8.0,
          },
          {
            'category': 'Transporte',
            'projectedIncrease': 3.5,
          },
        ],
      },
    };
  }

  Map<String, dynamic> getMonthlyReport({
    required int year,
    required int month,
  }) {
    return {
      'statusCode': 200,
      'data': {
        'year': year,
        'month': month,
        'summary': 'Reporte mensual dummy generado localmente.',
      },
    };
  }

  // Investment endpoints (no cambian)
  Map<String, dynamic> getInvestmentAnalysis() {
    return {
      'statusCode': 200,
      'data': {
        'totalValue': 15000.0,
        'profit': 1500.0,
        'profitPercentage': 10.0,
        'allocations': [
          {'asset': 'Stocks', 'percentage': 60.0, 'value': 9000.0},
          {'asset': 'Crypto', 'percentage': 30.0, 'value': 4500.0},
          {'asset': 'Bonds', 'percentage': 10.0, 'value': 1500.0},
        ],
      },
    };
  }

  Map<String, dynamic> getPersonalizedRecommendation() {
    return {
      'statusCode': 200,
      'data': {
        'recommendation': 'Basado en tu perfil, te recomendamos aumentar tu exposición a acciones tecnológicas.',
        'riskScore': 6,
        'suggestedAllocation': {
          'stocks': 65.0,
          'crypto': 25.0,
          'bonds': 10.0,
        },
      },
    };
  }

  Map<String, dynamic> createInvestmentAlert({
    required String symbol,
    required double targetPrice,
    required String direction,
  }) {
    return {
      'statusCode': 200,
      'data': {
        'symbol': symbol,
        'target_price': targetPrice,
        'direction': direction,
        'createdAt': DateTime.now().toIso8601String(),
      },
    };
  }

  Map<String, dynamic> getInvestmentTrends() {
    return {
      'statusCode': 200,
      'data': [
        {
          'asset': 'Stocks',
          'trend': 'bullish',
          'change': 4.5,
        },
        {
          'asset': 'Crypto',
          'trend': 'mixed',
          'change': 2.1,
        },
      ],
    };
  }

  Map<String, dynamic> getPortfolio() {
    return {
      'statusCode': 200,
      'data': {
        'holdings': [
          {'symbol': 'AAPL', 'shares': 10, 'price': 175.0, 'value': 1750.0},
          {'symbol': 'GOOGL', 'shares': 5, 'price': 140.0, 'value': 700.0},
          {'symbol': 'BTC', 'amount': 0.1, 'price': 45000.0, 'value': 4500.0},
        ],
        'totalValue': 6950.0,
      },
    };
  }

  // AI endpoints (no cambian)
  Map<String, dynamic> chatWithAI(String message, {String? conversationId}) {
    return {
      'statusCode': 200,
      'data': {
        'response': 'Esta es una respuesta de ejemplo del asistente de IA. Para usar el servicio real de IA, conecta el backend.',
        'conversationId': conversationId ?? 'conv_${DateTime.now().millisecondsSinceEpoch}',
      },
    };
  }

  Map<String, dynamic> getConversations() {
    return {
      'statusCode': 200,
      'data': [],
    };
  }

  Map<String, dynamic> getConversationById(String conversationId) {
    return {
      'statusCode': 200,
      'data': {
        'conversationId': conversationId,
        'messages': <Map<String, dynamic>>[],
      },
    };
  }

  Map<String, dynamic> getFinancialAnalysis() {
    return {
      'statusCode': 200,
      'data': {
        'analysis': 'Tu situación financiera es estable. Has ahorrado un 15% de tus ingresos este mes.',
        'recommendations': [
          'Mantén tu tasa de ahorro actual',
          'Considera aumentar tus inversiones',
          'Revisa tus gastos recurrentes',
        ],
      },
    };
  }

  // Payments endpoints (no cambian)
  Map<String, dynamic> createPayment(Map<String, dynamic> payment) {
    return {
      'statusCode': 200,
      'data': {
        'paymentId': 'pay_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending',
        'amount': payment['amount'],
      },
    };
  }

  Map<String, dynamic> confirmPayment(Map<String, dynamic> payment) {
    return {
      'statusCode': 200,
      'data': {
        'paymentId': payment['paymentId'],
        'status': 'completed',
      },
    };
  }

  Map<String, dynamic> getPaymentHistory() {
    return {
      'statusCode': 200,
      'data': [],
    };
  }

  Map<String, dynamic> getSubscriptionInfo() {
    return {
      'statusCode': 200,
      'data': {
        'plan': 'Free',
        'status': 'active',
        'expiresAt': null,
      },
    };
  }

  Map<String, dynamic> cancelSubscription() {
    return {
      'statusCode': 200,
      'data': {
        'plan': 'Free',
        'status': 'cancelled',
        'cancelledAt': DateTime.now().toIso8601String(),
      },
    };
  }

  // Users endpoints (no cambian)
  Map<String, dynamic> getAIUsage() {
    return {
      'statusCode': 200,
      'data': {
        'used': 0,
        'limit': 10,
        'resetAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      },
    };
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    // En modo dummy usamos un perfil básico basado en un usuario estático
    return {
      'statusCode': 200,
      'data': {
        'user': {
          'userId': 'dummy_user',
          'email': 'dummy_user@example.com',
          'subscriptionType': 'free',
          'aiQuestionsUsed': 0,
        },
      },
    };
  }
}
