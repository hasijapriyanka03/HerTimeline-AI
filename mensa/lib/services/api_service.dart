import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_pregnancy.dart';
import '../models/daily_log.dart';
import '../models/checklist_status.dart';

class ApiService {
  // Android emulator uses 10.0.2.2 to access host machine's localhost https://mensa-wieee.onrender.com
  // This works consistently without needing to change IP addresses
  static const String baseUrl = 'https://mensa-wieee.onrender.com/api';

  // User Pregnancy Profile
  Future<UserPregnancy?> getPregnancyProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/pregnancy'),
      );

      if (response.statusCode == 200) {
        return UserPregnancy.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching pregnancy profile: $e');
      return null;
    }
  }

  Future<bool> createOrUpdatePregnancyProfile(UserPregnancy profile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/${profile.userId}/pregnancy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating/updating pregnancy profile: $e');
      return false;
    }
  }

  Future<bool> createPregnancyProfile(
    String userId,
    DateTime lmp,
    DateTime dueDate,
  ) async {
    try {
      final now = DateTime.now();
      final profile = UserPregnancy(
        userId: userId,
        lmpDate: lmp,
        dueDate: dueDate,
        allergies: [],
        preferences: [],
        createdAt: now,
        updatedAt: now,
      );

      return await createOrUpdatePregnancyProfile(profile);
    } catch (e) {
      print('Error creating pregnancy profile: $e');
      return false;
    }
  }

  // Weekly Progress
  Future<Map<String, dynamic>?> getWeekProgress(String userId, int week) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress/$userId/week/$week'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching week progress: $e');
      return null;
    }
  }

  // Daily Logs
  Future<bool> addDailyLog(DailyLog log) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logs/${log.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(log.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding daily log: $e');
      return false;
    }
  }

  Future<List<DailyLog>> getDailyLogs(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/logs/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DailyLog.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching daily logs: $e');
      return [];
    }
  }

  // AI Symptom Analysis
  Future<Map<String, dynamic>?> analyzeSymptoms({
    required String userId,
    required List<String> symptoms,
    required int week,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/symptom-analysis'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'symptoms': symptoms,
          'week': week,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error analyzing symptoms: $e');
      return null;
    }
  }

  // Nutrition
  Future<Map<String, dynamic>?> getNutritionRecommendations(
    String userId,
    int week,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nutrition/$userId/$week'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching nutrition recommendations: $e');
      return null;
    }
  }

  // Checklist
  Future<List<ChecklistStatus>> getChecklist(String userId, int week) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/checklist/$userId/$week'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChecklistStatus.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching checklist: $e');
      return [];
    }
  }

  Future<bool> updateChecklistTask(ChecklistStatus status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checklist/${status.userId}/${status.week}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(status.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating checklist task: $e');
      return false;
    }
  }

  // AI Chat
  Future<String?> sendChatMessage({
    required String userId,
    required String message,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'message': message,
          'context': context,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      }
      return null;
    } catch (e) {
      print('Error sending chat message: $e');
      return null;
    }
  }

  // Menstruation Tracker
  Future<bool> addMenstruationLog(Map<String, dynamic> log) async {
    try {
      // Normalize date to start of day to ensure one log per day
      final date = DateTime.parse(log['date']);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      log['date'] = normalizedDate.toIso8601String();

      final response = await http.post(
        Uri.parse('$baseUrl/menstruation/${log['user_id']}/log'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(log),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding menstruation log: $e');
      return false;
    }
  }

  Future<List<dynamic>> getMenstruationLogs(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menstruation/$userId/logs'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching menstruation logs: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getMenstruationPredictions(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menstruation/$userId/predictions'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching predictions: $e');
      return null;
    }
  }

  Future<bool> initializeMenstruationCycle({
    required String userId,
    required DateTime lastPeriodStart,
    required int averageCycleLength,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menstruation/$userId/initialize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'last_period_start': lastPeriodStart.toIso8601String(),
          'average_cycle_length': averageCycleLength,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error initializing cycle: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getMenstruationStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menstruation/$userId/stats'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching stats: $e');
      return null;
    }
  }

  // Menopause Tracker
  Future<bool> addMenopauseLog(Map<String, dynamic> log) async {
    try {
      // Normalize date to start of day to ensure one log per day
      final date = DateTime.parse(log['date']);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      log['date'] = normalizedDate.toIso8601String();

      final response = await http.post(
        Uri.parse('$baseUrl/menopause/${log['user_id']}/log'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(log),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding menopause log: $e');
      return false;
    }
  }

  Future<List<dynamic>> getMenopauseLogs(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menopause/$userId/logs'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching menopause logs: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> generateMenopauseReport(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menopause/$userId/generate-report'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error generating report: $e');
      return null;
    }
  }

  // User Profile
  Future<bool> saveUserProfile(dynamic profile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/${profile.userId}/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/profile'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Breathing Game
  Future<Map<String, dynamic>?> getBreathingGameStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/breathing/game/$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching breathing game stats: $e');
      return null;
    }
  }

  Future<bool> updateBreathingGameSession({
    required String userId,
    required int duration,
    required bool completed,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/breathing/game/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'duration': duration,
          'completed': completed,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating breathing game session: $e');
      return false;
    }
  }

  // Menstruation AI Chat (uses Ollama with Gemini fallback)
  Future<String?> sendMenstruationChatMessage({
    required String userId,
    required String message,
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      // Try Ollama first
      final response = await http.post(
        Uri.parse('$baseUrl/ollama/chat/menstruation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'message': message,
          'history': history ?? [],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('💬 Response from ${data['source'] ?? 'unknown'}');
        return data['response'];
      } else if (response.statusCode == 503) {
        // Fallback to Gemini
        debugPrint('⚠️ Ollama unavailable, trying Gemini...');
        final geminiResponse = await http.post(
          Uri.parse('$baseUrl/ai/chat/menstruation'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'message': message,
            'history': history ?? [],
          }),
        );
        if (geminiResponse.statusCode == 200) {
          final data = jsonDecode(geminiResponse.body);
          return data['response'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error sending menstruation chat message: $e');
      return 'Sorry, I\'m having trouble connecting. Please check your internet connection and try again.';
    }
  }

  // Menopause AI Chat (uses Ollama with Gemini fallback)
  Future<String?> sendMenopauseChatMessage({
    required String userId,
    required String message,
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      // Try Ollama first
      final response = await http.post(
        Uri.parse('$baseUrl/ollama/chat/menopause'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'message': message,
          'history': history ?? [],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('💬 Response from ${data['source'] ?? 'unknown'}');
        return data['response'];
      } else if (response.statusCode == 503) {
        // Fallback to Gemini
        debugPrint('⚠️ Ollama unavailable, trying Gemini...');
        final geminiResponse = await http.post(
          Uri.parse('$baseUrl/ai/chat/menopause'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'message': message,
            'history': history ?? [],
          }),
        );
        if (geminiResponse.statusCode == 200) {
          final data = jsonDecode(geminiResponse.body);
          return data['response'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error sending menopause chat message: $e');
      return 'Sorry, I\'m having trouble connecting. Please check your internet connection and try again.';
    }
  }

  // Appointments
  Future<List<dynamic>> getAppointments(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  Future<bool> addAppointment(Map<String, dynamic> appointment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/${appointment['user_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(appointment),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding appointment: $e');
      return false;
    }
  }

  Future<bool> createAppointment(Map<String, dynamic> appointment) async {
    return await addAppointment(appointment);
  }

  Future<bool> updateAppointment(Map<String, dynamic> appointment) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/appointments/${appointment['user_id']}/${appointment['id']}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(appointment),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating appointment: $e');
      return false;
    }
  }

  Future<bool> deleteAppointment(String userId, String appointmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/appointments/$userId/$appointmentId'),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting appointment: $e');
      return false;
    }
  }

  // Education AI Chat (uses Ollama with Gemini fallback)
  Future<String?> sendEducationChatMessage({
    required String userId,
    required String message,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Try Ollama first
      final response = await http.post(
        Uri.parse('$baseUrl/ollama/chat/education'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'message': message,
          'context': context ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('💬 Response from ${data['source'] ?? 'unknown'}');
        return data['response'];
      } else if (response.statusCode == 503) {
        // Fallback to Gemini
        debugPrint('⚠️ Ollama unavailable, trying Gemini...');
        final geminiResponse = await http.post(
          Uri.parse('$baseUrl/ai/chat/education'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'message': message,
            'context': context ?? {},
          }),
        );
        if (geminiResponse.statusCode == 200) {
          final data = jsonDecode(geminiResponse.body);
          return data['response'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error sending education chat message: $e');
      return 'Sorry, I\'m having trouble connecting. Please check your internet connection and try again.';
    }
  }

  // Get AI Service Status
  Future<Map<String, dynamic>?> getAIServiceStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ollama/status'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting AI service status: $e');
      return null;
    }
  }

  // Emergency Alert
  Future<bool> sendEmergencyAlert({
    required String userId,
    required Map<String, dynamic> userProfile,
    required Map<String, dynamic> emergencyContact,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/emergency/alert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'userProfile': userProfile,
          'emergencyContact': emergencyContact,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error sending emergency alert: $e');
      return false;
    }
  }

  // Medical Report OCR Analysis
  Future<Map<String, dynamic>?> analyzeMedicalReport({
    required String userId,
    required String base64Image,
    required String fileName,
    String fileType = 'image',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ocr/analyze-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'image': base64Image,
          'fileName': fileName,
          'fileType': fileType,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error analyzing medical report: $e');
      return null;
    }
  }

  // Note: PDF upload is currently handled through image picker
  // For full PDF support, consider using native file picker or document_picker package
  Future<Map<String, String>?> pickPDFFile() async {
    debugPrint(
      'PDF picker: Please use image picker for now or upload via camera/gallery',
    );
    return null;
  }

  // Audio Emotion Detection
  Future<Map<String, dynamic>?> detectAudioEmotion({
    required String base64Audio,
    String mimeType = 'audio/wav',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/audio-emotion/detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'audio': base64Audio, 'mimeType': mimeType}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error detecting audio emotion: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> analyzeAudio({
    required String base64Audio,
    required String transcription,
    String mimeType = 'audio/wav',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/audio-emotion/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'audio': base64Audio,
          'transcription': transcription,
          'mimeType': mimeType,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error analyzing audio: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAudioEmotionStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/audio-emotion/status'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting audio emotion status: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> extractSymptoms({
    required String text,
    required String emotion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/audio-emotion/extract-symptoms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'emotion': emotion}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error extracting symptoms: $e');
      return null;
    }
  }

  // Agora Conversational AI
  Future<Map<String, dynamic>?> generateRTCToken({
    required String channelName,
    required int uid,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agora-ai/generate-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'channelName': channelName, 'uid': uid}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error generating RTC token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> startAgoraAgent({
    required String channelName,
    required String agentName,
    String mode = 'education',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agora-ai/start-agent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'channelName': channelName,
          'agentName': agentName,
          'mode': mode,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error starting Agora agent: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> stopAgoraAgent({
    required String agentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agora-ai/stop-agent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'agentId': agentId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error stopping Agora agent: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAgoraAgentStatus({
    required String agentId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agora-ai/agent-status/$agentId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting agent status: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAgoraAIStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/agora-ai/status'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting Agora AI status: $e');
      return null;
    }
  }

  Future<String?> getAgoraGreeting({String mode = 'education'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agora-ai/greeting?mode=$mode'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['greeting'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting Agora greeting: $e');
      return null;
    }
  }

  // Wallet APIs
  Future<Map<String, dynamic>?> getUserWallet(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/wallet/$userId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching wallet: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> addWalletPoints(
    String userId,
    int amount,
    String reason,
    String category,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/$userId/add-points'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'reason': reason,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error adding points: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getWalletHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/$userId/history'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['history'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching wallet history: $e');
      return null;
    }
  }

  // Streak APIs
  Future<Map<String, dynamic>?> getStreak(
    String userId,
    String category,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/streak/$userId/$category'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching streak: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkInStreak(
    String userId,
    String category,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/streak/$userId/$category/check-in'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error checking in streak: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getAllStreaks(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/streak/$userId/all'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['streaks'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching all streaks: $e');
      return null;
    }
  }

  // Voucher APIs
  Future<List<dynamic>?> getAvailableVouchers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/voucher/available'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['vouchers'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching vouchers: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getUserVouchers(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/voucher/$userId/my-vouchers'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['vouchers'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user vouchers: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> purchaseVoucher(
    String userId,
    String voucherId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/voucher/$userId/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'voucher_id': voucherId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error purchasing voucher: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> redeemVoucher(
    String userId,
    String userVoucherId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/voucher/$userId/redeem/$userVoucherId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error redeeming voucher: $e');
      return null;
    }
  }

  // Get streak summary
  Future<Map<String, dynamic>?> getStreakSummary(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/streak/$userId/summary'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching streak summary: $e');
      return null;
    }
  }

  // Validate streaks (check for broken streaks)
  Future<Map<String, dynamic>?> validateStreaks(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/streak/$userId/validate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error validating streaks: $e');
      return null;
    }
  }

  // Deduct points from wallet
  Future<Map<String, dynamic>?> deductWalletPoints(
    String userId,
    int amount,
    String reason,
    String category,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/$userId/deduct-points'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'reason': reason,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error deducting points: $e');
      return null;
    }
  }

  // Notification APIs
  Future<Map<String, dynamic>?> sendNotification({
    required String userId,
    String? phoneNumber,
    String? fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    bool sendFCM = true,
    bool sendWhatsApp = true,
    bool sendLocal = true,
  }) async {
    try {
      debugPrint('📨 Sending notification:');
      debugPrint('  userId: $userId');
      debugPrint('  phoneNumber: $phoneNumber');
      debugPrint('  title: $title');
      debugPrint('  body: $body');
      debugPrint('  sendWhatsApp: $sendWhatsApp');

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'phoneNumber': phoneNumber,
          'fcmToken': fcmToken,
          'title': title,
          'body': body,
          'data': data ?? {},
          'sendFCM': sendFCM,
          'sendWhatsApp': sendWhatsApp,
          'sendLocal': sendLocal,
        }),
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Notification sent successfully');
        return jsonDecode(response.body);
      }
      debugPrint('❌ Notification failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendStreakReminder({
    required String userId,
    required String tracker,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/streak-reminder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'tracker': tracker}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error sending streak reminder: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendPeriodReminder({
    required String userId,
    required int daysUntil,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/period-reminder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'daysUntil': daysUntil}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error sending period reminder: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendHealthTip({
    required String userId,
    required String tip,
    String category = 'wellness',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/health-tip'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'tip': tip, 'category': category}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error sending health tip: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getNotificationStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/status'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting notification status: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendMotivationMessage({
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/motivation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error sending motivation message: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendDailyCheckInReminder({
    required String userId,
    required String tracker,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/daily-checkin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'tracker': tracker}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error sending daily check-in reminder: $e');
      return null;
    }
  }

  // Phone Number Management for WhatsApp Notifications
  Future<bool> updatePhoneNumber(String userId, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/$userId/phone-number'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating phone number: $e');
      return false;
    }
  }

  Future<String?> getPhoneNumber(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/phone-number'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['phone_number'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching phone number: $e');
      return null;
    }
  }

  // Generate personalized notification using Gemini AI
  Future<Map<String, dynamic>?> generatePersonalizedNotification({
    required String userId,
    required String tracker,
    required int cycleDay,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/generate-personalized'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'tracker': tracker,
          'cycleDay': cycleDay,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error generating personalized notification: $e');
      return null;
    }
  }

  // Generate cute period reminder using Gemini AI
  Future<Map<String, dynamic>?> generatePeriodReminder({
    required String userId,
    required int daysUntil,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/period-reminder-ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'daysUntil': daysUntil}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error generating period reminder: $e');
      return null;
    }
  }

  // Delete Account
  Future<bool> deleteUserAccount(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/$userId/account'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting user account: $e');
      return false;
    }
  }
}
