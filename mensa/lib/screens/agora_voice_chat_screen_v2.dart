import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/chat_message.dart';
import '../services/agora_voice_service.dart';

class AgoraVoiceChatScreenV2 extends StatefulWidget {
  final String userId;

  const AgoraVoiceChatScreenV2({super.key, required this.userId});

  @override
  State<AgoraVoiceChatScreenV2> createState() => _AgoraVoiceChatScreenV2State();
}

class _AgoraVoiceChatScreenV2State extends State<AgoraVoiceChatScreenV2> {
  late AgoraVoiceService _voiceService;

  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isRecording = false;
  bool _isProcessing = false;
  String _recordingDuration = '0:00';

  // Color palette
  static const Color _accentPink = Color(0xFFD4A5A5);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _purpleAccent = Color(0xFFD4C4E8);

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _addWelcomeMessage();
  }

  Future<void> _initializeServices() async {
    try {
      // Request microphone and speaker permissions
      await _requestAudioPermissions();

      _voiceService = AgoraVoiceService();
      await _voiceService.initialize();

      // Listen to recording state
      _voiceService.recordingState.listen((isRecording) {
        if (mounted) {
          setState(() => _isRecording = isRecording);
        }
      });

      debugPrint('✅ Agora Voice Service initialized');
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

  Future<void> _requestAudioPermissions() async {
    try {
      final micStatus = await Permission.microphone.request();
      debugPrint('🎤 Microphone permission: $micStatus');

      // Note: Speaker permission is usually granted by default on Android
      // But we ensure audio settings are available
      debugPrint('🔊 Audio permissions configured');
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
    }
  }

  void _addWelcomeMessage() {
    final greeting = '''Hello! 👋

I'm your voice-enabled health educator! 

**How to use:**
1. Long-press the microphone button
2. Speak your question
3. Release to send
4. I'll respond!

I'm here to help you understand:
• **Periods** - What they are and what's normal
• **Menopause** - The natural transition
• **Pregnancy** - The journey from conception to birth

Let's get started! 💕''';

    _messages.add(
      ChatMessage(role: 'ai', content: greeting, timestamp: DateTime.now()),
    );
  }

  Future<void> _startRecording() async {
    try {
      await _voiceService.startRecording();
      _recordingDuration = '0:00';
      _updateRecordingDuration();
      debugPrint('🎤 Recording started');
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
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

      setState(() {
        _isProcessing = true;
      });

      _addSystemMessage('🎤 Voice message recorded. Processing...');
      _scrollToBottom();

      // Simulate AI response (in production, send to backend)
      await Future.delayed(const Duration(seconds: 2));

      _addSystemMessage(
        '✅ AI: Thank you for your message! I understand your concern. How can I help you learn more?',
      );
      _scrollToBottom();

      setState(() {
        _isProcessing = false;
      });

      debugPrint('✅ Recording processed: $filePath');
    } catch (e) {
      debugPrint('❌ Error processing recording: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _addSystemMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(
          role: 'system',
          content: message,
          timestamp: DateTime.now(),
        ),
      );
    });
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
                final isSystem = message.role == 'system';

                if (isSystem) {
                  return Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        message.content,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                }

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

          // Recording indicator
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

          // Microphone button
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
                  onLongPressStart: (_) async {
                    debugPrint('🎤 Long press started');
                    await _startRecording();
                  },
                  onLongPressEnd: (_) async {
                    debugPrint('🎤 Long press ended - stopping recording');
                    await _stopRecordingAndProcess();
                  },
                  onLongPressCancel: () async {
                    debugPrint('🎤 Long press cancelled');
                    if (_isRecording) {
                      await _stopRecordingAndProcess();
                    }
                  },
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
