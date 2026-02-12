import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/core/services/auth_service.dart';
import 'package:smart_wallet/core/services/payment_service.dart';
import 'package:smart_wallet/features/profile/widgets/profile_item.dart';
import 'package:smart_wallet/features/profile/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final PaymentService _paymentService = PaymentService();

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _subscription;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final responses = await Future.wait([
        _apiService.getUserProfile(),
        _paymentService.getSubscriptionInfo(),
      ]);
      if (!mounted) return;
      final data0 = (responses[0] as dynamic)?.data;
      final profileMap = data0 is Map ? (data0['data'] ?? data0) : null;
      setState(() {
        _profile = profileMap is Map<String, dynamic> ? profileMap : null;
        _subscription = responses[1] is Map<String, dynamic> ? responses[1] as Map<String, dynamic>? : null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final backendUser = _profile?['user'] as Map<String, dynamic>?;

    final name = backendUser?['userId']?.toString() ?? user?.name ?? '';
    final email = backendUser?['email']?.toString() ?? user?.email ?? '';
    final subscriptionType =
        backendUser?['subscriptionType']?.toString() ?? user?.subscriptionPlan;
    final aiUsed = backendUser?['aiQuestionsUsed']?.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (name.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(name.isNotEmpty ? name[0] : '?'),
                      ),
                      title: Text(name),
                      subtitle: Text(
                        [
                          if (email.isNotEmpty) email,
                          if (subscriptionType != null)
                            'Plan: $subscriptionType',
                          if (aiUsed != null) 'IA usadas: $aiUsed',
                        ].join('\n'),
                      ),
                    ),
                  ),
                if (_subscription != null) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: const Text('Suscripción'),
                      subtitle: Text(
                        'Plan actual: ${_subscription!['plan'] ?? 'Free'}',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ProfileItem(
                  title: 'Ajustes',
                  icon: Icons.settings_outlined,
                  onTap: () =>
                      Navigator.pushNamed(context, SettingsScreen.routeName),
                ),
                ProfileItem(
                  title: 'Recordatorios',
                  icon: Icons.alarm,
                  onTap: () => Navigator.pushNamed(context, '/reminders'),
                ),
                ProfileItem(
                  title: 'Cerrar sesión',
                  icon: Icons.logout,
                  onTap: () {
                    auth.logout();
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                ),
              ],
            ),
    );
  }
}

