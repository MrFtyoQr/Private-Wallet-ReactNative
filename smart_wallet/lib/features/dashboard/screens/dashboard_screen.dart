import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/services/auth_service.dart';
import 'package:smart_wallet/features/dashboard/widgets/balance_card.dart';
import 'package:smart_wallet/features/dashboard/widgets/quick_actions.dart';
import 'package:smart_wallet/features/dashboard/widgets/recent_transactions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SmartWallet'),
            if (auth.currentUser != null)
              Text(
                'Hola, ${auth.currentUser!.name}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.pushNamed(context, '/reminders'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await auth.refreshToken();
          _refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BalanceCard(key: ValueKey('balance_$_refreshKey')),
              const SizedBox(height: 24),
              QuickActions(
                onNavigate: (route) async {
                  final result = await Navigator.pushNamed(context, route);
                  if (result == true) {
                    _refresh();
                  }
                },
              ),
              const SizedBox(height: 24),
              RecentTransactions(key: ValueKey('transactions_$_refreshKey')),
            ],
          ),
        ),
      ),
    );
  }
}
