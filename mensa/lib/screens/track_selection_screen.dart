import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menstruation/menstruation_onboarding_screen.dart';
import 'menopause/menopause_home.dart';
import 'pregnancy/pregnancy_home.dart';
import 'education_chat_screen.dart';

class TrackSelectionScreen extends StatelessWidget {
  final String userId;

  const TrackSelectionScreen({super.key, required this.userId});

  Future<void> _selectTrack(BuildContext context, String track) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_track', track);

    if (!context.mounted) return;

    switch (track) {
      case 'menstruation':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MenstruationOnboardingScreen(userId: userId),
          ),
        );
        break;
      case 'menopause':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MenopauseHome(userId: userId),
          ),
        );
        break;
      case 'pregnancy':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PregnancyHome(userId: userId),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7), // Very light pink background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title - Bright pink like in screenshot
              const Text(
                'Welcome to Mensa',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF69B4), // Hot pink
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle - Gray
              Text(
                'Your complete women\'s health companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 48),

              // Section header - Dark gray
              Text(
                'Choose your health journey:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 24),

              // Tracker Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildTrackerCard(
                      context,
                      'Menstruation Tracker',
                      'Track your cycle, flow, and symptoms',
                      Icons.calendar_today_rounded,
                      const Color(0xFFD4A5A5), // Lighter dusty rose
                      'menstruation',
                    ),
                    const SizedBox(height: 16),
                    _buildTrackerCard(
                      context,
                      'Menopause Tracker',
                      'Manage symptoms and track your journey',
                      Icons.favorite_rounded,
                      const Color(0xFFC4B5D4), // Lighter lavender
                      'menopause',
                    ),
                    const SizedBox(height: 16),
                    _buildTrackerCard(
                      context,
                      'Pregnancy Tracker',
                      'Week-by-week pregnancy monitoring',
                      Icons.child_care_rounded,
                      const Color(0xFFB5C9C4), // Lighter sage
                      'pregnancy',
                    ),
                    const SizedBox(height: 16),
                    _buildEducationCard(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String trackId,
  ) {
    return GestureDetector(
      onTap: () => _selectTrack(context, trackId),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with white background circle
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 34, color: color),
            ),

            const SizedBox(width: 18),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.85),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(BuildContext context) {
    const color = Color(0xFFFFB6C1); // Light pink for education
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EducationChatScreen(userId: userId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with white background circle
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.school_rounded, size: 34, color: color),
            ),

            const SizedBox(width: 18),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Educate Me',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Learn about periods, menopause & pregnancy',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.85),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
