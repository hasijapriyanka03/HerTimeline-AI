const express = require('express');
const router = express.Router();
const db = require('../services/database');

// Save or update user profile
router.post('/:userId/profile', (req, res) => {
  try {
    const { userId } = req.params;
    const profile = {
      ...req.body,
      user_id: userId,
      updated_at: new Date().toISOString(),
    };

    // Check if profile exists
    const existing = db.get('userProfiles')
      .find({ user_id: userId })
      .value();

    if (existing) {
      // Update existing profile
      db.get('userProfiles')
        .find({ user_id: userId })
        .assign(profile)
        .write();
    } else {
      // Create new profile
      profile.created_at = new Date().toISOString();
      db.get('userProfiles')
        .push(profile)
        .write();
    }

    // Also update or create user record with phone number
    if (req.body.phone_number) {
      const existingUser = db.get('users')
        .find({ user_id: userId })
        .value();

      const userData = {
        user_id: userId,
        name: req.body.name || 'User',
        phone_number: req.body.phone_number,
        fcm_token: req.body.fcm_token,
        updated_at: new Date().toISOString(),
      };

      if (existingUser) {
        db.get('users')
          .find({ user_id: userId })
          .assign(userData)
          .write();
      } else {
        userData.created_at = new Date().toISOString();
        db.get('users')
          .push(userData)
          .write();
      }
    }

    res.status(200).json(profile);
  } catch (error) {
    console.error('Error saving user profile:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get user profile
router.get('/:userId/profile', (req, res) => {
  try {
    const profile = db.get('userProfiles')
      .find({ user_id: req.params.userId })
      .value();

    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    res.json(profile);
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * POST /:userId/phone-number
 * Update user's phone number for WhatsApp notifications
 * Body: {
 *   phone_number: string (e.g., "+1234567890")
 * }
 */
router.post('/:userId/phone-number', (req, res) => {
  try {
    const { userId } = req.params;
    const { phone_number } = req.body;

    if (!phone_number) {
      return res.status(400).json({ error: 'phone_number is required' });
    }

    // Validate phone number format (basic validation)
    if (!/^\+\d{1,15}$/.test(phone_number)) {
      return res.status(400).json({
        error: 'Invalid phone number format. Use format: +1234567890',
      });
    }

    // Update or create user record
    const existingUser = db.get('users')
      .find({ user_id: userId })
      .value();

    const userData = {
      user_id: userId,
      phone_number,
      updated_at: new Date().toISOString(),
    };

    if (existingUser) {
      db.get('users')
        .find({ user_id: userId })
        .assign(userData)
        .write();
    } else {
      userData.created_at = new Date().toISOString();
      db.get('users')
        .push(userData)
        .write();
    }

    // Also update userProfile if it exists
    const profile = db.get('userProfiles')
      .find({ user_id: userId })
      .value();

    if (profile) {
      db.get('userProfiles')
        .find({ user_id: userId })
        .assign({ phone_number, updated_at: new Date().toISOString() })
        .write();
    }

    res.status(200).json({
      success: true,
      message: 'Phone number updated successfully',
      user_id: userId,
      phone_number,
    });
  } catch (error) {
    console.error('Error updating phone number:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * GET /:userId/phone-number
 * Get user's phone number
 */
router.get('/:userId/phone-number', (req, res) => {
  try {
    const user = db.get('users')
      .find({ user_id: req.params.userId })
      .value();

    if (!user || !user.phone_number) {
      return res.status(404).json({
        error: 'Phone number not found for this user',
      });
    }

    res.json({
      user_id: req.params.userId,
      phone_number: user.phone_number,
    });
  } catch (error) {
    console.error('Error fetching phone number:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * DELETE /:userId/account
 * Permanently delete all user data from the server
 * This will delete:
 * - User profile
 * - All menstruation logs
 * - All pregnancy data
 * - All menopause logs
 * - All appointments
 * - Wallet data
 * - Streaks
 * - User vouchers
 * - FCM tokens
 * - User record
 */
router.delete('/:userId/account', (req, res) => {
  try {
    const { userId } = req.params;

    console.log(`🗑️ Deleting all data for user: ${userId}`);

    // Delete from all collections
    db.get('users')
      .remove({ user_id: userId })
      .write();

    db.get('userProfiles')
      .remove({ user_id: userId })
      .write();

    db.get('menstruationLogs')
      .remove({ user_id: userId })
      .write();

    db.get('cycleData')
      .remove({ user_id: userId })
      .write();

    db.get('pregnancyProfiles')
      .remove({ user_id: userId })
      .write();

    db.get('pregnancyLogs')
      .remove({ user_id: userId })
      .write();

    db.get('dailyLogs')
      .remove({ user_id: userId })
      .write();

    db.get('menopauseLogs')
      .remove({ user_id: userId })
      .write();

    db.get('fcmTokens')
      .remove({ user_id: userId })
      .write();

    db.get('appointments')
      .remove({ user_id: userId })
      .write();

    db.get('userWallets')
      .remove({ user_id: userId })
      .write();

    db.get('streaks')
      .remove({ user_id: userId })
      .write();

    db.get('userVouchers')
      .remove({ user_id: userId })
      .write();

    console.log(`✅ All data deleted for user: ${userId}`);

    res.status(200).json({
      success: true,
      message: 'All user data has been permanently deleted',
      user_id: userId,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error deleting user account:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

module.exports = router;
