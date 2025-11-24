import 'package:flutter/material.dart';

import 'package:smart_wallet/core/models/market_data_model.dart';

class MarketCard extends StatelessWidget {
  const MarketCard({
    super.key,
    required this.data,
    this.onTap,
    this.isSelected = false,
  });

  final MarketDataModel data;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isPositive = data.changePercentage >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono del activo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getAssetColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getAssetIcon(), color: _getAssetColor(), size: 20),
              ),
              const SizedBox(width: 12),

              // Información del activo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.symbol,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFormattedPrice(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Cambio porcentual
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${data.changePercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedPrice() {
    if (data.symbol.contains('/')) {
      // Forex
      return '\$${data.price.toStringAsFixed(4)}';
    } else if (data.price > 1000) {
      // Crypto
      return '\$${data.price.toStringAsFixed(0)}';
    } else {
      // Stocks
      return '\$${data.price.toStringAsFixed(2)}';
    }
  }

  IconData _getAssetIcon() {
    if (data.symbol.contains('/')) {
      return Icons.currency_exchange;
    } else if (data.symbol == 'BTC' || data.symbol == 'ETH') {
      return Icons.currency_bitcoin;
    } else {
      return Icons.trending_up;
    }
  }

  Color _getAssetColor() {
    if (data.symbol.contains('/')) {
      return Colors.green;
    } else if (data.symbol == 'BTC' || data.symbol == 'ETH') {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
}
