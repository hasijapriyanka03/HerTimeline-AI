import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class AgoraAIService {
  final String geminiApiKey;
  late GenerativeModel _geminiModel;

  AgoraAIService({required this.geminiApiKey}) {
    _initGemini();
  }

  void _initGemini() {
    _geminiModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 300,
      ),
    );
  }

  /// Get conversational response from Gemini
  Future<String> getEducationResponse(
    String userMessage, {
    Map<String, dynamic>? context,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(context);
      final prompt = '$systemPrompt\n\nUser: $userMessage';

      final content = [Content.text(prompt)];
      final response = await _geminiModel.generateContent(content);

      return response.text ?? 'Sorry, I could not process that.';
    } catch (e) {
      debugPrint('Error getting Gemini response: $e');
      rethrow;
    }
  }

  /// Build system prompt with context
  String _buildSystemPrompt(Map<String, dynamic>? context) {
    if (context == null) {
      return _defaultSystemPrompt();
    }

    final role = context['role'] ?? 'educator';
    final tone = context['tone'] ?? 'friendly and educational';
    final instructions = context['instructions'] ?? '';

    return '''You are a $role speaking in a $tone manner.

$instructions

Respond conversationally and helpfully.''';
  }

  String _defaultSystemPrompt() {
    return '''You are a friendly health educator specializing in periods, menopause, and pregnancy.

RULES:
1. Use simple, everyday words - avoid complex medical terms
2. Be friendly and encouraging
3. NEVER give medical advice or diagnose conditions
4. Always suggest visiting a doctor for health concerns
5. Stay on-topic: only discuss periods, menopause, and pregnancy
6. If asked about other topics, politely redirect
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
- Topics unrelated to periods, menopause, pregnancy''';
  }

  /// Generate text-to-speech using Cartesia API
  Future<List<int>> generateTTS(
    String text, {
    required String cartesiaApiKey,
    String voice = 'Arushi',
    double speed = 0.5,
  }) async {
    try {
      final url = Uri.parse('https://api.cartesia.ai/tts/stream');
      final request = http.Request('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $cartesiaApiKey',
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({
          'model': 'sonic-2',
          'input_text': text,
          'voice': voice,
        });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('TTS failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating TTS: $e');
      rethrow;
    }
  }

  /// Stream response for real-time conversation
  Stream<String> streamEducationResponse(
    String userMessage, {
    Map<String, dynamic>? context,
  }) async* {
    try {
      final systemPrompt = _buildSystemPrompt(context);
      final prompt = '$systemPrompt\n\nUser: $userMessage';

      final content = [Content.text(prompt)];
      final stream = _geminiModel.generateContentStream(content);

      await for (final response in stream) {
        if (response.text != null) {
          yield response.text!;
        }
      }
    } catch (e) {
      debugPrint('Error streaming response: $e');
      yield 'Sorry, I encountered an error. Please try again.';
    }
  }
}
