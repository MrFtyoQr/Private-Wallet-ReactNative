import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/features/subscription/widgets/plan_card.dart';
import 'package:smart_wallet/features/subscription/screens/payment_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  static const String routeName = '/subscription';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planes SmartWallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 24),
        child: Column(
          children: [
            PlanCard(
              title: 'Free',
              price: 'Sin costo',
              features: const [
                '3 preguntas IA por mes',
                'Control basico de gastos',
                'Recordatorios esenciales',
              ],
              onSelect: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ya tienes el plan gratuito')),
              ),
            ),
            PlanCard(
              title: 'Premium',
              price: '\$9.99 USD/mes',
              features: const [
                'Consultas IA ilimitadas',
                'Analitica avanzada',
                'Recordatorios inteligentes',
                'Datos de mercado en tiempo real',
              ],
              onSelect: () => Navigator.pushNamed(context, PaymentScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}

