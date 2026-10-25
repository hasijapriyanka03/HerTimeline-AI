import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OllamaService {
  static const String _baseUrl = 'http://localhost:11434/api';
  static const String _model = 'mistral'; // or 'neural-chat', 'orca-mini'

  /// Generate sarcastic insight based on log data
  Future<String> generateSarcasmInsight({
    required String logType, // 'pain', 'mood', 'energy', etc.
    required double value, // 1-10 scale
    required String context, // 'period', 'work', 'stress', etc.
    required String language = 'en',
  }) async {
    try {
      final prompt = _buildSarcasmPrompt(logType, value, context, language);
      return await _callOllama(prompt);
    } catch (e) {
      debugPrint('Error generating sarcasm insight: $e');
      return _getFallbackInsight(logType, value, context);
    }
  }

  /// Generate personalized health insight
  Future<String> generateHealthInsight({
    required Map<String, dynamic> logData,
    required String lifeStage,
    required String language = 'en',
  }) async {
    try {
      final prompt = _buildHealthPrompt(logData, lifeStage, language);
      return await _callOllama(prompt);
    } catch (e) {
      debugPrint('Error generating health insight: $e');
      return 'Keep tracking! Patterns emerge over time.';
    }
  }

  /// Detect patterns in user data
  Future<Map<String, dynamic>> detectPatterns({
    required List<Map<String, dynamic>> logs,
    required String language = 'en',
  }) async {
    try {
      final prompt = _buildPatternPrompt(logs, language);
      final response = await _callOllama(prompt);

      // Parse response into structured data
      return _parsePatternResponse(response);
    } catch (e) {
      debugPrint('Error detecting patterns: $e');
      return {};
    }
  }

  /// Generate burnout warning
  Future<String> generateBurnoutWarning({
    required double stressLevel,
    required double sleepQuality,
    required double painLevel,
    required double moodScore,
    required String language = 'en',
  }) async {
    try {
      final prompt = _buildBurnoutPrompt(
        stressLevel,
        sleepQuality,
        painLevel,
        moodScore,
        language,
      );
      return await _callOllama(prompt);
    } catch (e) {
      debugPrint('Error generating burnout warning: $e');
      return 'Your system needs attention. Consider reaching out for support.';
    }
  }

  /// Generate condition-specific advice
  Future<String> generateConditionAdvice({
    required String condition, // 'pcos', 'endo', 'peri'
    required Map<String, dynamic> symptoms,
    required String language = 'en',
  }) async {
    try {
      final prompt = _buildConditionPrompt(condition, symptoms, language);
      return await _callOllama(prompt);
    } catch (e) {
      debugPrint('Error generating condition advice: $e');
      return 'Track your symptoms and share with your healthcare provider.';
    }
  }

  /// Generate day editor suggestions
  Future<Map<String, dynamic>> generateDayEditorSuggestions({
    required double painLevel,
    required double energyLevel,
    required double stressLevel,
    required List<String> plannedTasks,
    required String language = 'en',
  }) async {
    try {
      final prompt = _buildDayEditorPrompt(
        painLevel,
        energyLevel,
        stressLevel,
        plannedTasks,
        language,
      );
      final response = await _callOllama(prompt);

      return _parseDayEditorResponse(response);
    } catch (e) {
      debugPrint('Error generating day editor suggestions: $e');
      return {
        'mode': 'normal',
        'suggestions': ['Take breaks', 'Stay hydrated'],
      };
    }
  }

  /// Main Ollama API call
  Future<String> _callOllama(String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _model,
              'prompt': prompt,
              'stream': false,
              'temperature': 0.7,
              'top_p': 0.9,
              'top_k': 40,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response generated';
      } else {
        throw Exception('Ollama API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ollama API call failed: $e');
      rethrow;
    }
  }

  // ============ PROMPT BUILDERS ============

  String _buildSarcasmPrompt(
    String logType,
    double value,
    String context,
    String language,
  ) {
    final lang = language == 'hi' ? 'Hindi' : 'English';

    return '''You are a supportive, sarcastic health companion for women. Generate a SHORT (1-2 sentences), witty, and encouraging response to this health log.

Log Type: $logType
Value: $value/10
Context: $context
Language: $lang

Rules:
- Be sarcastic but never mean or judgmental
- Make her feel seen and understood
- Keep it SHORT and punchy
- Use emojis sparingly
- If $language == 'hi', respond in Hindi

Examples:
- "Ah yes, the classic 'stress + period = chaos' combo. Solid strategy."
- "Caffeine + period = science experiment vibes."
- "Your body said 'SHIP IT' today. Time to deep work, babe."

Generate response:''';
  }

  String _buildHealthPrompt(
    Map<String, dynamic> logData,
    String lifeStage,
    String language,
  ) {
    final lang = language == 'hi' ? 'Hindi' : 'English';

    return '''You are a health insights AI for women. Generate a SHORT, personalized health insight based on this log.

Log Data: ${jsonEncode(logData)}
Life Stage: $lifeStage
Language: $lang

Rules:
- Be encouraging and supportive
- Provide actionable insight
- Keep it SHORT (2-3 sentences max)
- Use simple language
- If $language == 'hi', respond in Hindi

Generate insight:''';
  }

  String _buildPatternPrompt(List<Map<String, dynamic>> logs, String language) {
    final lang = language == 'hi' ? 'Hindi' : 'English';

    return '''Analyze these health logs and identify patterns. Return JSON with patterns found.

Logs: ${jsonEncode(logs.take(30).toList())}
Language: $lang

Return JSON format:
{
  "patterns": [
    {"type": "pain_trigger", "trigger": "stress", "frequency": "80%"},
    {"type": "mood_pattern", "pattern": "low_on_tuesdays", "confidence": "75%"}
  ],
  "insights": ["insight 1", "insight 2"]
}

Analyze and return JSON:''';
  }

  String _buildBurnoutPrompt(
    double stressLevel,
    double sleepQuality,
    double painLevel,
    double moodScore,
    String language,
  ) {
    final lang = language == 'hi' ? 'Hindi' : 'English';

    return '''You are a burnout detection AI. Generate a warning if burnout is detected.

Stress Level: $stressLevel/10
Sleep Quality: $sleepQuality/10
Pain Level: $painLevel/10
Mood Score: $moodScore/10
Language: $lang

Rules:
- If stress > 7 AND sleep < 4 AND mood < 4: URGENT burnout warning
- Be compassionate but direct
- Suggest real actions (not just self-care)
- If $language == 'hi', respond in Hindi

Generate warning or reassurance:''';
  }

  String _buildConditionPrompt(
    String condition,
    Map<String, dynamic> symptoms,
    String language,
  ) {
    final lang = language == 'hi' ? 'Hindi' : 'English';

    return '''You are a health advisor for women with $condition. Generate advice based on symptoms.

Condition: $condition
Symptoms: ${jsonEncode(symptoms)}
Language: $lang

Rules:
- Provide practical, evidence-based advice
- Suggest lifestyle modifications
- Recommend when to see a doctor
- Keep it SHORT (3-4 sentences)
- If $language == 'hi', respond in Hindi

Generate advice:''';
  }

  String _buildDayEditorPrompt(
    double painLevel,
    double energyLevel,
    double stressLevel,
    List<String> plannedTasks,
    String language,
  ) {
    final lang = language == 'hi' ? 'Hindi' : 'English';

    return '''You are a day editor AI. Suggest how to adjust the day based on health metrics.

Pain Level: $painLevel/10
Energy Level: $energyLevel/10
Stress Level: $stressLevel/10
Planned Tasks: ${plannedTasks.join(', ')}
Language: $lang

Return JSON format:
{
  "mode": "focus|comfort|recovery",
  "suggestions": ["suggestion 1", "suggestion 2"],
  "task_adjustments": {"task": "new_timing_or_intensity"},
  "breaks_recommended": 3
}

Analyze and return JSON:''';
  }

  // ============ RESPONSE PARSERS ============

  Map<String, dynamic> _parsePatternResponse(String response) {
    try {
      // Extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
    } catch (e) {
      debugPrint('Error parsing pattern response: $e');
    }
    return {};
  }

  Map<String, dynamic> _parseDayEditorResponse(String response) {
    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
    } catch (e) {
      debugPrint('Error parsing day editor response: $e');
    }
    return {
      'mode': 'normal',
      'suggestions': ['Take breaks', 'Stay hydrated'],
    };
  }

  // ============ FALLBACK RESPONSES ============

  String _getFallbackInsight(String logType, double value, String context) {
    final insights = {
      'pain': [
        'Your body is sending signals. Listen to them.',
        'Pain is temporary. You\'ve got this.',
        'Rest is productive too.',
      ],
      'mood': [
        'Your feelings are valid.',
        'Emotions are data, not destiny.',
        'Be gentle with yourself today.',
      ],
      'energy': [
        'Rest when you need to.',
        'Energy fluctuates. That\'s normal.',
        'Listen to what your body needs.',
      ],
      'stress': [
        'Stress is real. So is your strength.',
        'One thing at a time.',
        'You\'re doing better than you think.',
      ],
    };

    final typeInsights = insights[logType] ?? insights['mood']!;
    return typeInsights[value.toInt() % typeInsights.length];
  }
}
