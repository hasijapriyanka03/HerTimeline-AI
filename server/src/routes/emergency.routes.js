const express = require('express');
const router = express.Router();
const emailService = require('../services/emailService');

// Send emergency alert
router.post('/alert', async (req, res) => {
  try {
    const { userId, userProfile, emergencyContact } = req.body;

    if (!userProfile || !emergencyContact || !emergencyContact.email) {
      return res.status(400).json({ 
        error: 'Missing required fields',
        message: 'User profile and emergency contact email are required'
      });
    }

    console.log(`🚨 Emergency alert triggered for user: ${userId}`);
    
    const result = await emailService.sendEmergencyAlert(userProfile, emergencyContact);

    if (result.success) {
      res.json({ 
        success: true, 
        message: 'Emergency alert sent successfully',
        messageId: result.messageId
      });
    } else {
      res.status(500).json({ 
        success: false, 
        error: result.error,
        message: 'Failed to send emergency alert'
      });
    }
  } catch (error) {
    console.error('Error in emergency alert route:', error);
    res.status(500).json({ 
      error: error.message,
      message: 'Internal server error while sending emergency alert'
    });
  }
});

// Test email service
router.get('/test', async (req, res) => {
  try {
    const isReady = await emailService.testConnection();
    res.json({ 
      success: isReady,
      message: isReady ? 'Email service is ready' : 'Email service is not configured'
    });
  } catch (error) {
    res.status(500).json({ 
      error: error.message,
      message: 'Error testing email service'
    });
  }
});

module.exports = router;
