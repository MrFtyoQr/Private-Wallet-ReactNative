import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  AuthService({ApiService? apiService})
    : _apiService = apiService ?? ApiService() {
    _restoreSession();
  }

  final ApiService _apiService;
  UserModel? _user;
  String? _accessToken;
  bool _loading = false;
  String? _errorMessage;

  UserModel? get currentUser => _user;
  bool get isAuthenticated => _accessToken != null;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> _restoreSession() async {
    final token = await StorageService.readToken();
    final userId = await StorageService.readUserId();
    final subscriptionType = await StorageService.readSubscriptionType();

    if (token != null && userId != null) {
      _accessToken = token;
      _user = UserModel(
        id: userId,
        name: userId,
        email: userId,
        subscriptionPlan: subscriptionType ?? 'Free',
      );
      notifyListeners();
    }
  }

  Future<bool> login(String userId, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      print('🔐 Intentando login con userId: $userId');
      
      final response = await _apiService.login(userId, password);

      print('📥 Respuesta recibida - Status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Verificar que response.data tenga la estructura correcta
        if (response.data is Map && response.data.containsKey('data')) {
          final data = response.data['data'];

          final accessToken = data['accessToken'];
          final refreshToken = data['refreshToken'];
          final userData = data['user'];

          print('✅ Tokens obtenidos correctamente');

          // Save tokens securely
          await StorageService.saveToken(accessToken);
          await StorageService.saveRefreshToken(refreshToken);
          // Usar el userId del parámetro (sin espacios) en lugar del que viene del backend
          await StorageService.saveUserId(userId);
          await StorageService.saveSubscriptionType(userData['subscriptionType']);

          // Update state
          _accessToken = accessToken;
          _user = UserModel(
            id: userId, // Usar el userId del parámetro
            name:
                userData['userId'] ??
                userId, // Mostrar el nombre del backend si existe
            email: userData['email'] ?? userId,
            subscriptionPlan: userData['subscriptionType'],
          );

          print('✅ Login exitoso - Usuario: $userId');
          notifyListeners();
          return true;
        } else {
          print('❌ Error: response.data no tiene la estructura esperada');
          _errorMessage = 'Error en el formato de respuesta';
          notifyListeners();
          return false;
        }
      }

      print('❌ Error: statusCode no es 200');
      _errorMessage = 'Error al iniciar sesión';
      notifyListeners();
      return false;
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      if (e.response != null) {
        _errorMessage =
            e.response?.data['message'] ?? 'Error al iniciar sesión';
      } else {
        _errorMessage = 'Error de conexión. Verifica tu internet.';
      }
      notifyListeners();
      return false;
    } catch (error) {
      print('❌ Error general: $error');
      _errorMessage = 'No se pudo iniciar sesión: $error';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiService.register(name, email, password);

      if (response.statusCode == 201) {
        final data = response.data['data'];

        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userData = data['user'];

        // Save tokens securely
        await StorageService.saveToken(accessToken);
        await StorageService.saveRefreshToken(refreshToken);
        // Usar el name del parámetro (el userId que ingresó el usuario)
        await StorageService.saveUserId(name);
        await StorageService.saveSubscriptionType(userData['subscriptionType']);

        // Update state
        _accessToken = accessToken;
        _user = UserModel(
          id: name, // Usar el name como userId
          name: name,
          email: email,
          subscriptionPlan: userData['subscriptionType'],
        );

        notifyListeners();
        return true;
      }

      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        _errorMessage = e.response?.data['message'] ?? 'Error al registrar';
      } else {
        _errorMessage = 'Error de conexión. Verifica tu internet.';
      }
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'No se pudo registrar';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    _user = null;
    await StorageService.clearAll();
    notifyListeners();
  }

  Future<void> refreshToken() async {
    if (_accessToken == null) return;

    try {
      final refreshToken = await StorageService.readRefreshToken();
      if (refreshToken == null) {
        await logout();
        return;
      }

      final response = await _apiService.refreshToken(refreshToken);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        await StorageService.saveToken(newAccessToken);
        await StorageService.saveRefreshToken(newRefreshToken);

        _accessToken = newAccessToken;
        notifyListeners();
      }
    } catch (e) {
      // Refresh failed, logout user
      await logout();
    }
  }

  Map<String, String> get authHeaders {
    if (_accessToken == null) return <String, String>{};
    return <String, String>{'Authorization': 'Bearer $_accessToken'};
  }

  void _setLoading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }
}

// Keep for backward compatibility
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}
