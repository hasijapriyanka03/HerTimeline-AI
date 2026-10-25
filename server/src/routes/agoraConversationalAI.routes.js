const express = require('express');
const agoraService = require('../services/agoraConversationalAIService');
const agoraTokenService = require('../services/agoraTokenService');

const router = express.Router();

/**
 * POST /api/agora-ai/start-agent
 * Start a conversational AI agent in an Agora channel
 * Body: {
 *   channelName: string,
 *   agentName: string,
 *   systemMessages: object[] (optional)
 * }
 * Note: Token is generated server-side for the agent UID (999)
 */
router.post('/start-agent', async (req, res) => {
  try {
    const {
      channelName,
      agentName,
      mode = 'education',
      systemMessages = null,
    } = req.body;

    if (!channelName || !agentName) {
      return res.status(400).json({
        success: false,
        error: 'channelName and agentName are required',
      });
    }

    // Generate token for agent UID 999 with RTM2 privileges (required for Conversational AI)
    const agentUid = 999;
    const agentToken = agoraTokenService.generateAgentTokenWithRtm2(channelName, agentUid, 3600);
    
    console.log(`🔑 Generated agent token for UID ${agentUid}`);

    const result = await agoraService.startAgent(
      channelName,
      agentToken,
      agentName,
      ['*'], // Subscribe to all users
      systemMessages,
      mode,
    );

    res.json(result);
  } catch (error) {
    console.error('Error starting agent:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/agora-ai/stop-agent
 * Stop a conversational AI agent
 * Body: { agentId: string }
 */
router.post('/stop-agent', async (req, res) => {
  try {
    const { agentId } = req.body;

    if (!agentId) {
      return res.status(400).json({
        success: false,
        error: 'agentId is required',
      });
    }

    const result = await agoraService.stopAgent(agentId);
    res.json(result);
  } catch (error) {
    console.error('Error stopping agent:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/agora-ai/agent-status/:agentId
 * Query the status of a conversational AI agent
 */
router.get('/agent-status/:agentId', async (req, res) => {
  try {
    const { agentId } = req.params;

    if (!agentId) {
      return res.status(400).json({
        success: false,
        error: 'agentId is required',
      });
    }

    const result = await agoraService.queryAgentStatus(agentId);
    res.json(result);
  } catch (error) {
    console.error('Error querying agent status:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * PATCH /api/agora-ai/update-agent/:agentId
 * Update agent configuration
 * Body: { properties: object }
 */
router.patch('/update-agent/:agentId', async (req, res) => {
  try {
    const { agentId } = req.params;
    const { properties } = req.body;

    if (!agentId || !properties) {
      return res.status(400).json({
        success: false,
        error: 'agentId and properties are required',
      });
    }

    const result = await agoraService.updateAgent(agentId, properties);
    res.json(result);
  } catch (error) {
    console.error('Error updating agent:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/agora-ai/generate-token
 * Generate RTC token for Agora channel
 * Body: { channelName: string, uid: number, expirationTimeInSeconds?: number }
 */
router.post('/generate-token', (req, res) => {
  try {
    const { channelName, uid, expirationTimeInSeconds = 86400 } = req.body;

    if (!channelName || uid === undefined) {
      return res.status(400).json({
        success: false,
        error: 'channelName and uid are required',
      });
    }

    const token = agoraTokenService.generateToken(
      channelName,
      uid,
      expirationTimeInSeconds,
    );

    res.json({
      success: true,
      token: token,
      channelName: channelName,
      uid: uid,
      expiresIn: expirationTimeInSeconds,
    });
  } catch (error) {
    console.error('Error generating token:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/agora-ai/status
 * Get service status
 */
router.get('/status', (req, res) => {
  const status = agoraService.getStatus();
  res.json(status);
});

/**
 * GET /api/agora-ai/greeting
 * Generate a greeting message from the AI
 * Query params: mode (optional) - 'education' or 'ranting'
 */
router.get('/greeting', async (req, res) => {
  try {
    const { mode = 'education' } = req.query;
    const greeting = await agoraService.generateGreeting(mode);
    res.json({
      success: true,
      greeting: greeting,
    });
  } catch (error) {
    console.error('Error generating greeting:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      greeting:
        'Hello! I\'m your health educator. Feel free to ask me anything about periods, menopause, or pregnancy.',
    });
  }
});

module.exports = router;
