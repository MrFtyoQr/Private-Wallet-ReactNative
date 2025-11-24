import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_wallet/core/services/auth_service.dart';
import 'package:smart_wallet/features/profile/widgets/profile_item.dart';
import 'package:smart_wallet/features/profile/screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(user.name[0])),
                title: Text(user.name),
                subtitle: Text('${user.email}\nPlan: ${user.subscriptionPlan}'),
              ),
            ),
          const SizedBox(height: 16),
          ProfileItem(
            title: 'Ajustes',
            icon: Icons.settings_outlined,
            onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
          ),
          ProfileItem(
            title: 'Recordatorios',
            icon: Icons.alarm,
            onTap: () => Navigator.pushNamed(context, '/reminders'),
          ),
          ProfileItem(
            title: 'Cerrar sesion',
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

