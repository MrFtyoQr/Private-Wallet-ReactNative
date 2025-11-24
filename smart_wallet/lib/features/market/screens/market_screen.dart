import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/models/market_data_model.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/features/market/widgets/market_card.dart';
import 'package:smart_wallet/features/market/widgets/price_chart.dart';
import 'package:smart_wallet/features/market/widgets/ai_recommendations.dart';
import 'package:smart_wallet/features/market/screens/investment_analysis_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  static const String routeName = '/market';

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<MarketDataModel> _marketData = [];
  List<MarketDataModel> _cryptoData = [];
  List<MarketDataModel> _stocksData = [];
  List<MarketDataModel> _forexData = [];
  bool _isLoading = true;
  String _selectedAsset = 'BTC';
  String _selectedCategory = 'Crypto';

  @override
  void initState() {
    super.initState();
    _loadAllMarketData();
  }

  Future<void> _loadAllMarketData() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();

      // Cargar datos de crypto
      final cryptoResponse = await apiService.getCryptoData();
      if (cryptoResponse.statusCode == 200) {
        final cryptoData =
            cryptoResponse.data['data']['crypto'] as List<dynamic>;
        _cryptoData = cryptoData.map((item) {
          // Manejar price que puede venir como String o double
          double parsePrice(dynamic value) {
            if (value == null) return 0.0;
            if (value is String) return double.parse(value);
            if (value is num) return value.toDouble();
            return 0.0;
          }

          return MarketDataModel(
            symbol: item['symbol'] ?? 'N/A',
            price: parsePrice(item['price']),
            changePercentage: parsePrice(item['change_24h']),
          );
        }).toList();
      }

      // Cargar datos de stocks
      final stocksResponse = await apiService.getStocksData();
      if (stocksResponse.statusCode == 200) {
        final stocksData =
            stocksResponse.data['data']['stocks'] as List<dynamic>;
        _stocksData = stocksData.map((item) {
          // Manejar price que puede venir como String o double
          double parsePrice(dynamic value) {
            if (value == null) return 0.0;
            if (value is String) return double.parse(value);
            if (value is num) return value.toDouble();
            return 0.0;
          }

          return MarketDataModel(
            symbol: item['symbol'] ?? 'N/A',
            price: parsePrice(item['price']),
            changePercentage: parsePrice(item['change_24h']),
          );
        }).toList();
      }

      // Datos de forex (simulados por ahora)
      _forexData = [
        MarketDataModel(symbol: 'USD/EUR', price: 0.85, changePercentage: 0.2),
        MarketDataModel(symbol: 'USD/GBP', price: 0.78, changePercentage: -0.1),
        MarketDataModel(symbol: 'USD/JPY', price: 150.0, changePercentage: 0.5),
      ];

      // Combinar todos los datos
      _marketData = [..._cryptoData, ..._stocksData, ..._forexData];

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error cargando market data: $e');
      if (mounted) {
        setState(() {
          _marketData = MarketDataModel.sampleMarket();
          _isLoading = false;
        });
      }
    }
  }

  void _selectAsset(String symbol, String category) {
    setState(() {
      _selectedAsset = symbol;
      _selectedCategory = category;
    });
  }

  List<MarketDataModel> get _currentCategoryData {
    switch (_selectedCategory) {
      case 'Crypto':
        return _cryptoData;
      case 'Stocks':
        return _stocksData;
      case 'Forex':
        return _forexData;
      default:
        return _marketData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllMarketData,
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => Navigator.pushNamed(
              context,
              InvestmentAnalysisScreen.routeName,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando datos del mercado...',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Obteniendo información actualizada',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAllMarketData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gráfica interactiva
                    PriceChart(
                      selectedAsset: _selectedAsset,
                      selectedCategory: _selectedCategory,
                    ),
                    const SizedBox(height: 24),

                    // Recomendaciones de IA
                    const AiRecommendations(),
                    const SizedBox(height: 24),

                    // Categorías de activos
                    _buildCategoryTabs(),
                    const SizedBox(height: 16),

                    // Lista de activos por categoría
                    Text(
                      '$_selectedCategory - Activos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_currentCategoryData.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No hay datos disponibles para $_selectedCategory',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._currentCategoryData.map(
                        (item) => MarketCard(
                          data: item,
                          onTap: () =>
                              _selectAsset(item.symbol, _selectedCategory),
                          isSelected: item.symbol == _selectedAsset,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['Crypto', 'Stocks', 'Forex'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                    // Seleccionar el primer activo de la categoría
                    if (_currentCategoryData.isNotEmpty) {
                      _selectedAsset = _currentCategoryData.first.symbol;
                    }
                  });
                }
              },
              selectedColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}
