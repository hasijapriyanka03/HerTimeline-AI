const express = require('express');
const audioEmotionService = require('../services/audioEmotionService');

const router = express.Router();

/**
 * POST /api/audio-emotion/detect
 * Detect emotion from audio file
 * Body: { audio: base64_string, mimeType: 'audio/wav' }
 */
router.post('/detect', async (req, res) => {
  try {
    const { audio, mimeType = 'audio/wav' } = req.body;

    if (!audio) {
      return res.status(400).json({
        success: false,
        error: 'Audio data is required',
      });
    }

    const audioBuffer = Buffer.from(audio, 'base64');
    const result = await audioEmotionService.detectEmotionFromAudio(
      audioBuffer,
      mimeType,
    );

    res.json(result);
  } catch (error) {
    console.error('Error in audio emotion detection:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/audio-emotion/analyze
 * Comprehensive audio analysis with transcription
 * Body: { audio: base64_string, transcription: string, mimeType: 'audio/wav' }
 */
router.post('/analyze', async (req, res) => {
  try {
    const { audio, transcription, mimeType = 'audio/wav' } = req.body;

    if (!audio || !transcription) {
      return res.status(400).json({
        success: false,
        error: 'Audio data and transcription are required',
      });
    }

    const audioBuffer = Buffer.from(audio, 'base64');
    const result = await audioEmotionService.analyzeAudio(
      audioBuffer,
      transcription,
      mimeType,
    );

    res.json(result);
  } catch (error) {
    console.error('Error in audio analysis:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/audio-emotion/status
 * Get audio emotion detection service status
 */
router.get('/status', (req, res) => {
  const status = audioEmotionService.getStatus();
  res.json(status);
});

/**
 * POST /api/audio-emotion/extract-symptoms
 * Extract symptoms from text and emotion
 * Body: { text: string, emotion: string }
 */
router.post('/extract-symptoms', (req, res) => {
  try {
    const { text, emotion } = req.body;

    if (!text || !emotion) {
      return res.status(400).json({
        success: false,
        error: 'Text and emotion are required',
      });
    }

    const symptoms = audioEmotionService.extractSymptoms(text, emotion);

    res.json({
      success: true,
      symptoms: symptoms,
      emotion: emotion,
    });
  } catch (error) {
    console.error('Error extracting symptoms:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

module.exports = router;
