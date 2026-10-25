import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/localization_provider.dart';
import 'wheel_spin_screen.dart';
import 'chat_logging_screen.dart';
import 'voice_dump_screen.dart';
import 'body_selfie_screen.dart';

class QuickLogHub extends StatefulWidget {
  final String userId;

  const QuickLogHub({super.key, required this.userId});

  @override
  State<QuickLogHub> createState() => _QuickLogHubState();
}

class _QuickLogHubState extends State<QuickLogHub> {
  // Color palette
  static const Color _primaryPurple = Color(0xFFD4C4E8);
  static const Color _lightPurple = Color(0xFFF0E6FA);
  static const Color _backgroundColor = Color(0xFFFAF5FF);
  static const Color _greenAccent = Color(0xFFB8D4C8);
  static const Color _pinkAccent = Color(0xFFE8C4C4);

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
            return Text(
              'Quick Log',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryPurple, _lightPurple],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Choose Your Logging Style 📝',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pick the way that feels right for you today',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logging Options Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildLogOption(
                    icon: Icons.casino,
                    title: 'Wheel Spin',
                    subtitle: 'Fun & Quick',
                    color: _pinkAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WheelSpinScreen(userId: widget.userId),
                      ),
                    ),
                  ),
                  _buildLogOption(
                    icon: Icons.chat_bubble,
                    title: 'Chat Log',
                    subtitle: 'Conversational',
                    color: _greenAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatLoggingScreen(userId: widget.userId),
                      ),
                    ),
                  ),
                  _buildLogOption(
                    icon: Icons.mic,
                    title: 'Voice Dump',
                    subtitle: 'Speak Freely',
                    color: _primaryPurple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VoiceDumpScreen(userId: widget.userId),
                      ),
                    ),
                  ),
                  _buildLogOption(
                    icon: Icons.camera_alt,
                    title: 'Body Selfie',
                    subtitle: 'Visual Check-in',
                    color: const Color(0xFFFFB6C1),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BodySelfieScreen(userId: widget.userId),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Tips Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Logging Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      'Consistency matters - log daily for better insights',
                    ),
                    _buildTip(
                      'Be honest - your data helps personalize recommendations',
                    ),
                    _buildTip('Mix methods - try different logging styles'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✓ ',
            style: TextStyle(
              fontSize: 14,
              color: _greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
