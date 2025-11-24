import 'package:flutter/material.dart';
import 'package:smart_wallet/core/services/api_service.dart';

class InvestmentAnalysisScreen extends StatefulWidget {
  const InvestmentAnalysisScreen({super.key});

  static const String routeName = '/market/analysis';

  @override
  State<InvestmentAnalysisScreen> createState() =>
      _InvestmentAnalysisScreenState();
}

class _InvestmentAnalysisScreenState extends State<InvestmentAnalysisScreen> {
  String? _analysis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.getMarketAnalysis();

      if (response.statusCode == 200 && mounted) {
        final analysis = response.data['data']['analysis'];
        final personalizedAnalysis = _generatePersonalizedAnalysis(analysis);

        setState(() {
          _analysis = personalizedAnalysis;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando análisis: $e');
      if (mounted) {
        setState(() {
          _analysis = _getFallbackAnalysis();
          _isLoading = false;
        });
      }
    }
  }

  String _generatePersonalizedAnalysis(Map<String, dynamic> analysis) {
    final cryptoTrend = analysis['crypto']['trend'] ?? 0.0;
    final stocksTrend = analysis['stocks']['trend'] ?? 0.0;
    final sentiment = analysis['marketSentiment'] ?? 'mixed';

    return '''
🤖 **Análisis Personalizado de IA**

**Estado del Mercado:**
• Crypto: ${cryptoTrend > 0 ? '📈 Alcista' : '📉 Bajista'} (${cryptoTrend.toStringAsFixed(1)}%)
• Stocks: ${stocksTrend > 0 ? '📈 Alcista' : '📉 Bajista'} (${stocksTrend.toStringAsFixed(1)}%)
• Sentimiento: ${_getSentimentEmoji(sentiment)} ${_getSentimentText(sentiment)}

**Recomendaciones para Principiantes:**

🎯 **Estrategia de Inversión:**
${_getInvestmentStrategy(sentiment)}

💰 **Distribución Sugerida:**
${_getAssetAllocation(sentiment)}

⚠️ **Advertencias Importantes:**
• Nunca inviertas dinero que necesites para gastos básicos
• La diversificación reduce el riesgo
• Los mercados pueden ser volátiles a corto plazo
• Considera tu tolerancia al riesgo

📚 **Educación Financiera:**
• Aprende sobre cada activo antes de invertir
• Comienza con cantidades pequeñas
• Usa promedios de costo (DCA) para reducir el riesgo
• Mantén un fondo de emergencia de 3-6 meses

**Recuerda:** Las inversiones son a largo plazo. La paciencia y la educación son tus mejores aliados.
    ''';
  }

  String _getSentimentEmoji(String sentiment) {
    switch (sentiment) {
      case 'bullish':
        return '🚀';
      case 'bearish':
        return '⚠️';
      default:
        return '⚖️';
    }
  }

  String _getSentimentText(String sentiment) {
    switch (sentiment) {
      case 'bullish':
        return 'Optimista - Mercado en tendencia alcista';
      case 'bearish':
        return 'Cauteloso - Mercado en tendencia bajista';
      default:
        return 'Mixto - Mercado con señales contradictorias';
    }
  }

  String _getInvestmentStrategy(String sentiment) {
    switch (sentiment) {
      case 'bullish':
        return '''• Aprovecha las tendencias alcistas con cautela
• Considera aumentar exposición a crypto gradualmente
• Mantén diversificación para proteger ganancias''';
      case 'bearish':
        return '''• Enfócate en preservar capital
• Considera bonos del tesoro y oro
• Usa promedios de costo para crypto''';
      default:
        return '''• Mantén un enfoque balanceado
• Diversifica entre diferentes activos
• Usa promedios de costo regularmente''';
    }
  }

  String _getAssetAllocation(String sentiment) {
    switch (sentiment) {
      case 'bullish':
        return '''• 50% Acciones (tech, growth)
• 30% Crypto (BTC, ETH)
• 15% Bonos
• 5% Efectivo''';
      case 'bearish':
        return '''• 30% Acciones (defensivas)
• 20% Crypto (solo BTC)
• 40% Bonos del tesoro
• 10% Efectivo''';
      default:
        return '''• 40% Acciones (diversificadas)
• 25% Crypto (BTC, ETH)
• 25% Bonos
• 10% Efectivo''';
    }
  }

  String _getFallbackAnalysis() {
    return '''
🤖 **Análisis General de IA**

**Para Principiantes en Inversiones:**

🎯 **Conceptos Básicos:**
• **Diversificación**: No pongas todos tus huevos en una canasta
• **Tiempo**: Las inversiones son un maratón, no un sprint
• **Educación**: Aprende antes de invertir grandes cantidades

💰 **Distribución Conservadora:**
• 40% Acciones (ETFs diversificados)
• 20% Crypto (solo Bitcoin y Ethereum)
• 30% Bonos del tesoro
• 10% Efectivo

⚠️ **Reglas de Oro:**
• Nunca inviertas dinero que necesites pronto
• Comienza con cantidades pequeñas
• Usa promedios de costo (invierte regularmente)
• Mantén un fondo de emergencia

📚 **Educación Recomendada:**
• Aprende sobre cada activo antes de invertir
• Entiende tu tolerancia al riesgo
• Considera tu horizonte temporal
• Busca asesoría profesional si es necesario

**Recuerda:** La inversión es personal. Lo que funciona para otros puede no funcionar para ti.
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de Inversión'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAnalysis),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Análisis Personalizado',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_analysis != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: Text(
                                _analysis!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 ¿Por qué la IA explica de forma simple?',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'La IA analiza datos complejos del mercado y los explica en términos que cualquier persona puede entender. No necesitas ser un experto en finanzas para tomar decisiones informadas.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
