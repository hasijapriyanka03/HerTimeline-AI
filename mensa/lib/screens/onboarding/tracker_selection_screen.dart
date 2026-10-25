import 'package:flutter/material.dart';
import 'onboarding_pregnancy_screen.dart';
import 'onboarding_menstruation_screen.dart';
import 'onboarding_menopause_screen.dart';

class TrackerSelectionScreen extends StatelessWidget {
  final String userId;
  final VoidCallback onComplete;
  final Map<String, dynamic>? initialData;

  const TrackerSelectionScreen({
    super.key,
    required this.userId,
    required this.onComplete,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Welcome Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE8C4C4), Color(0xFFF5E6E6)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE8C4C4).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icon/appicon.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to Mensa!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your personal health companion',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'What are you going through?',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the tracker that best fits your current journey',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                _buildTrackerCard(
                  context: context,
                  icon: Icons.calendar_today,
                  title: 'Menstruation',
                  description: 'Monitor your cycle and predict periods',
                  color: const Color(0xFFD4A5A5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardingMenstruationScreen(
                          userId: userId,
                          onComplete: onComplete,
                          initialData: initialData,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildTrackerCard(
                  context: context,
                  icon: Icons.favorite,
                  title: 'Menopause',
                  description: 'Manage symptoms and track your wellness',
                  color: const Color(0xFFC4B5D4),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardingMenopauseScreen(
                          userId: userId,
                          onComplete: onComplete,
                          initialData: initialData,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildTrackerCard(
                  context: context,
                  icon: Icons.child_care,
                  title: 'Pregnancy',
                  description: 'Track your pregnancy journey week by week',
                  color: const Color(0xFFB5C9C4),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardingPregnancyScreen(
                          userId: userId,
                          onComplete: onComplete,
                          initialData: initialData,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
