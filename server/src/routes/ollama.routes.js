const express = require('express');
const router = express.Router();
const ollamaService = require('../services/ollamaService');
const geminiService = require('../services/geminiService');

// Check Ollama status
router.get('/status', (req, res) => {
  const status = ollamaService.getStatus();
  res.json(status);
});

// Generate response using Ollama (with Gemini fallback)
router.post('/generate', async (req, res) => {
  try {
    const { userId, message, context = {}, useGemini = false } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    let response;
    let source = 'unknown';

    // Try Ollama first if available and not explicitly requesting Gemini
    if (ollamaService.isServiceAvailable() && !useGemini) {
      try {
        response = await ollamaService.generateResponse(message, context);
        source = 'ollama';
        console.log(`✅ Response generated using Ollama (${ollamaService.model})`);
      } catch (error) {
        console.warn('⚠️ Ollama failed, falling back to Gemini:', error.message);
        // Fall through to Gemini
      }
    }

    // Use Gemini if Ollama failed or is not available
    if (!response) {
      if (geminiService.ai) {
        response = await geminiService.generateResponse(message, context);
        source = 'gemini';
        console.log('✅ Response generated using Gemini');
      } else {
        return res.status(503).json({
          error: 'No AI service available',
          message: 'Both Ollama and Gemini are unavailable',
        });
      }
    }

    res.json({
      response,
      source,
      model: source === 'ollama' ? ollamaService.model : 'gemini-2.5-flash',
    });
  } catch (error) {
    console.error('Error generating response:', error);
    res.status(500).json({
      error: 'Failed to generate response',
      message: error.message,
    });
  }
});

// Chat endpoint for menstruation tracker
router.post('/chat/menstruation', async (req, res) => {
  try {
    const { userId, message, history = [], userProfile = null } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    let response;
    let source = 'unknown';

    // Try Ollama first
    if (ollamaService.isServiceAvailable()) {
      try {
        response = await ollamaService.chatMenstruation(
          userId,
          message,
          history,
          userProfile
        );
        source = 'ollama';
      } catch (error) {
        console.warn('⚠️ Ollama failed, falling back to Gemini');
      }
    }

    // Use Gemini if Ollama failed
    if (!response && geminiService.ai) {
      response = await geminiService.chatMenstruation(
        userId,
        message,
        history,
        userProfile
      );
      source = 'gemini';
    }

    if (!response) {
      return res.status(503).json({
        error: 'No AI service available',
      });
    }

    res.json({ response, source });
  } catch (error) {
    console.error('Error in menstruation chat:', error);
    res.status(500).json({
      error: 'Failed to process chat',
      message: error.message,
    });
  }
});

// Chat endpoint for pregnancy tracker
router.post('/chat/pregnancy', async (req, res) => {
  try {
    const { userId, message, week, history = [] } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    let response;
    let source = 'unknown';

    // Try Ollama first
    if (ollamaService.isServiceAvailable()) {
      try {
        response = await ollamaService.chatPregnancy(
          userId,
          message,
          week,
          history
        );
        source = 'ollama';
      } catch (error) {
        console.warn('⚠️ Ollama failed, falling back to Gemini');
      }
    }

    // Use Gemini if Ollama failed
    if (!response && geminiService.ai) {
      response = await geminiService.chatPregnancy(
        userId,
        message,
        week,
        history
      );
      source = 'gemini';
    }

    if (!response) {
      return res.status(503).json({
        error: 'No AI service available',
      });
    }

    res.json({ response, source });
  } catch (error) {
    console.error('Error in pregnancy chat:', error);
    res.status(500).json({
      error: 'Failed to process chat',
      message: error.message,
    });
  }
});

// Chat endpoint for menopause tracker
router.post('/chat/menopause', async (req, res) => {
  try {
    const { userId, message, history = [] } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    let response;
    let source = 'unknown';

    // Try Ollama first
    if (ollamaService.isServiceAvailable()) {
      try {
        response = await ollamaService.chatMenopause(userId, message, history);
        source = 'ollama';
      } catch (error) {
        console.warn('⚠️ Ollama failed, falling back to Gemini');
      }
    }

    // Use Gemini if Ollama failed
    if (!response && geminiService.ai) {
      response = await geminiService.chatMenopause(userId, message, history);
      source = 'gemini';
    }

    if (!response) {
      return res.status(503).json({
        error: 'No AI service available',
      });
    }

    res.json({ response, source });
  } catch (error) {
    console.error('Error in menopause chat:', error);
    res.status(500).json({
      error: 'Failed to process chat',
      message: error.message,
    });
  }
});

// Chat endpoint for education
router.post('/chat/education', async (req, res) => {
  try {
    const { userId, message, context = {} } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    let response;
    let source = 'unknown';

    // Try Ollama first
    if (ollamaService.isServiceAvailable()) {
      try {
        response = await ollamaService.chatEducation(userId, message, context);
        source = 'ollama';
      } catch (error) {
        console.warn('⚠️ Ollama failed, falling back to Gemini');
      }
    }

    // Use Gemini if Ollama failed
    if (!response && geminiService.ai) {
      response = await geminiService.chatEducation(userId, message, context);
      source = 'gemini';
    }

    if (!response) {
      return res.status(503).json({
        error: 'No AI service available',
      });
    }

    res.json({ response, source });
  } catch (error) {
    console.error('Error in education chat:', error);
    res.status(500).json({
      error: 'Failed to process chat',
      message: error.message,
    });
  }
});

module.exports = router;
