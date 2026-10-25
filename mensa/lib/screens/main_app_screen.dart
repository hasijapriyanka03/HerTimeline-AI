import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import 'onboarding/initial_onboarding_screen.dart';
import 'menstruation/menstruation_home.dart';
import 'menopause/menopause_home.dart';
import 'pregnancy/pregnancy_home.dart';

class MainAppScreen extends StatefulWidget {
  final String userId;

  const MainAppScreen({super.key, required this.userId});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  bool _isLoading = true;
  UserProfile? _userProfile;
  Key _homeScreenKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      debugPrint('🔍 Checking profile for user: ${widget.userId}');
      final apiService = ApiService();

      // Add timeout to prevent hanging
      final profileData = await apiService
          .getUserProfile(widget.userId)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⏱️ Profile check timeout - treating as no profile');
              return null;
            },
          );

      debugPrint(
        '📦 Profile data received: ${profileData != null ? "Found" : "Not found"}',
      );

      if (!mounted) return;

      setState(() {
        if (profileData != null) {
          _userProfile = UserProfile.fromJson(profileData);
          debugPrint(
            '✅ Profile loaded: ${_userProfile!.name}, tracker: ${_userProfile!.trackerType}',
          );
        } else {
          debugPrint('❌ No profile found - showing onboarding');
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error checking profile: $e');
      if (!mounted) return;

      setState(() {
        _userProfile = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    debugPrint('🔄 Refreshing profile and rebuilding home screen...');
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _homeScreenKey = UniqueKey(); // Force complete rebuild with new key
    });
    // Add small delay to ensure profile save completed
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    await _checkProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFB6C1)),
        ),
      );
    }

    // Show onboarding if no profile
    if (_userProfile == null) {
      return InitialOnboardingScreen(userId: widget.userId);
    }

    // Route to appropriate home screen based on tracker type
    // Use key to force complete rebuild when tracker changes
    Widget homeScreen;
    switch (_userProfile!.trackerType) {
      case 'pregnancy':
        homeScreen = PregnancyHome(
          key: _homeScreenKey,
          userId: widget.userId,
          onTrackerChanged: _refreshProfile,
        );
        break;
      case 'menopause':
        homeScreen = MenopauseHome(
          key: _homeScreenKey,
          userId: widget.userId,
          onTrackerChanged: _refreshProfile,
        );
        break;
      case 'menstruation':
      default:
        homeScreen = MenstruationHome(
          key: _homeScreenKey,
          userId: widget.userId,
          onTrackerChanged: _refreshProfile,
        );
        break;
    }

    return homeScreen;
  }
}
