import 'dart:io';

class ApiConstants {
  // 🎭 MODO DUMMY (Datos simulados sin backend)
  // Cambia a true para usar datos dummy sin conexión al backend
  static const bool useDummyData = true; // ⬅️ Cambia a false para usar backend real

  // 🌐 CONFIGURACIÓN NGROK (Túnel público)
  // Si usas ngrok, pega aquí la URL que te da (ej: https://abc123.ngrok-free.app)
  // Deja vacío para usar IP local
  static const String ngrokUrl = ''; // ⬅️ URL de ngrok (ej: https://abc123.ngrok-free.app)

  // 🔧 CONFIGURACIÓN PARA DISPOSITIVO FÍSICO (Fallback si ngrok está vacío)
  // Cambia esta IP por la IP de tu computadora en la red local
  // Para encontrarla: ipconfig (Windows) o ifconfig (Mac/Linux)
  static const String localIP =
      '172.20.10.5'; // ⬅️ TU IP LOCAL (actualizada automáticamente)

  // 📱 CONFIGURACIÓN DE BASE URL
  static String get baseUrl {
    // Si hay URL de ngrok configurada, usarla (prioridad)
    if (ngrokUrl.isNotEmpty) {
      return '$ngrokUrl/api';
    }

    // Si no, usar IP local según la plataforma
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
