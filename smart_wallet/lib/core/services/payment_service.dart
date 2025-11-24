class PaymentService {
  Future<bool> processSubscriptionPayment({required String planId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
