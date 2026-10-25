import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../models/user_pregnancy.dart';
import '../models/daily_log.dart';
import '../services/api_service.dart';

class AIChatScreen extends StatefulWidget {
  final String userId;
  final int currentWeek;

  const AIChatScreen({
    super.key,
    required this.userId,
    required this.currentWeek,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isLoadingContext = true;

  // User context
  UserProfile? _userProfile;
  UserPregnancy? _pregnancyProfile;
  List<DailyLog> _recentLogs = [];

  // Modern color palette
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _accentPink = Color(0xFFD4A5A5);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _purpleAccent = Color(0xFFD4C4E8);

  @override
  void initState() {
    super.initState();
    _loadUserContext();
  }

  Future<void> _loadUserContext() async {
    setState(() => _isLoadingContext = true);

    try {
      // Load user profile
      final profileData = await _apiService.getUserProfile(widget.userId);
      if (profileData != null) {
        _userProfile = UserProfile.fromJson(profileData);
      }

      // Load pregnancy profile
      _pregnancyProfile = await _apiService.getPregnancyProfile(widget.userId);

      // Load recent daily logs (last 7 days)
      final logs = await _apiService.getDailyLogs(widget.userId);
      _recentLogs = logs.take(7).toList();

      if (mounted) {
        setState(() => _isLoadingContext = false);
        _addWelcomeMessage();
      }
    } catch (e) {
      debugPrint('Error loading user context: $e');
      if (mounted) {
        setState(() => _isLoadingContext = false);
        _addWelcomeMessage();
      }
    }
  }

  void _addWelcomeMessage() {
    final name = _userProfile?.name ?? 'there';
    final week = widget.currentWeek;

    String greeting = 'Hello $name! 💕\n\n';
    greeting += 'I\'m your pregnancy wellness companion. I\'m here to:\n\n';
    greeting += '• **Listen** to your feelings and concerns\n';
    greeting += '• **Support** you emotionally through this journey\n';
    greeting += '• **Answer** your pregnancy questions\n';
    greeting += '• **Help** you feel calm and confident\n\n';

    if (_pregnancyProfile != null) {
      greeting += 'I see you\'re in week $week of your pregnancy. ';
      greeting += 'How are you feeling today? I\'m here to listen. 🤗';
    } else {
      greeting += 'How are you feeling today? Share anything on your mind. 🤗';
    }

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
      // Build comprehensive context for AI
      final context = {
        'week': widget.currentWeek,
        'role': 'supportive_psychologist_friend',
        'tone': 'warm, empathetic, calming, non-judgmental',
        'instructions':
            'Act as a supportive friend and psychologist. Listen actively, validate feelings, provide emotional support, and help the user feel calm and understood. Use empathy and compassion. Never give medical advice, but offer emotional support and coping strategies.',
      };

      // Add user profile context
      if (_userProfile != null) {
        context['user_name'] = _userProfile!.name;
        context['user_age'] = _userProfile!.age.toString();
        if (_userProfile!.medicalConditions.isNotEmpty) {
          context['medical_conditions'] = _userProfile!.medicalConditions.join(
            ', ',
          );
        }
      }

      // Add pregnancy context
      if (_pregnancyProfile != null) {
        context['trimester'] = _pregnancyProfile!.trimester.toString();
        context['due_date'] = _pregnancyProfile!.dueDate.toIso8601String();
      }

      // Add recent mood/symptoms context
      if (_recentLogs.isNotEmpty) {
        final recentMoods = _recentLogs.map((log) => log.mood).take(3).toList();
        final recentSymptoms = _recentLogs
            .expand((log) => log.symptoms)
            .toSet()
            .take(5)
            .toList();

        context['recent_moods'] = recentMoods.join(', ');
        if (recentSymptoms.isNotEmpty) {
          context['recent_symptoms'] = recentSymptoms.join(', ');
        }
      }

      final response = await _apiService.sendChatMessage(
        userId: widget.userId,
        message: text,
        context: context,
      );

      if (response != null && mounted) {
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
      debugPrint('Error sending message: $e');
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              role: 'ai',
              content:
                  'I\'m having trouble connecting right now. Please check your internet connection and try again. I\'m here for you! 💕',
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _purpleAccent.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: _purpleAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Companion',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Here to listen & support',
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
      body: _isLoadingContext
          ? const Center(child: CircularProgressIndicator(color: _accentPink))
          : Column(
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
                          'I provide emotional support and guidance. Always consult your healthcare provider for medical advice.',
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
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
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
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Share your feelings...',
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
