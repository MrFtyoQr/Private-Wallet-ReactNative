import 'package:dio/dio.dart';
import 'package:smart_wallet/core/constants/api_constants.dart';
import 'package:smart_wallet/core/services/storage_service.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
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

  // Auth endpoints
  Future<Response> login(String userId, String password) async {
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
    return await _dio.post(
      '/auth/register',
      data: {'user_id': userId, 'email': email, 'password': password},
    );
  }

  Future<Response> refreshToken(String refreshToken) async {
    return await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
  }

  // Transactions endpoints
  Future<Response> getTransactions(String userId) async {
    // Backend usa el userId del JWT automáticamente, no necesita pasarlo en URL
    return await _dio.get('/transactions');
  }

  Future<Response> createTransaction(Map<String, dynamic> transaction) async {
    return await _dio.post('/transactions', data: transaction);
  }

  Future<Response> updateTransaction(
    String id,
    Map<String, dynamic> transaction,
  ) async {
    return await _dio.put('/transactions/$id', data: transaction);
  }

  Future<Response> deleteTransaction(String id) async {
    return await _dio.delete('/transactions/$id');
  }

  Future<Response> getSummary(String userId) async {
    // Backend usa el userId del JWT automáticamente, no necesita pasarlo en URL
    return await _dio.get('/transactions/summary');
  }

  // AI endpoints
  Future<Response> chatWithAI(String message, {String? conversationId}) async {
    return await _dio.post(
      '/ai/chat',
      data: {'message': message, 'conversationId': conversationId},
    );
  }

  Future<Response> getConversations() async {
    return await _dio.get('/ai/conversations');
  }

  Future<Response> getFinancialAnalysis() async {
    return await _dio.get('/ai/analysis');
  }

  // Goals endpoints
  Future<Response> getGoals() async {
    return await _dio.get('/goals');
  }

  Future<Response> createGoal(Map<String, dynamic> goal) async {
    return await _dio.post('/goals', data: goal);
  }

  Future<Response> updateGoal(String id, Map<String, dynamic> goal) async {
    return await _dio.put('/goals/$id', data: goal);
  }

  Future<Response> deleteGoal(String id) async {
    return await _dio.delete('/goals/$id');
  }

  Future<Response> getGoalPlan(String id) async {
    return await _dio.get('/goals/$id/plan');
  }

  // Market endpoints
  Future<Response> getCryptoData() async {
    return await _dio.get('/market/crypto');
  }

  Future<Response> getStocksData() async {
    return await _dio.get('/market/stocks');
  }

  Future<Response> getMarketAnalysis() async {
    return await _dio.get('/market/analysis');
  }

  // Analytics endpoints
  Future<Response> getDashboardSummary() async {
    return await _dio.get('/analytics/dashboard');
  }

  Future<Response> getTrends(String period) async {
    return await _dio.get(
      '/analytics/trends',
      queryParameters: {'period': period},
    );
  }

  Future<Response> getCategoriesAnalysis() async {
    return await _dio.get('/analytics/categories');
  }

  // Reminders endpoints
  Future<Response> getReminders() async {
    return await _dio.get('/reminders');
  }

  Future<Response> createReminder(Map<String, dynamic> reminder) async {
    return await _dio.post('/reminders', data: reminder);
  }

  Future<Response> markReminderComplete(String id) async {
    return await _dio.put('/reminders/$id/complete');
  }

  Future<Response> getUpcomingReminders() async {
    return await _dio.get('/reminders/upcoming');
  }

  // Investment endpoints
  Future<Response> getInvestmentAnalysis() async {
    return await _dio.get('/investments/analysis');
  }

  Future<Response> getPersonalizedRecommendation() async {
    return await _dio.get('/investments/recommendation');
  }

  Future<Response> getPortfolio() async {
    return await _dio.get('/investments/portfolio');
  }

  // Payments endpoints
  Future<Response> createPayment(Map<String, dynamic> payment) async {
    return await _dio.post('/payments/create', data: payment);
  }

  Future<Response> confirmPayment(Map<String, dynamic> payment) async {
    return await _dio.post('/payments/confirm', data: payment);
  }

  Future<Response> getPaymentHistory() async {
    return await _dio.get('/payments/history');
  }

  Future<Response> getSubscriptionInfo() async {
    return await _dio.get('/payments/subscription');
  }

  // Users endpoints
  Future<Response> getAIUsage() async {
    return await _dio.get('/users/usage');
  }
}
