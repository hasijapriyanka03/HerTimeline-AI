import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../services/api_service.dart';

class MenopauseAIChatScreen extends StatefulWidget {
  final String userId;

  const MenopauseAIChatScreen({super.key, required this.userId});

  @override
  State<MenopauseAIChatScreen> createState() => _MenopauseAIChatScreenState();
}

class _MenopauseAIChatScreenState extends State<MenopauseAIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  // Soft, calming colors - Purple theme
  static const Color _lightPurple = Color(0xFFF0E6FA);
  static const Color _accentPurple = Color(0xFFD4C4E8);
  static const Color _darkPurple = Color(0xFF9B7FC8);
  static const Color _backgroundColor = Color(0xFFFAF5FF);

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
            'Hello! 👋 I\'m your menopause health assistant. I specialize in helping women navigate perimenopause and menopause.\n\n'
            'I can help you with:\n\n'
            '• Hot flashes and night sweats\n'
            '• Sleep disturbances\n'
            '• Mood changes and emotional support\n'
            '• Hormone therapy information\n'
            '• Lifestyle and wellness strategies\n'
            '• Bone and heart health\n\n'
            'What would you like to know about your menopause journey?',
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

      // Build conversation history (exclude welcome, last 10 messages)
      final conversationHistory = _messages
          .where((msg) => msg['timestamp'] != _messages.first['timestamp'])
          .skip(_messages.length > 11 ? _messages.length - 11 : 0)
          .map((msg) {
            return {
              'role': msg['role'] == 'user' ? 'user' : 'model',
              'content': msg['content'],
            };
          })
          .toList();

      final response = await apiService.sendMenopauseChatMessage(
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
                color: _accentPurple.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: _accentPurple,
                size: 20,
              ),
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
                  'Menopause support',
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

          // Quick Questions (only show if no messages yet or just welcome)
          if (_messages.length <= 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Questions:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickQuestion(
                        'What are normal menopause symptoms?',
                      ),
                      _buildQuickQuestion('How to manage hot flashes?'),
                      _buildQuickQuestion('When should I see a doctor?'),
                      _buildQuickQuestion('Natural remedies for menopause'),
                      _buildQuickQuestion('Is hormone therapy right for me?'),
                      _buildQuickQuestion('How to improve sleep quality?'),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                      color: isUser ? _darkPurple : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                                backgroundColor: _lightPurple,
                                color: _darkPurple,
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
                            color: _accentPurple,
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                        color: _lightPurple,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask about menopause...',
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
                        color: _darkPurple,
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

  Widget _buildQuickQuestion(String question) {
    return GestureDetector(
      onTap: () {
        _messageController.text = question;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _lightPurple,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _accentPurple.withValues(alpha: 0.3)),
        ),
        child: Text(
          question,
          style: TextStyle(
            fontSize: 13,
            color: _darkPurple,
            fontWeight: FontWeight.w500,
          ),
        ),
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
