import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../services/api_service.dart';

class MenstruationAIChatScreen extends StatefulWidget {
  final String userId;

  const MenstruationAIChatScreen({super.key, required this.userId});

  @override
  State<MenstruationAIChatScreen> createState() =>
      _MenstruationAIChatScreenState();
}

class _MenstruationAIChatScreenState extends State<MenstruationAIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  // Soft, calming colors
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _accentPink = Color(0xFFD4A5A5);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _purpleMood = Color(0xFFD4C4E8);

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'role': 'ai',
        'content':
            'Hello! 👋 I\'m your menstruation health assistant. I can help you with:\n\n'
            '• Understanding your cycle\n'
            '• Managing symptoms\n'
            '• Answering period-related questions\n'
            '• Providing health tips\n\n'
            'What would you like to know?',
        'timestamp': DateTime.now(),
      });
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'content': text,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final apiService = ApiService();

      // Build conversation history (exclude welcome message, take last 10 messages)
      // This gives the AI context of the last 5 conversation turns
      final conversationHistory = _messages
          .where(
            (msg) => msg['timestamp'] != _messages.first['timestamp'],
          ) // Exclude welcome
          .skip(
            _messages.length > 11 ? _messages.length - 11 : 0,
          ) // Last 10 messages
          .map((msg) {
            return {
              'role': msg['role'] == 'user'
                  ? 'user'
                  : 'model', // Gemini uses 'model' not 'ai'
              'content': msg['content'],
            };
          })
          .toList();

      final response = await apiService.sendMenstruationChatMessage(
        userId: widget.userId,
        message: text,
        history: conversationHistory,
      );

      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'content':
                response ??
                'Sorry, I couldn\'t process your request. Please try again.',
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'content':
                'Sorry, I\'m having trouble connecting. Please check your internet connection and try again.',
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _purpleMood.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: _purpleMood, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This AI provides general information only. Always consult your healthcare provider for medical advice.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? _darkPink : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isUser
                        ? Text(
                            message['content'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          )
                        : MarkdownBody(
                            data: message['content'],
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                height: 1.5,
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              listBullet: const TextStyle(
                                color: Colors.black87,
                              ),
                              code: TextStyle(
                                backgroundColor: _lightPink,
                                color: _darkPink,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _accentPink,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Thinking...',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _lightPink,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask about your cycle...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: 15,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _darkPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
