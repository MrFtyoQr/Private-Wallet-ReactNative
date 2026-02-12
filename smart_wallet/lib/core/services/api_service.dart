import 'package:dio/dio.dart';
import 'package:smart_wallet/core/constants/api_constants.dart';
import 'package:smart_wallet/core/services/dummy_data_service.dart';
import 'package:smart_wallet/core/services/storage_service.dart';

class ApiService {
  late final Dio _dio;
  final DummyDataService _dummyService = DummyDataService();

  ApiService() {
    // Inicializar datos dummy si está habilitado (async, se ejecuta en background)
    if (ApiConstants.useDummyData) {
      _dummyService.initialize().then((_) {
        print('🎭 Modo DUMMY activado - Base de datos SQLite lista');
      });
    }
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Log error for debugging
          print(
            'API Error: ${error.requestOptions.method} ${error.requestOptions.path}',
          );
          print('Status: ${error.response?.statusCode}');
          print('Message: ${error.message}');

          if (error.response?.statusCode == 401) {
            // Only try refresh token if not already on auth endpoints
            final path = error.requestOptions.path;
            if (path.contains('/auth/login') ||
                path.contains('/auth/register')) {
              // Don't refresh on login/register failures
              handler.next(error);
              return;
            }

            try {
              await _refreshToken();
              // Retry the original request
              final options = error.requestOptions;
              final token = await StorageService.readToken();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              final response = await _dio.request(
                options.path,
                options: Options(method: options.method),
                data: options.data,
                queryParameters: options.queryParameters,
              );
              handler.resolve(response);
              return;
            } catch (e) {
              // Refresh failed, logout user
              print('Token refresh failed: $e');
              await StorageService.clearAll();
              handler.next(error);
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> _refreshToken() async {
    final refreshToken = await StorageService.readRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      await StorageService.saveToken(data['accessToken']);
      await StorageService.saveRefreshToken(data['refreshToken']);
    }
  }

  // Helper para crear Response desde datos dummy
  Response _createDummyResponse(Map<String, dynamic> data) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: data['statusCode'] ?? 200,
      data: data, // Devolver data completo para que AuthService pueda acceder a data['data']
    );
  }

  // Auth endpoints
  Future<Response> login(String userId, String password) async {
    if (ApiConstants.useDummyData) {
      print('🎭 Modo DUMMY activado - Usando datos simulados para login');
      await Future.delayed(const Duration(milliseconds: 500)); // Simular delay de red
      final data = _dummyService.login(userId, password);
      print('🎭 Respuesta dummy generada: ${data['statusCode']}');
      return _createDummyResponse(data);
    }
    return await _dio.post(
      '/auth/login',
      data: {'user_id': userId, 'password': password},
    );
  }

  Future<Response> register(
    String userId,
    String email,
    String password,
  ) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final data = _dummyService.register(userId, email, password);
      return _createDummyResponse(data);
    }
    return await _dio.post(
      '/auth/register',
      data: {'user_id': userId, 'email': email, 'password': password},
    );
  }

  Future<Response> refreshToken(String refreshToken) async {
    if (ApiConstants.useDummyData) {
      final data = _dummyService.refreshToken(refreshToken);
      return _createDummyResponse(data);
    }
    return await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
  }

  // Transactions endpoints
  Future<Response> getTransactions(String userId) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getTransactions();
      return _createDummyResponse(data);
    }
    // Backend usa el userId del JWT automáticamente, no necesita pasarlo en URL
    return await _dio.get('/transactions');
  }

  Future<Response> createTransaction(Map<String, dynamic> transaction) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.createTransaction(transaction);
      return _createDummyResponse(data);
    }
    return await _dio.post('/transactions', data: transaction);
  }

  Future<Response> updateTransaction(
    String id,
    Map<String, dynamic> transaction,
  ) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.updateTransaction(id, transaction);
      return _createDummyResponse(data);
    }
    return await _dio.put('/transactions/$id', data: transaction);
  }

  Future<Response> deleteTransaction(String id) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.deleteTransaction(id);
      return _createDummyResponse(data);
    }
    return await _dio.delete('/transactions/$id');
  }

  Future<Response> getSummary(String userId) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getSummary();
      return _createDummyResponse(data);
    }
    // Backend usa el userId del JWT automáticamente, no necesita pasarlo en URL
    return await _dio.get('/transactions/summary');
  }

  // AI endpoints
  Future<Response> chatWithAI(String message, {String? conversationId}) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final data = _dummyService.chatWithAI(message, conversationId: conversationId);
      return _createDummyResponse(data);
    }
    return await _dio.post(
      '/ai/chat',
      data: {'message': message, 'conversationId': conversationId},
    );
  }

  Future<Response> getConversations() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = _dummyService.getConversations();
      return _createDummyResponse(data);
    }
    return await _dio.get('/ai/conversations');
  }

  Future<Response> getConversationById(String conversationId) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getConversationById(conversationId);
      return _createDummyResponse(data);
    }
    return await _dio.get('/ai/conversations/$conversationId');
  }

  Future<Response> getFinancialAnalysis() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final data = _dummyService.getFinancialAnalysis();
      return _createDummyResponse(data);
    }
    return await _dio.get('/ai/analysis');
  }

  // Goals endpoints
  Future<Response> getGoals() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getGoals();
      return _createDummyResponse(data);
    }
    return await _dio.get('/goals');
  }

  Future<Response> getGoalsSummary() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getGoalsSummary();
      return _createDummyResponse(data);
    }
    return await _dio.get('/goals/summary');
  }

  Future<Response> createGoal(Map<String, dynamic> goal) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.createGoal(goal);
      return _createDummyResponse(data);
    }
    return await _dio.post('/goals', data: goal);
  }

  Future<Response> updateGoal(String id, Map<String, dynamic> goal) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.updateGoal(id, goal);
      return _createDummyResponse(data);
    }
    return await _dio.put('/goals/$id', data: goal);
  }

  Future<Response> deleteGoal(String id) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.deleteGoal(id);
      return _createDummyResponse(data);
    }
    return await _dio.delete('/goals/$id');
  }

  Future<Response> getGoalPlan(String id) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getGoalPlan(id);
      return _createDummyResponse(data);
    }
    return await _dio.get('/goals/$id/plan');
  }

  Future<Response> updateGoalProgress(String id, double amount) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.updateGoalProgress(id, amount);
      return _createDummyResponse(data);
    }
    return await _dio.put(
      '/goals/$id/progress',
      data: {'amount': amount},
    );
  }

  Future<Response> updateGoalStatus(String id, String status) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.updateGoalStatus(id, status);
      return _createDummyResponse(data);
    }
    return await _dio.put(
      '/goals/$id/status',
      data: {'status': status},
    );
  }

  // Market endpoints
  Future<Response> getCryptoData() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final data = _dummyService.getCryptoData();
      return _createDummyResponse(data);
    }
    return await _dio.get('/market/crypto');
  }

  Future<Response> getStocksData() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final data = _dummyService.getStocksData();
      return _createDummyResponse(data);
    }
    return await _dio.get('/market/stocks');
  }

  Future<Response> getMarketAnalysis() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final data = _dummyService.getMarketAnalysis();
      return _createDummyResponse(data);
    }
    return await _dio.get('/market/analysis');
  }

  Future<Response> getPersonalizedAnalysis() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final data = _dummyService.getPersonalizedAnalysis();
      return _createDummyResponse(data);
    }
    return await _dio.get('/market/personalized-analysis');
  }

  // Analytics endpoints
  Future<Response> getDashboardSummary() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getDashboardSummary();
      return _createDummyResponse(data);
    }
    return await _dio.get(
      '/analytics/dashboard',
      queryParameters: {'period': 30},
    );
  }

  Future<Response> getTrends(String period) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final data = _dummyService.getTrends(period);
      return _createDummyResponse(data);
    }
    return await _dio.get(
      '/analytics/trends',
      queryParameters: {'period': period},
    );
  }

  Future<Response> getCategoriesAnalysis() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getCategoriesAnalysis();
      return _createDummyResponse(data);
    }
    return await _dio.get('/analytics/categories');
  }

  Future<Response> getAnalyticsPredictions() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final data = await _dummyService.getAnalyticsPredictions();
      return _createDummyResponse(data);
    }
    return await _dio.get('/analytics/predictions');
  }

  Future<Response> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final data = await _dummyService.getMonthlyReport(
        year: year,
        month: month,
      );
      return _createDummyResponse(data);
    }
    return await _dio.get(
      '/analytics/monthly-report',
      queryParameters: {
        'year': year,
        'month': month,
      },
    );
  }

  // Reminders endpoints
  Future<Response> getReminders() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getReminders();
      return _createDummyResponse(data);
    }
    return await _dio.get('/reminders');
  }

  Future<Response> createReminder(Map<String, dynamic> reminder) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.createReminder(reminder);
      return _createDummyResponse(data);
    }
    return await _dio.post('/reminders', data: reminder);
  }

  Future<Response> markReminderComplete(String id) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.markReminderComplete(id);
      return _createDummyResponse(data);
    }
    return await _dio.put('/reminders/$id/complete');
  }

  Future<Response> updateReminder(String id, Map<String, dynamic> reminder) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.updateReminder(id, reminder);
      return _createDummyResponse(data);
    }
    return await _dio.put('/reminders/$id', data: reminder);
  }

  Future<Response> deleteReminder(String id) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.deleteReminder(id);
      return _createDummyResponse(data);
    }
    return await _dio.delete('/reminders/$id');
  }

  Future<Response> getUpcomingReminders() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getUpcomingReminders();
      return _createDummyResponse(data);
    }
    return await _dio.get(
      '/reminders/upcoming',
      queryParameters: {'days': 7},
    );
  }

  Future<Response> getRemindersSummary() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getRemindersSummary();
      return _createDummyResponse(data);
    }
    return await _dio.get('/reminders/summary');
  }

  Future<Response> getRemindersNotifications() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getRemindersNotifications();
      return _createDummyResponse(data);
    }
    return await _dio.get('/reminders/notifications');
  }

  // Investment endpoints
  Future<Response> getInvestmentAnalysis() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final data = _dummyService.getInvestmentAnalysis();
      return _createDummyResponse(data);
    }
    return await _dio.get('/investments/analysis');
  }

  Future<Response> getPersonalizedRecommendation() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final data = _dummyService.getPersonalizedRecommendation();
      return _createDummyResponse(data);
    }
    return await _dio.get('/investments/recommendation');
  }

  Future<Response> getPortfolio() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final data = _dummyService.getPortfolio();
      return _createDummyResponse(data);
    }
    return await _dio.get('/investments/portfolio');
  }

  Future<Response> createInvestmentAlert({
    required String symbol,
    required double targetPrice,
    required String direction,
  }) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final data = await _dummyService.createInvestmentAlert(
        symbol: symbol,
        targetPrice: targetPrice,
        direction: direction,
      );
      return _createDummyResponse(data);
    }
    return await _dio.post(
      '/investments/alert',
      data: {
        'symbol': symbol,
        'target_price': targetPrice,
        'direction': direction,
      },
    );
  }

  Future<Response> getInvestmentTrends() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final data = await _dummyService.getInvestmentTrends();
      return _createDummyResponse(data);
    }
    return await _dio.get('/investments/trends');
  }

  // Payments endpoints
  Future<Response> createPayment(Map<String, dynamic> payment) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final data = _dummyService.createPayment(payment);
      return _createDummyResponse(data);
    }
    return await _dio.post('/payments/create', data: payment);
  }

  Future<Response> confirmPayment(Map<String, dynamic> payment) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final data = _dummyService.confirmPayment(payment);
      return _createDummyResponse(data);
    }
    return await _dio.post('/payments/confirm', data: payment);
  }

  Future<Response> getPaymentHistory() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = _dummyService.getPaymentHistory();
      return _createDummyResponse(data);
    }
    return await _dio.get('/payments/history');
  }

  Future<Response> getSubscriptionInfo() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = _dummyService.getSubscriptionInfo();
      return _createDummyResponse(data);
    }
    return await _dio.get('/payments/subscription');
  }

  // Users endpoints
  Future<Response> getAIUsage() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = _dummyService.getAIUsage();
      return _createDummyResponse(data);
    }
    return await _dio.get('/users/usage');
  }

  Future<Response> getUserProfile() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.getUserProfile();
      return _createDummyResponse(data);
    }
    return await _dio.get('/users/profile');
  }

  Future<Response> cancelSubscription() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = await _dummyService.cancelSubscription();
      return _createDummyResponse(data);
    }
    return await _dio.post('/payments/cancel');
  }
}
