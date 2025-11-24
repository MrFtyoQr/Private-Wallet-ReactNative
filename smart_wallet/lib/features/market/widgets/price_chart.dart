import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PriceChart extends StatelessWidget {
  const PriceChart({
    super.key,
    required this.selectedAsset,
    required this.selectedCategory,
  });

  final String selectedAsset;
  final String selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor(context).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getCategoryColor(context).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con información del activo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAssetIcon(),
                  color: _getCategoryColor(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedAsset,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(context),
                      ),
                    ),
                    Text(
                      selectedCategory,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getChangeColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getChangeText(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getChangeColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Precio actual
          Text(
            _getFormattedPrice(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          // Gráfica mejorada
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.2),
                      strokeWidth: 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.1),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatPriceForChart(value),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          'Lun',
                          'Mar',
                          'Mié',
                          'Jue',
                          'Vie',
                          'Sáb',
                          'Dom',
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateChartData(),
                    isCurved: true,
                    color: _getCategoryColor(context),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        // Destacar el último punto
                        if (index == barData.spots.length - 1) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: _getCategoryColor(context),
                            strokeWidth: 3,
                            strokeColor: Colors.white,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 3,
                          color: _getCategoryColor(
                            context,
                          ).withValues(alpha: 0.6),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _getCategoryColor(context).withValues(alpha: 0.3),
                          _getCategoryColor(context).withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Footer con información adicional
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Última actualización: ${_getLastUpdate()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: _getChangeColor()),
                  const SizedBox(width: 4),
                  Text(
                    'Tendencia ${_getTrendText()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getChangeColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartData() {
    // Simulate data based on selected asset
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final basePrice = _getBasePrice();
    final volatility = _getVolatility();

    return List.generate(7, (index) {
      final variation = (random + index * 10) % 20 - 10;
      final price = basePrice + (variation * volatility);
      return FlSpot(index.toDouble(), price);
    });
  }

  double _getBasePrice() {
    switch (selectedAsset) {
      case 'BTC':
        return 45000;
      case 'ETH':
        return 3000;
      case 'AAPL':
        return 175;
      case 'MSFT':
        return 380;
      case 'USD/EUR':
        return 0.85;
      case 'USD/GBP':
        return 0.78;
      case 'USD/JPY':
        return 150.0;
      default:
        return 100;
    }
  }

  double _getVolatility() {
    switch (selectedCategory) {
      case 'Crypto':
        return 1000;
      case 'Stocks':
        return 10;
      case 'Forex':
        return 0.01;
      default:
        return 1;
    }
  }

  Color _getCategoryColor(BuildContext context) {
    switch (selectedCategory) {
      case 'Crypto':
        return Colors.orange;
      case 'Stocks':
        return Colors.blue;
      case 'Forex':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getFormattedPrice() {
    final price = _getBasePrice();
    if (selectedCategory == 'Forex') {
      return '\$${price.toStringAsFixed(4)}';
    } else if (selectedCategory == 'Crypto') {
      return '\$${price.toStringAsFixed(0)}';
    } else {
      return '\$${price.toStringAsFixed(2)}';
    }
  }

  String _formatPriceForChart(double value) {
    if (selectedCategory == 'Forex') {
      return value.toStringAsFixed(3);
    } else if (selectedCategory == 'Crypto') {
      return '\$${(value / 1000).toStringAsFixed(0)}k';
    } else {
      return '\$${value.toStringAsFixed(0)}';
    }
  }

  String _getChangeText() {
    final random = DateTime.now().millisecondsSinceEpoch % 20 - 10;
    final change = random / 100;
    return '${change > 0 ? '+' : ''}${(change * 100).toStringAsFixed(1)}%';
  }

  Color _getChangeColor() {
    final random = DateTime.now().millisecondsSinceEpoch % 20 - 10;
    return random > 0 ? Colors.green : Colors.red;
  }

  String _getTrendText() {
    final random = DateTime.now().millisecondsSinceEpoch % 20 - 10;
    return random > 0 ? 'Alcista' : 'Bajista';
  }

  String _getLastUpdate() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  IconData _getAssetIcon() {
    if (selectedAsset.contains('/')) {
      return Icons.currency_exchange;
    } else if (selectedAsset == 'BTC' || selectedAsset == 'ETH') {
      return Icons.currency_bitcoin;
    } else {
      return Icons.trending_up;
    }
  }
}
