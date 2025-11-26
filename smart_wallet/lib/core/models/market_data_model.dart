class MarketDataModel {
  const MarketDataModel({
    required this.symbol,
    required this.price,
    required this.changePercentage,
  });

  final String symbol;
  final double price;
  final double changePercentage;
}
