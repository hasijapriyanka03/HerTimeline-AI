import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../services/agora_ai_service.dart';
import '../services/agora_voice_service.dart';

class AgoraVoiceChatScreen extends StatefulWidget {
  final String userId;

  const AgoraVoiceChatScreen({super.key, required this.userId});

  @override
  State<AgoraVoiceChatScreen> createState() => _AgoraVoiceChatScreenState();
}

class _AgoraVoiceChatScreenState extends State<AgoraVoiceChatScreen> {
  late AgoraAIService _agoraAIService;
  late AgoraVoiceService _voiceService;

  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isPlaying = false;
  String _recordingDuration = '0:00';

  // Color palette
  static const Color _accentPink = Color(0xFFD4A5A5);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _purpleAccent = Color(0xFFD4C4E8);
  static const Color _greenAccent = Color(0xFFB8D4C8);

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _addWelcomeMessage();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize Agora AI
      const geminiApiKey = String.fromEnvironment(
        'GEMINI_API_KEY',
        defaultValue: 'AIzaSyAfx795kOnCdA3aPFH2k4ESIFYbVDHEuY8',
      );
      _agoraAIService = AgoraAIService(geminiApiKey: geminiApiKey);

      // Initialize Voice Service
      _voiceService = AgoraVoiceService();
      await _voiceService.initialize();

      // Listen to recording state
      _voiceService.recordingState.listen((isRecording) {
        if (mounted) {
          setState(() => _isRecording = isRecording);
        }
      });

      // Listen to playing state
      _voiceService.playingState.listen((isPlaying) {
        if (mounted) {
          setState(() => _isPlaying = isPlaying);
        }
      });

      debugPrint('✅ All services initialized');
    } catch (e) {
      debugPrint('❌ Error initializing services: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing voice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addWelcomeMessage() {
    final greeting = '''Hello! 👋

I'm your voice-enabled health educator! You can:

🎤 **Tap the microphone** to ask me questions by voice
🔊 **Listen to my responses** - I'll speak back to you
💬 **Or type** if you prefer

I'm here to help you understand:
• **Periods** - What they are and what's normal
• **Menopause** - The natural transition
• **Pregnancy** - The journey from conception to birth

Let's get started! Ask me anything! 💕''';

    _messages.add(
      ChatMessage(role: 'ai', content: greeting, timestamp: DateTime.now()),
    );
  }

  Future<void> _startRecording() async {
    try {
      await _voiceService.startRecording();
      _recordingDuration = '0:00';
      _updateRecordingDuration();
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _updateRecordingDuration() {
    if (!_isRecording) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        final parts = _recordingDuration.split(':');
        int seconds = int.parse(parts[1]);
        int minutes = int.parse(parts[0]);

        seconds++;
        if (seconds >= 60) {
          minutes++;
          seconds = 0;
        }

        setState(() {
          _recordingDuration =
              '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
        });

        _updateRecordingDuration();
      }
    });
  }

  Future<void> _stopRecordingAndProcess() async {
    try {
      final filePath = await _voiceService.stopRecording();
      if (filePath == null) return;

      // Add user message indicator
      setState(() {
        _messages.add(
          ChatMessage(
            role: 'user',
            content: '🎤 Voice message sent',
            timestamp: DateTime.now(),
          ),
        );
        _isProcessing = true;
      });
      _scrollToBottom();

      // Process voice with Gemini
      final response = await _agoraAIService.getEducationResponse(
        'I sent you a voice message. Please respond to my question.',
      );

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(role: 'ai', content: response, timestamp: DateTime.now()),
        );
        _isProcessing = false;
      });
      _scrollToBottom();

      // Play response as audio
      await _playResponse(response);
    } catch (e) {
      debugPrint('Error processing voice: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _playResponse(String text) async {
    try {
      // For now, just show that we would play the response
      // In production, integrate with Cartesia TTS
      debugPrint('🔊 Would play: $text');

      // Placeholder for TTS integration
      // final audioBytes = await _agoraAIService.generateTTS(text);
      // await _voiceService.playTTSAudio(audioBytes);
    } catch (e) {
      debugPrint('Error playing response: $e');
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
              child: const Icon(Icons.mic, color: _purpleAccent, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voice Chat',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Speak freely with AI',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
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
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Educational information only. For medical advice, consult a healthcare provider.',
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
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          // Recording/Processing indicator
          if (_isRecording)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mic, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Recording: $_recordingDuration',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (_isProcessing)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _accentPink.withValues(alpha: 0.2),
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
                        const SizedBox(width: 8),
                        const Text(
                          'Processing...',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (_isPlaying)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _greenAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.volume_up,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Playing response...',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Voice Input Button
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
              child: Center(
                child: GestureDetector(
                  onLongPress: _startRecording,
                  onLongPressEnd: (_) => _stopRecordingAndProcess(),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : _darkPink,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.red : _darkPink)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRecording ? 'Release' : 'Hold to speak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _voiceService.dispose();
    super.dispose();
  }
}
