const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

class AudioEmotionService {
  constructor() {
    // Hugging Face API endpoint for audio emotion detection
    this.huggingFaceApiUrl =
      'https://api-inference.huggingface.co/models/Hatman/audio-emotion-detection';
    this.huggingFaceApiKey = process.env.HUGGING_FACE_API_KEY;

    if (!this.huggingFaceApiKey) {
      console.warn(
        '⚠️ HUGGING_FACE_API_KEY not set. Audio emotion detection will be disabled.',
      );
    }
  }

  /**
   * Detect emotion from audio file using Hugging Face API
   * @param {Buffer} audioBuffer - Audio file buffer
   * @param {string} mimeType - MIME type of audio (e.g., 'audio/wav', 'audio/mp3')
   * @returns {Promise<Object>} Emotion detection results
   */
  async detectEmotionFromAudio(audioBuffer, mimeType = 'audio/wav') {
    try {
      if (!this.huggingFaceApiKey) {
        console.warn('⚠️ Audio emotion detection API key not configured');
        return this._getFallbackEmotion();
      }

      console.log('🎤 Sending audio to Hugging Face for emotion detection...');
      console.log(`📊 Audio buffer size: ${audioBuffer.length} bytes`);

      const response = await axios.post(
        this.huggingFaceApiUrl,
        audioBuffer,
        {
          headers: {
            Authorization: `Bearer ${this.huggingFaceApiKey}`,
            'Content-Type': mimeType,
          },
          timeout: 60000,
        },
      );

      console.log('✅ Hugging Face response received:', response.data);
      return this._parseEmotionResponse(response.data);
    } catch (error) {
      console.error('❌ Error detecting emotion from audio:', error.message);
      if (error.response) {
        console.error('Response status:', error.response.status);
        console.error('Response data:', error.response.data);
      }
      return this._getFallbackEmotion();
    }
  }

  /**
   * Detect emotion from base64 encoded audio
   * @param {string} base64Audio - Base64 encoded audio data
   * @param {string} mimeType - MIME type of audio
   * @returns {Promise<Object>} Emotion detection results
   */
  async detectEmotionFromBase64(base64Audio, mimeType = 'audio/wav') {
    try {
      const audioBuffer = Buffer.from(base64Audio, 'base64');
      return await this.detectEmotionFromAudio(audioBuffer, mimeType);
    } catch (error) {
      console.error('Error processing base64 audio:', error.message);
      return this._getFallbackEmotion();
    }
  }

  /**
   * Parse emotion detection response from Hugging Face API
   * @param {Array} responseData - API response data
   * @returns {Object} Parsed emotion data
   */
  _parseEmotionResponse(responseData) {
    try {
      console.log('📊 Parsing emotion response:', JSON.stringify(responseData));

      if (!Array.isArray(responseData) || responseData.length === 0) {
        console.warn('⚠️ Empty response from Hugging Face');
        return this._getFallbackEmotion();
      }

      // Response format from Hugging Face: [{ label: 'emotion', score: 0.95 }, ...]
      const emotions = responseData.map((item) => ({
        emotion: item.label || 'unknown',
        confidence: parseFloat(item.score) || 0,
      }));

      // Sort by confidence (highest first)
      emotions.sort((a, b) => b.confidence - a.confidence);

      // Get top emotion
      const topEmotion = emotions[0];

      console.log('🎯 Top emotion detected:', topEmotion);

      // Map Hugging Face emotions to our mood categories
      const moodMapping = {
        happy: 'Happy',
        sad: 'Sad',
        angry: 'Stressed',
        fear: 'Anxious',
        surprise: 'Energetic',
        neutral: 'Calm',
        disgust: 'Stressed',
        calm: 'Calm',
        joy: 'Happy',
        sorrow: 'Sad',
        anger: 'Stressed',
        fear: 'Anxious',
      };

      const emotionKey = topEmotion.emotion.toLowerCase();
      const mappedMood = moodMapping[emotionKey] || 'Calm';

      console.log(`✅ Mapped emotion "${topEmotion.emotion}" to mood "${mappedMood}"`);

      return {
        success: true,
        emotion: topEmotion.emotion,
        mood: mappedMood,
        confidence: topEmotion.confidence,
        allEmotions: emotions,
        source: 'audio_emotion_detection',
      };
    } catch (error) {
      console.error('❌ Error parsing emotion response:', error.message);
      return this._getFallbackEmotion();
    }
  }

  /**
   * Get fallback emotion when API fails
   * @returns {Object} Default emotion object
   */
  _getFallbackEmotion() {
    return {
      success: false,
      emotion: 'neutral',
      mood: 'Calm',
      confidence: 0,
      allEmotions: [],
      source: 'fallback',
      message: 'Using fallback emotion detection',
    };
  }

  /**
   * Extract symptoms based on emotion and text analysis
   * @param {string} transcribedText - Transcribed text from audio
   * @param {string} emotion - Detected emotion
   * @returns {Array<string>} List of detected symptoms
   */
  extractSymptoms(transcribedText, emotion) {
    const symptoms = [];
    const textLower = transcribedText.toLowerCase();

    // Symptom keywords mapping
    const symptomKeywords = {
      'Cramps': [
        'cramp',
        'cramping',
        'pain',
        'ache',
        'stomach',
        'belly',
        'abdomen',
      ],
      'Bloating': ['bloat', 'bloated', 'swollen', 'puffed', 'gas', 'full'],
      'Headache': ['headache', 'head', 'migraine', 'dizzy', 'dizziness'],
      'Fatigue': [
        'tired',
        'fatigue',
        'exhausted',
        'sleepy',
        'energy',
        'weak',
        'lethargic',
      ],
      'Nausea': ['nausea', 'nauseous', 'sick', 'vomit', 'queasy'],
      'Mood Swings': ['mood', 'emotional', 'irritable', 'grumpy', 'angry'],
      'Anxiety': ['anxious', 'nervous', 'worried', 'stressed', 'panic'],
      'Insomnia': ['sleep', 'insomnia', 'awake', 'restless', 'night'],
    };

    // Check for symptom keywords in text
    for (const [symptom, keywords] of Object.entries(symptomKeywords)) {
      if (keywords.some((keyword) => textLower.includes(keyword))) {
        symptoms.push(symptom);
      }
    }

    // Add emotion-based symptoms
    const emotionSymptoms = {
      angry: ['Mood Swings', 'Anxiety'],
      sad: ['Fatigue', 'Insomnia'],
      fear: ['Anxiety', 'Nausea'],
      surprise: [],
      neutral: [],
      happy: [],
    };

    const emotionKey = emotion.toLowerCase();
    if (emotionSymptoms[emotionKey]) {
      emotionSymptoms[emotionKey].forEach((symptom) => {
        if (!symptoms.includes(symptom)) {
          symptoms.push(symptom);
        }
      });
    }

    return symptoms.length > 0 ? symptoms : ['None'];
  }

  /**
   * Comprehensive audio analysis combining emotion detection and text analysis
   * @param {Buffer} audioBuffer - Audio file buffer
   * @param {string} transcribedText - Transcribed text from audio
   * @param {string} mimeType - MIME type of audio
   * @returns {Promise<Object>} Combined analysis results
   */
  async analyzeAudio(audioBuffer, transcribedText, mimeType = 'audio/wav') {
    try {
      // Detect emotion from audio
      const emotionResult = await this.detectEmotionFromAudio(
        audioBuffer,
        mimeType,
      );

      // Extract symptoms from text and emotion
      const symptoms = this.extractSymptoms(
        transcribedText,
        emotionResult.emotion,
      );

      return {
        success: true,
        mood: emotionResult.mood,
        emotion: emotionResult.emotion,
        confidence: emotionResult.confidence,
        symptoms: symptoms,
        transcription: transcribedText,
        source: emotionResult.source,
        allEmotions: emotionResult.allEmotions,
      };
    } catch (error) {
      console.error('Error analyzing audio:', error.message);
      return {
        success: false,
        mood: 'Calm',
        emotion: 'neutral',
        confidence: 0,
        symptoms: ['None'],
        transcription: transcribedText,
        source: 'fallback',
        error: error.message,
      };
    }
  }

  /**
   * Check if audio emotion detection is available
   * @returns {boolean} True if API key is configured
   */
  isAvailable() {
    return !!this.huggingFaceApiKey;
  }

  /**
   * Get service status
   * @returns {Object} Service status information
   */
  getStatus() {
    return {
      service: 'audio_emotion_detection',
      available: this.isAvailable(),
      model: 'Hatman/audio-emotion-detection',
      provider: 'Hugging Face',
      configured: !!this.huggingFaceApiKey,
    };
  }
}

module.exports = new AudioEmotionService();
