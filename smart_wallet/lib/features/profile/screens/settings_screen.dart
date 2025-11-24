import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_wallet/core/services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          SwitchListTile(
            value: themeService.isDarkMode,
            title: const Text('Modo oscuro'),
            subtitle: const Text('Cambiar entre tema claro y oscuro'),
            onChanged: (_) => themeService.toggleTheme(),
          ),
          const Divider(),
          SwitchListTile(
            value: true,
            title: const Text('Notificaciones push'),
            subtitle: const Text('Recibir notificaciones de recordatorios'),
            onChanged: (_) {
              // TODO: Implementar notificaciones
            },
          ),
        ],
      ),
    );
  }
}
