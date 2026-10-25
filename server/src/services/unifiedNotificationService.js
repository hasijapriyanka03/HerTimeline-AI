const fcmService = require('./fcmService');
const twilioService = require('./twilioWhatsappService');
const personalizedMessageService = require('./personalizedMessageService');
const db = require('./database');

class UnifiedNotificationService {
  /**
   * Send notification via all available channels
   * @param {Object} options - Notification options
   * @param {string} options.userId - User ID (for FCM token lookup)
   * @param {string} options.phoneNumber - Phone number for WhatsApp (with country code)
   * @param {string} options.fcmToken - FCM token (optional, if not provided will use userId)
   * @param {string} options.title - Notification title
   * @param {string} options.body - Notification body
   * @param {Object} options.data - Additional data
   * @param {boolean} options.sendFCM - Send via FCM (default: true)
   * @param {boolean} options.sendWhatsApp - Send via WhatsApp (default: true)
   * @param {boolean} options.sendLocal - Send local notification (default: true)
   * @returns {Promise<Object>} Results from all channels
   */
  async sendNotification(options) {
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
    } = options;

    const results = {
      fcm: null,
      whatsapp: null,
      local: null,
      timestamp: new Date().toISOString(),
    };

    try {
      // Send FCM notification
      if (sendFCM && fcmToken) {
        console.log('📤 Sending FCM notification...');
        results.fcm = await fcmService.sendToDevice(
          fcmToken,
          { title, body },
          data,
        );
      }

      // Send WhatsApp notification via Twilio
      if (sendWhatsApp && phoneNumber) {
        console.log('📱 Sending WhatsApp notification via Twilio...');
        results.whatsapp = await twilioService.sendMessage(phoneNumber, body);
      }

      // Local notification is handled on the client side
      if (sendLocal) {
        console.log('🔔 Local notification will be shown on client');
        results.local = {
          success: true,
          message: 'Local notification queued for client',
        };
      }

      console.log('✅ Notification sent via all channels');
      return {
        success: true,
        results,
      };
    } catch (error) {
      console.error('❌ Error sending unified notification:', error);
      return {
        success: false,
        error: error.message,
        results,
      };
    }
  }

  /**
   * Send notification to multiple users
   * @param {Array} users - Array of user objects {userId, phoneNumber, fcmToken}
   * @param {string} title - Notification title
   * @param {string} body - Notification body
   * @param {Object} data - Additional data
   * @param {Object} options - Send options {sendFCM, sendWhatsApp, sendLocal}
   * @returns {Promise<Object>} Results for all users
   */
  async sendBulkNotification(users, title, body, data = {}, options = {}) {
    const {
      sendFCM = true,
      sendWhatsApp = true,
      sendLocal = true,
    } = options;

    const results = {
      total: users.length,
      successful: 0,
      failed: 0,
      details: [],
      timestamp: new Date().toISOString(),
    };

    try {
      for (const user of users) {
        try {
          const result = await this.sendNotification({
            userId: user.userId,
            phoneNumber: user.phoneNumber,
            fcmToken: user.fcmToken,
            title,
            body,
            data,
            sendFCM,
            sendWhatsApp,
            sendLocal,
          });

          if (result.success) {
            results.successful++;
          } else {
            results.failed++;
          }

          results.details.push({
            userId: user.userId,
            ...result,
          });
        } catch (error) {
          results.failed++;
          results.details.push({
            userId: user.userId,
            success: false,
            error: error.message,
          });
        }
      }

      console.log(`✅ Bulk notification sent: ${results.successful}/${results.total} successful`);
      return results;
    } catch (error) {
      console.error('❌ Error sending bulk notification:', error);
      return {
        ...results,
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Send streak reminder notification with personalized message
   * @param {Object} user - User object {userId, phoneNumber, fcmToken, name}
   * @param {string} tracker - Tracker type (menstruation, pregnancy, menopause)
   * @param {number} streakDays - Current streak days
   * @returns {Promise<Object>} Notification result
   */
  async sendStreakReminder(user, tracker, streakDays) {
    const title = '🔥 Keep Your Streak Going!';
    const body = personalizedMessageService.generateStreakMessage(
      user.userId,
      tracker,
      streakDays,
      user.name,
    );

    return this.sendNotification({
      userId: user.userId,
      phoneNumber: user.phoneNumber,
      fcmToken: user.fcmToken,
      title,
      body,
      data: {
        type: 'streak_reminder',
        tracker,
        streakDays,
      },
    });
  }

  /**
   * Send period prediction notification with personalized message
   * @param {Object} user - User object {userId, phoneNumber, fcmToken, name}
   * @param {number} daysUntil - Days until next period
   * @returns {Promise<Object>} Notification result
   */
  async sendPeriodReminder(user, daysUntil) {
    const title = '🌸 Period Reminder';
    const body = personalizedMessageService.generatePeriodReminderMessage(
      user.userId,
      daysUntil,
      user.name,
    );

    return this.sendNotification({
      userId: user.userId,
      phoneNumber: user.phoneNumber,
      fcmToken: user.fcmToken,
      title,
      body,
      data: {
        type: 'period_reminder',
        daysUntil,
      },
    });
  }

  /**
   * Send health tip notification with personalized message based on logs
   * @param {Object} user - User object {userId, phoneNumber, fcmToken, name}
   * @param {string} tracker - Tracker type
   * @returns {Promise<Object>} Notification result
   */
  async sendHealthTip(user, tracker) {
    const title = '💡 Health Tip';
    const body = personalizedMessageService.generateHealthTip(
      user.userId,
      tracker,
      user.name,
    );

    return this.sendNotification({
      userId: user.userId,
      phoneNumber: user.phoneNumber,
      fcmToken: user.fcmToken,
      title,
      body,
      data: {
        type: 'health_tip',
        tracker,
      },
    });
  }

  /**
   * Send motivation message based on user's points
   * @param {Object} user - User object {userId, phoneNumber, fcmToken, name}
   * @returns {Promise<Object>} Notification result
   */
  async sendMotivationMessage(user) {
    const wallet = db.get('userWallets')
      .find({ user_id: user.userId })
      .value();

    const totalPoints = wallet?.total_points || 0;
    const title = '💪 You\'re Doing Amazing!';
    const body = personalizedMessageService.generateMotivationMessage(
      user.name,
      totalPoints,
    );

    return this.sendNotification({
      userId: user.userId,
      phoneNumber: user.phoneNumber,
      fcmToken: user.fcmToken,
      title,
      body,
      data: {
        type: 'motivation',
        totalPoints,
      },
    });
  }

  /**
   * Send appointment reminder notification with personalized message
   * @param {Object} user - User object {userId, phoneNumber, fcmToken, name}
   * @param {string} appointmentTitle - Appointment title
   * @param {string} appointmentTime - Appointment time
   * @param {number} minutesBefore - Minutes before appointment
   * @returns {Promise<Object>} Notification result
   */
  async sendAppointmentReminder(user, appointmentTitle, appointmentTime, minutesBefore = 60) {
    const title = '📅 Appointment Reminder';
    const body = personalizedMessageService.generateAppointmentReminder(
      user.name,
      appointmentTitle,
      appointmentTime,
      minutesBefore,
    );

    return this.sendNotification({
      userId: user.userId,
      phoneNumber: user.phoneNumber,
      fcmToken: user.fcmToken,
      title,
      body,
      data: {
        type: 'appointment_reminder',
        appointmentTitle,
        appointmentTime,
      },
    });
  }

  /**
   * Send voucher notification with personalized message
   * @param {Object} user - User object {userId, phoneNumber, fcmToken, name}
   * @param {string} voucherName - Voucher name
   * @param {number} points - Points required
   * @returns {Promise<Object>} Notification result
   */
  async sendVoucherNotification(user, voucherName, points) {
    const title = '🎁 New Voucher Available';
    const body = personalizedMessageService.generateVoucherMessage(
      user.name,
      voucherName,
      points,
    );

    return this.sendNotification({
      userId: user.userId,
      phoneNumber: user.phoneNumber,
      fcmToken: user.fcmToken,
      title,
      body,
      data: {
        type: 'voucher_available',
        voucherName,
        points,
      },
    });
  }

  /**
   * Send daily check-in reminder with personalized message
   * @param {Object} user - User object {userId, phoneNumber, fcmToken, name}
   * @param {string} tracker - Tracker type
   * @returns {Promise<Object>} Notification result
   */
  async sendDailyCheckInReminder(user, tracker) {
    const title = '📝 Daily Check-in Reminder';
    const body = personalizedMessageService.generateDailyCheckInReminder(
      user.name,
      tracker,
    );

    return this.sendNotification({
      userId: user.userId,
      phoneNumber: user.phoneNumber,
      fcmToken: user.fcmToken,
      title,
      body,
      data: {
        type: 'daily_checkin',
        tracker,
      },
    });
  }

  /**
   * Get notification service status
   * @returns {Object} Status of all notification services
   */
  getStatus() {
    return {
      fcm: {
        available: true,
        description: 'Firebase Cloud Messaging',
      },
      whatsapp: {
        service: 'Twilio',
        ...twilioService.getStatus(),
      },
      local: {
        available: true,
        description: 'Local device notifications',
      },
    };
  }
}

module.exports = new UnifiedNotificationService();
