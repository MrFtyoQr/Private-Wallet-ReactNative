import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/core/services/auth_service.dart';

class AiRecommendations extends StatefulWidget {
  const AiRecommendations({super.key});

  @override
  State<AiRecommendations> createState() => _AiRecommendationsState();
}

class _AiRecommendationsState extends State<AiRecommendations> {
  String? _recommendation;
  bool _isLoading = false;
  bool _canRequestAnalysis = true;
  String? _limitMessage;

  @override
  void initState() {
    super.initState();
    _checkAnalysisLimits();
  }

  Future<void> _checkAnalysisLimits() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;

    if (user == null) return;

    try {
      final apiService = ApiService();
      final response = await apiService.getAIUsage();

      if (response.statusCode == 200 && mounted) {
        final usage = response.data['data'];
        final subscriptionType = user.subscriptionPlan;
        final dailyUsage = usage['dailyAnalysisCount'] ?? 0;
        final weeklyUsage = usage['weeklyAnalysisCount'] ?? 0;

        setState(() {
          _canRequestAnalysis = _canUserRequestAnalysis(
            subscriptionType,
            dailyUsage,
            weeklyUsage,
          );
          _limitMessage = _getLimitMessage(
            subscriptionType,
            dailyUsage,
            weeklyUsage,
          );
        });
      }
    } catch (e) {
      print('❌ Error verificando límites: $e');
    }
  }

  bool _canUserRequestAnalysis(
    String subscriptionType,
    int dailyUsage,
    int weeklyUsage,
  ) {
    switch (subscriptionType.toLowerCase()) {
      case 'premium':
        return weeklyUsage < 3; // 3 veces por semana
      case 'premium+':
        return true; // Ilimitado
      default: // free
        return dailyUsage < 1; // 1 vez por día
    }
  }

  String _getLimitMessage(
    String subscriptionType,
    int dailyUsage,
    int weeklyUsage,
  ) {
    switch (subscriptionType.toLowerCase()) {
      case 'premium':
        final remaining = 3 - weeklyUsage;
        return remaining > 0
            ? 'Análisis restantes esta semana: $remaining'
            : 'Límite semanal alcanzado. Actualiza a Premium+ para análisis ilimitados.';
      case 'premium+':
        return 'Análisis ilimitados disponibles';
      default: // free
        final remaining = 1 - dailyUsage;
        return remaining > 0
            ? 'Análisis restantes hoy: $remaining'
            : 'Límite diario alcanzado. Actualiza a Premium para más análisis.';
    }
  }

  Future<void> _loadRecommendations() async {
    if (!_canRequestAnalysis) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_limitMessage ?? 'Límite de análisis alcanzado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.getMarketAnalysis();

      if (response.statusCode == 200 && mounted) {
        final analysis = response.data['data']['analysis'];

        // Verificar si hay análisis de IA disponible
        if (analysis['hasAIAnalysis'] == true &&
            analysis['aiAnalysis'] != null) {
          setState(() {
            _recommendation = analysis['aiAnalysis'];
            _isLoading = false;
          });
        } else {
          // Usar análisis básico si no hay IA
          final recommendation = _generateRecommendation(analysis);
          setState(() {
            _recommendation = recommendation;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error cargando recomendaciones: $e');
      if (mounted) {
        setState(() {
          _recommendation = _getFallbackRecommendation();
          _isLoading = false;
        });
      }
    }
  }

  String _generateRecommendation(Map<String, dynamic> analysis) {
    final sentiment = analysis['marketSentiment'] ?? 'mixed';

    if (sentiment == 'bullish') {
      return '''
🚀 **Mercado Optimista**

El mercado está mostrando señales positivas. Te recomiendo:

• **Crypto**: Considera Bitcoin y Ethereum para exposición a largo plazo
• **Stocks**: Las acciones tecnológicas están en tendencia alcista
• **Diversificación**: Mantén un 60% acciones, 30% crypto, 10% efectivo

**¿Por qué es buena idea?**
Los mercados alcistas ofrecen oportunidades de crecimiento, pero recuerda: nunca inviertas más de lo que puedes permitirte perder.
      ''';
    } else if (sentiment == 'bearish') {
      return '''
⚠️ **Mercado Cauteloso**

El mercado muestra señales de incertidumbre. Mi recomendación:

• **Protección**: Considera bonos del tesoro y oro
• **DCA**: Usa promedios de costo para crypto
• **Efectivo**: Mantén 20-30% en efectivo para oportunidades

**¿Por qué ser cauteloso?**
Los mercados bajistas pueden ser oportunidades de compra, pero requieren paciencia y no invertir dinero que necesites pronto.
      ''';
    } else {
      return '''
⚖️ **Mercado Mixto**

El mercado muestra señales mixtas. Estrategia balanceada:

• **Diversificación**: 40% acciones, 30% crypto, 20% bonos, 10% efectivo
• **DCA**: Invierte cantidades fijas regularmente
• **Educación**: Aprende antes de invertir grandes cantidades

**¿Por qué diversificar?**
Los mercados mixtos requieren paciencia. La diversificación reduce el riesgo mientras mantienes exposición al crecimiento.
      ''';
    }
  }

  String _getFallbackRecommendation() {
    return '''
💡 **Recomendación General**

Como principiante en inversiones, te sugiero:

• **Comienza pequeño**: Invierte solo lo que puedas permitirte perder
• **Diversifica**: No pongas todos tus huevos en una canasta
• **Educación**: Aprende sobre cada activo antes de invertir
• **Paciencia**: Las inversiones son un maratón, no un sprint

**Recuerda**: No hay garantías en las inversiones. Siempre investiga y considera tu situación financiera personal.
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recomendaciones de IA',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (_limitMessage != null)
                        Text(
                          _limitMessage!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _canRequestAnalysis
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                    ],
                  ),
                ),
                if (_isLoading)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      _canRequestAnalysis ? Icons.refresh : Icons.lock,
                      color: _canRequestAnalysis
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    onPressed: _canRequestAnalysis
                        ? _loadRecommendations
                        : null,
                    iconSize: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Analizando mercado...'),
                ),
              )
            else if (_recommendation != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  _recommendation!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No se pudieron cargar las recomendaciones'),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              '💡 La IA analiza el mercado para darte consejos simples y fáciles de entender',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
