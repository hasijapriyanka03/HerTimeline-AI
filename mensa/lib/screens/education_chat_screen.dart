import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/agora_ai_service.dart';
import '../providers/localization_provider.dart';

class EducationChatScreen extends StatefulWidget {
  final String userId;

  const EducationChatScreen({super.key, required this.userId});

  @override
  State<EducationChatScreen> createState() => _EducationChatScreenState();
}

class _EducationChatScreenState extends State<EducationChatScreen> {
  final ApiService _apiService = ApiService();
  late AgoraAIService _agoraAIService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final bool _useAgoraAI = true; // Toggle between Agora AI and backend

  // Modern color palette
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _accentPink = Color(0xFFD4A5A5);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _purpleAccent = Color(0xFFD4C4E8);

  @override
  void initState() {
    super.initState();
    _initializeAgoraAI();
    _addWelcomeMessage();
  }

  void _initializeAgoraAI() {
    // Get Gemini API key from environment or use fallback
    const geminiApiKey = String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: 'AIzaSyAfx795kOnCdA3aPFH2k4ESIFYbVDHEuY8',
    );

    _agoraAIService = AgoraAIService(geminiApiKey: geminiApiKey);
    debugPrint('✅ Agora AI Service initialized');
  }

  void _addWelcomeMessage() {
    final greeting = '''Hello! 👋

I'm your friendly health educator! I'm here to help you understand:

• **Periods** - What they are, why they happen, and what's normal
• **Menopause** - The natural transition and what to expect
• **Pregnancy** - The journey from conception to birth

Ask me anything! I'll explain in simple, easy-to-understand words. 

**Remember**: I'm here to educate, not to give medical advice. If you have health concerns, please talk to a doctor. 💕

What would you like to learn about today?''';

    _messages.add(
      ChatMessage(role: 'ai', content: greeting, timestamp: DateTime.now()),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Build education-specific context
      final context = {
        'role': 'teen_friendly_educator',
        'tone': 'simple, friendly, educational, encouraging',
        'instructions':
            '''You are a teen-friendly educator on periods, menopause, and pregnancy. 

RULES:
1. Use simple, everyday words - avoid complex medical terms
2. Be friendly and encouraging
3. NEVER give medical advice or diagnose conditions
4. Always suggest visiting a doctor for health concerns
5. Stay on-topic: only discuss periods, menopause, and pregnancy
6. If asked about other topics, politely redirect to these three topics
7. Use analogies and examples to make concepts clear
8. Be inclusive and respectful of all experiences
9. Keep responses concise but informative (2-3 paragraphs max)

TOPICS YOU CAN DISCUSS:
- What periods are and why they happen
- Menstrual cycle phases
- Common period symptoms
- What menopause is and when it happens
- Menopause symptoms and changes
- How pregnancy happens
- Pregnancy stages and development
- Common pregnancy symptoms
- Basic reproductive health education

WHAT TO AVOID:
- Medical diagnoses
- Treatment recommendations
- Medication advice
- Specific health concerns (redirect to doctor)
- Topics unrelated to periods, menopause, pregnancy''',
      };

      String response;

      if (_useAgoraAI) {
        // Use Agora AI (Gemini) for faster, more reliable responses
        debugPrint('🤖 Using Agora AI (Gemini) for response');
        response = await _agoraAIService.getEducationResponse(
          text,
          context: context,
        );
      } else {
        // Fallback to backend API
        debugPrint('🔄 Using backend API for response');
        final apiResponse = await _apiService.sendEducationChatMessage(
          userId: widget.userId,
          message: text,
          context: context,
        );
        response = apiResponse ?? 'Sorry, I could not process that.';
      }

      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              role: 'ai',
              content: response,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              role: 'ai',
              content:
                  'Oops! I\'m having trouble connecting right now. Please check your internet and try again. I\'m here to help! 💕',
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: Consumer<LocalizationProvider>(
          builder: (context, localization, _) {
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _purpleAccent.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school,
                    color: _purpleAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.getString('educate_me'),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      localization.getString('learn_about'),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'I provide educational information only. For medical advice, please consult a healthcare provider.',
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
                final isUser = message.role == 'user';

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
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isUser
                        ? Text(
                            message.content,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          )
                        : MarkdownBody(
                            data: message.content,
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
                        color: _lightPink,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Consumer<LocalizationProvider>(
                        builder: (context, localization, _) {
                          return TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: localization.getString('ask_question'),
                              border: InputBorder.none,
                              hintStyle: const TextStyle(
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
                          );
                        },
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
