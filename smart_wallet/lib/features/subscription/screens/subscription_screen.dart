import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/services/payment_service.dart';
import 'package:smart_wallet/features/subscription/widgets/plan_card.dart';
import 'package:smart_wallet/features/subscription/screens/payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  static const String routeName = '/subscription';

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PaymentService _paymentService = PaymentService();
  Map<String, dynamic>? _subscription;
  bool _loading = true;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    setState(() => _loading = true);
    final info = await _paymentService.getSubscriptionInfo();
    if (!mounted) return;
    setState(() {
      _subscription = info;
      _loading = false;
    });
  }

  Future<void> _cancelSubscription() async {
    setState(() => _processing = true);
    final ok = await _paymentService.cancelSubscription();
    if (!mounted) return;
    setState(() => _processing = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Suscripción cancelada'),
          backgroundColor: Colors.green,
        ),
      );
      _loadSubscription();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cancelar la suscripción'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan =
        _subscription?['plan']?.toString().toLowerCase() ?? 'free';
    final isPremium = currentPlan != 'free';

    return Scaffold(
      appBar: AppBar(title: const Text('Planes SmartWallet')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.horizontalPadding,
                vertical: 24,
              ),
              child: Column(
                children: [
                  if (_subscription != null)
                    Card(
                      child: ListTile(
                        title: const Text('Tu plan actual'),
                        subtitle: Text(isPremium ? 'Premium' : 'Free'),
                        trailing: isPremium
                            ? TextButton(
                                onPressed:
                                    _processing ? null : _cancelSubscription,
                                child: _processing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Cancelar'),
                              )
                            : null,
                      ),
                    ),
                  const SizedBox(height: 16),
                  PlanCard(
                    title: 'Free',
                    price: 'Sin costo',
                    features: const [
                      '3 preguntas IA por mes',
                      'Control básico de gastos',
                      'Recordatorios esenciales',
                    ],
                    onSelect: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ya tienes el plan gratuito'),
                      ),
                    ),
                  ),
                  PlanCard(
                    title: 'Premium',
                    price: '\$9.99 USD/mes',
                    features: const [
                      'Consultas IA ilimitadas',
                      'Analítica avanzada',
                      'Recordatorios inteligentes',
                      'Datos de mercado en tiempo real',
                    ],
                    onSelect: () =>
                        Navigator.pushNamed(context, PaymentScreen.routeName)
                            .then((value) {
                      if (value == true) {
                        _loadSubscription();
                      }
                    }),
                  ),
                ],
              ),
            ),
    );
  }
}

