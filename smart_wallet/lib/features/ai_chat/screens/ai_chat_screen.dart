import 'package:flutter/material.dart';

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
  final List<_Message> _messages = <_Message>[
    const _Message(text: 'Hola, soy tu asistente financiero. En que te puedo ayudar?', isUser: false),
  ];
  int _used = 1;
  final int _limit = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _controller.clear();
      _used++;
      _messages.add(const _Message(text: 'Trabajo en ello, te dare una recomendacion pronto.', isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat con IA')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: UsageIndicator(used: _used, limit: _limit),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message.text, isUser: message.isUser);
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
                      decoration: const InputDecoration(hintText: 'Escribe tu pregunta'),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send_rounded)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  const _Message({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}


