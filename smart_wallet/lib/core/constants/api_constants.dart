import 'dart:io';

class ApiConstants {
  // 🔧 CONFIGURACIÓN PARA DISPOSITIVO FÍSICO
  // Cambia esta IP por la IP de tu computadora en la red local
  // Para encontrarla: ipconfig (Windows) o ifconfig (Mac/Linux)
  static const String localIP =
      '192.168.33.84'; // ⬅️ TU IP LOCAL (encontrada automáticamente)

  // 📱 CONFIGURACIÓN DE BASE URL
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Para dispositivo físico Android
      return 'http://$localIP:5001/api';
      // Para emulador Android, descomenta la siguiente línea:
      // return 'http://10.0.2.2:5001/api';
    } else if (Platform.isIOS) {
      // Para dispositivo físico iOS
      return 'http://$localIP:5001/api';
      // Para iOS simulator, descomenta la siguiente línea:
      // return 'http://localhost:5001/api';
    } else {
      // Web o desktop
      return 'http://localhost:5001/api';
    }
  }

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get transactions => '$baseUrl/transactions';
  static String get goals => '$baseUrl/goals';
  static String get reminders => '$baseUrl/reminders';
  static String get marketData => '$baseUrl/market';
  static String get analytics => '$baseUrl/analytics';
  static String get subscription => '$baseUrl/subscription';
}
