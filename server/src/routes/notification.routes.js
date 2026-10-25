const express = require('express');
const router = express.Router();
const fcmService = require('../services/fcmService');
const db = require('../services/database');

// Save FCM token for a user
router.post('/token', (req, res) => {
  try {
    const { userId, token } = req.body;

    if (!userId || !token) {
      return res.status(400).json({ error: 'Missing userId or token' });
    }

    // Check if token exists
    const existing = db.get('fcmTokens')
      .find({ user_id: userId })
      .value();

    if (existing) {
      db.get('fcmTokens')
        .find({ user_id: userId })
        .assign({ token, updated_at: new Date().toISOString() })
        .write();
    } else {
      db.get('fcmTokens')
        .push({
          user_id: userId,
          token,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .write();
    }

    res.json({ success: true, message: 'Token saved successfully' });
  } catch (error) {
    console.error('Error saving token:', error);
    res.status(500).json({ error: error.message });
  }
});

// Send notification to a single user
router.post('/send', async (req, res) => {
  try {
    const { userId, title, body, data } = req.body;

    if (!userId || !title || !body) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Get user's FCM token
    const tokenData = db.get('fcmTokens')
      .find({ user_id: userId })
      .value();

    if (!tokenData) {
      return res.status(404).json({ error: 'User token not found' });
    }

    const result = await fcmService.sendToDevice(
      tokenData.token,
      { title, body },
      data || {}
    );

    res.json(result);
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({ error: error.message });
  }
});

// Send notification to all users
router.post('/send-all', async (req, res) => {
  try {
    const { title, body, data } = req.body;

    if (!title || !body) {
      return res.status(400).json({ error: 'Missing title or body' });
    }

    // Get all FCM tokens
    const allTokens = db.get('fcmTokens').value();

    if (allTokens.length === 0) {
      return res.json({
        success: true,
        message: 'No users to send notifications to',
        successCount: 0,
        failureCount: 0,
      });
    }

    const tokens = allTokens.map(t => t.token);

    const result = await fcmService.sendToMultipleDevices(
      tokens,
      { title, body },
      data || {}
    );

    res.json(result);
  } catch (error) {
    console.error('Error sending notifications to all:', error);
    res.status(500).json({ error: error.message });
  }
});

// Send notification to a topic
router.post('/send-topic', async (req, res) => {
  try {
    const { topic, title, body, data } = req.body;

    if (!topic || !title || !body) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const result = await fcmService.sendToTopic(
      topic,
      { title, body },
      data || {}
    );

    res.json(result);
  } catch (error) {
    console.error('Error sending topic notification:', error);
    res.status(500).json({ error: error.message });
  }
});

// Test endpoint - send test notification to all users
router.post('/test-all', async (req, res) => {
  try {
    const allTokens = db.get('fcmTokens').value();

    if (allTokens.length === 0) {
      return res.json({
        success: true,
        message: 'No users registered. Add FCM tokens first.',
        successCount: 0,
      });
    }

    const tokens = allTokens.map(t => t.token);

    const result = await fcmService.sendToMultipleDevices(
      tokens,
      {
        title: '🧪 Test Notification',
        body: 'This is a test notification from the server! If you see this, background notifications are working! 🎉',
      },
      {
        type: 'test',
        timestamp: new Date().toISOString(),
      }
    );

    res.json({
      ...result,
      totalUsers: allTokens.length,
      message: 'Test notification sent to all registered users',
    });
  } catch (error) {
    console.error('Error sending test notification:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
