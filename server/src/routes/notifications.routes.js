const express = require('express');
const router = express.Router();
const unifiedNotificationService = require('../services/unifiedNotificationService');
const db = require('../services/database');

/**
 * POST /api/notifications/send
 * Send notification via all available channels
 * Body: {
 *   userId: string,
 *   phoneNumber: string (optional),
 *   fcmToken: string (optional),
 *   title: string,
 *   body: string,
 *   data: object (optional),
 *   sendFCM: boolean (default: true),
 *   sendWhatsApp: boolean (default: true),
 *   sendLocal: boolean (default: true)
 * }
 */
router.post('/send', async (req, res) => {
  try {
    const {
      userId,
      phoneNumber,
      fcmToken,
      title,
      body,
      data = {},
      sendFCM = true,
      sendWhatsApp = true,
      sendLocal = true,
    } = req.body;

    console.log('📨 Notification request received:');
    console.log('  userId:', userId);
    console.log('  phoneNumber:', phoneNumber);
    console.log('  title:', title);
    console.log('  body:', body);
    console.log('  sendWhatsApp:', sendWhatsApp);

    if (!title || !body) {
      return res.status(400).json({
        success: false,
        error: 'title and body are required',
      });
    }

    const result = await unifiedNotificationService.sendNotification({
      userId,
      phoneNumber,
      fcmToken,
      title,
      body,
      data,
      sendFCM,
      sendWhatsApp,
      sendLocal,
    });

    console.log('✅ Notification sent, result:', JSON.stringify(result, null, 2));
    res.json(result);
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/notifications/bulk
 * Send notification to multiple users
 * Body: {
 *   users: array of {userId, phoneNumber, fcmToken},
 *   title: string,
 *   body: string,
 *   data: object (optional),
 *   sendFCM: boolean (default: true),
 *   sendWhatsApp: boolean (default: true),
 *   sendLocal: boolean (default: true)
 * }
 */
router.post('/bulk', async (req, res) => {
  try {
    const {
      users,
      title,
      body,
      data = {},
      sendFCM = true,
      sendWhatsApp = true,
      sendLocal = true,
    } = req.body;

    if (!users || !Array.isArray(users) || users.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'users array is required and must not be empty',
      });
    }

    if (!title || !body) {
      return res.status(400).json({
        success: false,
        error: 'title and body are required',
      });
    }

    const result = await unifiedNotificationService.sendBulkNotification(
      users,
      title,
      body,
      data,
      { sendFCM, sendWhatsApp, sendLocal },
    );

    res.json(result);
  } catch (error) {
    console.error('Error sending bulk notification:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/notifications/streak-reminder
 * Send streak reminder notification
 * Body: {
 *   userId: string,
 *   tracker: string (menstruation, pregnancy, menopause)
 * }
 */
router.post('/streak-reminder', async (req, res) => {
  try {
    const { userId, tracker } = req.body;

    if (!userId || !tracker) {
      return res.status(400).json({
        success: false,
        error: 'userId and tracker are required',
      });
    }

    // Get user profile
    const user = db.get('users').find({ user_id: userId }).value();
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    // Get streak info
    const streak = db.get('streaks')
      .find({ user_id: userId, category: tracker })
      .value();

    const streakDays = streak?.current_streak || 0;

    const result = await unifiedNotificationService.sendStreakReminder(
      {
        userId,
        phoneNumber: user.phone_number,
        fcmToken: user.fcm_token,
        name: user.name,
      },
      tracker,
      streakDays,
    );

    res.json(result);
  } catch (error) {
    console.error('Error sending streak reminder:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/notifications/period-reminder
 * Send period prediction reminder
 * Body: {
 *   userId: string,
 *   daysUntil: number
 * }
 */
router.post('/period-reminder', async (req, res) => {
  try {
    const { userId, daysUntil } = req.body;

    if (!userId || daysUntil === undefined) {
      return res.status(400).json({
        success: false,
        error: 'userId and daysUntil are required',
      });
    }

    // Get user profile
    const user = db.get('users').find({ user_id: userId }).value();
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    const result = await unifiedNotificationService.sendPeriodReminder(
      {
        userId,
        phoneNumber: user.phone_number,
        fcmToken: user.fcm_token,
        name: user.name,
      },
      daysUntil,
    );

    res.json(result);
  } catch (error) {
    console.error('Error sending period reminder:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/notifications/health-tip
 * Send health tip notification based on user's logs
 * Body: {
 *   userId: string,
 *   tracker: string (menstruation, pregnancy, menopause)
 * }
 */
router.post('/health-tip', async (req, res) => {
  try {
    const { userId, tracker = 'menstruation' } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'userId is required',
      });
    }

    // Get user profile
    const user = db.get('users').find({ user_id: userId }).value();
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    const result = await unifiedNotificationService.sendHealthTip(
      {
        userId,
        phoneNumber: user.phone_number,
        fcmToken: user.fcm_token,
        name: user.name,
      },
      tracker,
    );

    res.json(result);
  } catch (error) {
    console.error('Error sending health tip:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/notifications/appointment-reminder
 * Send appointment reminder notification
 * Body: {
 *   userId: string,
 *   appointmentTitle: string,
 *   appointmentTime: string,
 *   minutesBefore: number (optional, default: 60)
 * }
 */
router.post('/appointment-reminder', async (req, res) => {
  try {
    const {
      userId,
      appointmentTitle,
      appointmentTime,
      minutesBefore = 60,
    } = req.body;

    if (!userId || !appointmentTitle || !appointmentTime) {
      return res.status(400).json({
        success: false,
        error: 'userId, appointmentTitle, and appointmentTime are required',
      });
    }

    // Get user profile
    const user = db.get('users').find({ user_id: userId }).value();
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    const result = await unifiedNotificationService.sendAppointmentReminder(
      {
        userId,
        phoneNumber: user.phone_number,
        fcmToken: user.fcm_token,
        name: user.name,
      },
      appointmentTitle,
      appointmentTime,
      minutesBefore,
    );

    res.json(result);
  } catch (error) {
    console.error('Error sending appointment reminder:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/notifications/voucher
 * Send voucher notification
 * Body: {
 *   userId: string,
 *   voucherName: string,
 *   points: number
 * }
 */
router.post('/voucher', async (req, res) => {
  try {
    const { userId, voucherName, points } = req.body;

    if (!userId || !voucherName || !points) {
      return res.status(400).json({
        success: false,
        error: 'userId, voucherName, and points are required',
      });
    }

    // Get user profile
    const user = db.get('users').find({ user_id: userId }).value();
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    const result = await unifiedNotificationService.sendVoucherNotification(
      {
        userId,
        phoneNumber: user.phone_number,
        fcmToken: user.fcm_token,
        name: user.name,
      },
      voucherName,
      points,
    );

    res.json(result);
  } catch (error) {
    console.error('Error sending voucher notification:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/notifications/status
 * Get notification service status
 */
router.get('/status', (req, res) => {
  try {
    const status = unifiedNotificationService.getStatus();
    res.json({
      success: true,
      status,
    });
  } catch (error) {
    console.error('Error getting notification status:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/notifications/motivation
 * Send motivation message based on user's points
 * Body: {
 *   userId: string
 * }
 */
router.post('/motivation', async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'userId is required',
      });
    }

    // Get user profile
    const user = db.get('users').find({ user_id: userId }).value();
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    const result = await unifiedNotificationService.sendMotivationMessage({
      userId,
      phoneNumber: user.phone_number,
      fcmToken: user.fcm_token,
      name: user.name,
    });

    res.json(result);
  } catch (error) {
    console.error('Error sending motivation message:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/notifications/daily-checkin
 * Send daily check-in reminder
 * Body: {
 *   userId: string,
 *   tracker: string (menstruation, pregnancy, menopause)
 * }
 */
router.post('/daily-checkin', async (req, res) => {
  try {
    const { userId, tracker = 'menstruation' } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'userId is required',
      });
    }

    // Get user profile
    const user = db.get('users').find({ user_id: userId }).value();
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    const result = await unifiedNotificationService.sendDailyCheckInReminder(
      {
        userId,
        phoneNumber: user.phone_number,
        fcmToken: user.fcm_token,
        name: user.name,
      },
      tracker,
    );

    res.json(result);
  } catch (error) {
    console.error('Error sending daily check-in reminder:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/notifications/generate-personalized
 * Generate personalized notification using Gemini AI based on user logs
 * Body: {
 *   userId: string,
 *   tracker: string (menstruation, pregnancy, menopause),
 *   cycleDay: number
 * }
 */
router.post('/generate-personalized', async (req, res) => {
  try {
    const { userId, tracker, cycleDay } = req.body;

    if (!userId || !tracker || cycleDay === undefined) {
      return res.status(400).json({
        success: false,
        error: 'userId, tracker, and cycleDay are required',
      });
    }

    const geminiService = require('../services/geminiNotificationService');

    const notification = await geminiService.generatePersonalizedNotification(
      userId,
      tracker,
      cycleDay,
    );

    res.json({
      success: true,
      title: notification.title,
      body: notification.body,
    });
  } catch (error) {
    console.error('Error generating personalized notification:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/notifications/period-reminder-ai
 * Generate cute, loving period reminder using Gemini AI based on user logs
 * Body: {
 *   userId: string,
 *   daysUntil: number
 * }
 */
router.post('/period-reminder-ai', async (req, res) => {
  try {
    const { userId, daysUntil } = req.body;

    if (!userId || daysUntil === undefined) {
      return res.status(400).json({
        success: false,
        error: 'userId and daysUntil are required',
      });
    }

    const periodReminderService = require('../services/periodReminderService');

    const reminder = await periodReminderService.generatePeriodReminder(
      userId,
      daysUntil,
    );

    // Get user for phone number
    const user = db.get('users').find({ user_id: userId }).value();

    // Send notification
    const unifiedNotificationService = require('../services/unifiedNotificationService');
    const result = await unifiedNotificationService.sendNotification({
      userId,
      phoneNumber: user?.phone_number,
      fcmToken: user?.fcm_token,
      title: reminder.title,
      body: reminder.body,
      data: {
        type: 'period_reminder',
        daysUntil,
      },
      sendWhatsApp: true,
      sendLocal: true,
    });

    res.json({
      success: true,
      reminder,
      notificationResult: result,
    });
  } catch (error) {
    console.error('Error sending period reminder:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

module.exports = router;
