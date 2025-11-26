import 'package:smart_wallet/core/services/api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  Future<bool> processSubscriptionPayment({
    required String planId,
    double amount = 9.99,
    String currency = 'usd',
  }) async {
    try {
      // Crear payment intent
      final createResponse = await _apiService.createPayment({
        'amount': amount,
        'currency': currency,
      });

      if (createResponse.statusCode != 200 || createResponse.data['success'] != true) {
        return false;
      }

      // En una implementación real, aquí usarías Stripe SDK para procesar el pago
      // clientSecret se usaría con Stripe SDK: await Stripe.instance.confirmPayment(...)
      // Por ahora, simulamos la confirmación del pago
      // TODO: Integrar Stripe Flutter SDK para procesar pagos reales
      final paymentIntentId = createResponse.data['data']['paymentIntentId'];
      
      // Confirmar pago (en producción esto se haría después de que Stripe procese el pago)
      final confirmResponse = await _apiService.confirmPayment({
        'payment_intent_id': paymentIntentId,
      });

      return confirmResponse.statusCode == 200 && confirmResponse.data['success'] == true;
    } catch (e) {
      print('Error procesando pago: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPaymentHistory() async {
    try {
      final response = await _apiService.getPaymentHistory();
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error obteniendo historial de pagos: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSubscriptionInfo() async {
    try {
      final response = await _apiService.getSubscriptionInfo();
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error obteniendo información de suscripción: $e');
      return null;
    }
  }
}
