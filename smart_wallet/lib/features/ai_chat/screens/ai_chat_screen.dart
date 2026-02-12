import 'package:flutter/material.dart';

import 'package:smart_wallet/core/services/api_service.dart';
import 'package:smart_wallet/features/ai_chat/widgets/chat_bubble.dart';
import 'package:smart_wallet/features/ai_chat/widgets/usage_indicator.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  static const String routeName = '/ai-chat';

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final List<_Message> _messages = [];
  int _used = 0;
  int _limit = 3;
  String? _conversationId;
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      // Cargar uso de IA
      final usageResponse = await _apiService.getAIUsage();
      if (usageResponse.statusCode == 200) {
        // Formato dummy: {'statusCode': 200, 'data': {...}}
        final usageData = usageResponse.data['data'] ?? usageResponse.data;
        setState(() {
          _used = usageData['used'] ?? 0;
          _limit = usageData['limit'] ?? 10;
        });
      }

      // Cargar conversaciones previas (en modo dummy siempre está vacío)
      final conversationsResponse = await _apiService.getConversations();
      if (conversationsResponse.statusCode == 200) {
        final conversationsData = conversationsResponse.data['data'] ?? [];
        if (conversationsData is List && conversationsData.isNotEmpty) {
          // Si hay conversaciones (no en modo dummy)
          final conversations = conversationsData;
          final lastConv = conversations.first;
          _conversationId = lastConv['conversation_id'] ?? lastConv['id'];

          final messages = lastConv['messages'] as List<dynamic>?;
          if (messages != null && messages.isNotEmpty) {
            setState(() {
              for (var msg in messages) {
                if (msg['message'] != null) {
                  _messages.add(_Message(text: msg['message'], isUser: true));
                }
                if (msg['response'] != null) {
                  _messages.add(_Message(text: msg['response'], isUser: false));
                }
              }
            });
            return; // Ya cargamos mensajes, no mostrar bienvenida
          }
        }
      }

      // Mensaje de bienvenida por defecto
      setState(() {
        _messages.add(
          const _Message(
            text: 'Hola, soy tu asistente financiero. ¿En qué te puedo ayudar?',
            isUser: false,
          ),
        );
      });
    } catch (e) {
      print('Error inicializando chat: $e');
      setState(() {
        _messages.add(
          const _Message(
            text: 'Hola, soy tu asistente financiero. ¿En qué te puedo ayudar?',
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isLoading) return;

    final text = _controller.text.trim();
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _apiService.chatWithAI(
        text,
        conversationId: _conversationId,
      );

      if (response.statusCode == 200) {
        // Formato dummy: {'statusCode': 200, 'data': {...}}
        final data = response.data['data'] ?? response.data;
        setState(() {
          _messages.add(
            _Message(
              text:
                  data['response'] ?? 'Lo siento, no pude procesar tu mensaje.',
              isUser: false,
            ),
          );
          _conversationId = data['conversationId'] ?? _conversationId;
          _used++;
          _isLoading = false;
        });

        // Actualizar uso
        final usageResponse = await _apiService.getAIUsage();
        if (usageResponse.statusCode == 200) {
          final usageData = usageResponse.data['data'] ?? usageResponse.data;
          setState(() {
            _used = usageData['used'] ?? _used;
            _limit = usageData['limit'] ?? 10;
          });
        }
      } else {
        setState(() {
          _messages.add(
            _Message(
              text: 'Error al procesar tu mensaje. Intenta nuevamente.',
              isUser: false,
            ),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error enviando mensaje: $e');
      setState(() {
        _messages.add(
          _Message(
            text:
                'Error de conexión. Verifica tu internet e intenta nuevamente.',
            isUser: false,
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat con IA')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final canSend = _used < _limit || _limit >= 999999;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat con IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Ver análisis financiero',
            onPressed: _isLoading ? null : _showFinancialAnalysis,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: UsageIndicator(used: _used, limit: _limit),
          ),
          if (!canSend)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Has alcanzado tu límite de preguntas. Actualiza a Premium para preguntas ilimitadas.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final message = _messages[index];
                return ChatBubble(
                  message: message.text,
                  isUser: message.isUser,
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: canSend && !_isLoading,
                      decoration: InputDecoration(
                        hintText: canSend
                            ? 'Escribe tu pregunta'
                            : 'Límite alcanzado',
                      ),
                      onSubmitted: canSend ? (_) => _sendMessage() : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: (canSend && !_isLoading) ? _sendMessage : null,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFinancialAnalysis() async {
    try {
      final response = await _apiService.getFinancialAnalysis();
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final analysis = data['analysis'] as String? ??
            'No se pudo obtener el análisis.';
        if (!mounted) return;
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Análisis financiero'),
            content: Text(analysis),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error obteniendo análisis: $e'),
        ),
      );
    }
  }
}

class _Message {
  const _Message({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}
