import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.onNavigate});

  final Future<dynamic> Function(String) onNavigate;

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionItem>[
      _ActionItem(
        title: 'Nueva transaccion',
        icon: Icons.add,
        route: '/transactions/add',
      ),
      _ActionItem(title: 'Metas', icon: Icons.flag_outlined, route: '/goals'),
      _ActionItem(
        title: 'Analiticas',
        icon: Icons.analytics_outlined,
        route: '/analytics',
      ),
      _ActionItem(
        title: 'Chat IA',
        icon: Icons.chat_bubble_outline,
        route: '/ai-chat',
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final action = actions[index];
          return GestureDetector(
            onTap: () async {
              await onNavigate(action.route);
            },
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    action.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Spacer(),
                  Text(
                    action.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.title,
    required this.icon,
    required this.route,
  });
  final String title;
  final IconData icon;
  final String route;
}
