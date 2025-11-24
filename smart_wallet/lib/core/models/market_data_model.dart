class MarketDataModel {
  const MarketDataModel({
    required this.symbol,
    required this.price,
    required this.changePercentage,
  });

  final String symbol;
  final double price;
  final double changePercentage;

  static List<MarketDataModel> sampleMarket() => <MarketDataModel>[
        MarketDataModel(symbol: 'BTC', price: 64000, changePercentage: 2.4),
        MarketDataModel(symbol: 'ETH', price: 3400, changePercentage: -1.2),
        MarketDataModel(symbol: 'AAPL', price: 189, changePercentage: 0.8),
      ];
}
