import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_wallet/core/services/payment_service.dart';
import 'package:smart_wallet/shared/widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  static const String routeName = '/subscription/payment';

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;

  Future<void> _processPayment() async {
    setState(() => _loading = true);
    final service = context.read<PaymentService>();
    final success = await service.processSubscriptionPayment(planId: 'premium');
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Pago completado' : 'Pago fallido')),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago suscripcion')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Plan Premium'),
            const SizedBox(height: 8),
            const Text('Cargo mensual de \$9.99'),
            const SizedBox(height: 24),
            CustomButton(
              label: _loading ? 'Procesando...' : 'Confirmar pago',
              onPressed: _loading ? () {} : _processPayment,
              icon: Icons.lock_open,
            ),
          ],
        ),
      ),
    );
  }
}

