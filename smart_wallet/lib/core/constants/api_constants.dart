import 'dart:io';

class ApiConstants {
  // 🎭 MODO DUMMY (Datos simulados sin backend)
  static const bool useDummyData = false;

  // 🌐 NGROK (opcional): si usas túnel público, pon aquí la URL (ej: https://xxx.ngrok-free.app)
  static const String ngrokUrl = '';

  // 🔧 IP DE LA PC DONDE CORRE EL BACKEND (obligatorio para dispositivo físico)
  // Al iniciar el backend verás "Opciones: 192.168.x.x, ..." — usa una de esas IPs aquí.
  // Si no, en Windows: ipconfig (IPv4 del Wi‑Fi o Ethernet). Móvil y PC deben estar en la misma red.
  static const String hostIP = '192.168.33.97';

  // 📱 BASE URL DE LA API (nunca usar localhost en dispositivo físico)
  static String get baseUrl {
    if (ngrokUrl.isNotEmpty) {
      return '$ngrokUrl/api';
    }
    final host = hostIP;
    const port = 5001;
    if (Platform.isAndroid) {
      // Dispositivo físico: IP de la PC. Emulador: descomenta la línea siguiente.
      return 'http://$host:$port/api';
      // return 'http://10.0.2.2:$port/api'; // solo emulador Android
    } else if (Platform.isIOS) {
      return 'http://$host:$port/api';
      // return 'http://127.0.0.1:$port/api'; // solo simulador iOS
    } else {
      // Web/desktop en la misma máquina que el backend
      return 'http://127.0.0.1:$port/api';
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
