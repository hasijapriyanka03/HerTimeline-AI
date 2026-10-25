const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Simple test server to send notifications
const app = express();
app.use(cors());
app.use(express.json());

// Initialize database
const db = require('./src/services/database');
const fcmService = require('./src/services/fcmService');

// Test endpoint to send notification to all users
app.post('/test-send-all', async (req, res) => {
  try {
    console.log('🧪 Testing notification to all users...');
    
    // Get all FCM tokens from database
    const allTokens = db.get('fcmTokens').value();
    console.log(`📱 Found ${allTokens.length} registered tokens`);
    
    if (allTokens.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No FCM tokens registered. Add a token first using /add-test-token'
      });
    }
    
    // Get tokens
    const tokens = allTokens.map(t => t.token);
    
    const result = await fcmService.sendToMultipleDevices(
      tokens,
      {
        title: '🌸 Server Test Notification',
        body: 'This notification was sent from the Node.js server! Background notifications are working! 🎉',
      },
      {
        type: 'server_test',
        timestamp: new Date().toISOString(),
        source: 'node_server',
      }
    );
    
    console.log('📤 Notification send result:', result);
    
    res.json({
      success: true,
      message: 'Test notification sent!',
      totalTokens: tokens.length,
      result: result,
    });
  } catch (error) {
    console.error('❌ Error sending test notification:', error);
    res.status(500).json({ error: error.message });
  }
});

// Add test token endpoint
app.post('/add-test-token', (req, res) => {
  try {
    const { token } = req.body;
    
    if (!token) {
      return res.status(400).json({ error: 'Token is required' });
    }
    
    // Check if token already exists
    const existing = db.get('fcmTokens').find({ token }).value();
    if (existing) {
      return res.json({
        success: true,
        message: 'Token already exists',
      });
    }
    
    // Add token to database
    db.get('fcmTokens')
      .push({
        user_id: 'test_user_' + Date.now(),
        token: token,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .write();
    
    console.log('✅ Test token added:', token.substring(0, 20) + '...');
    
    res.json({
      success: true,
      message: 'Token added successfully',
    });
  } catch (error) {
    console.error('❌ Error adding token:', error);
    res.status(500).json({ error: error.message });
  }
});

// List all tokens
app.get('/tokens', (req, res) => {
  try {
    const tokens = db.get('fcmTokens').value();
    res.json({
      success: true,
      count: tokens.length,
      tokens: tokens.map(t => ({
        user_id: t.user_id,
        token: t.token.substring(0, 20) + '...',
        created_at: t.created_at,
      })),
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Notification test server is running',
    timestamp: new Date().toISOString(),
  });
});

const PORT = 3001; // Use 3001 to avoid conflict with main server
app.listen(PORT, () => {
  console.log('🚀 Notification test server running on port', PORT);
  console.log('📍 Test endpoints:');
  console.log(`   POST http://localhost:${PORT}/test-send-all - Send test notification to all`);
  console.log(`   POST http://localhost:${PORT}/add-test-token - Add FCM token`);
  console.log(`   GET  http://localhost:${PORT}/tokens - List all tokens`);
  console.log(`   GET  http://localhost:${PORT}/health - Health check`);
  console.log('');
  console.log('💡 To test:');
  console.log('   1. Copy your FCM token from the app logs');
  console.log('   2. POST to /add-test-token with {"token": "your-token"}');
  console.log('   3. POST to /test-send-all to send notification');
});
