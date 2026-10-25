const twilio = require('twilio');
const db = require('./database');

class TwilioWhatsappService {
  constructor() {
    this.accountSid = process.env.TWILIO_ACCOUNT_SID;
    this.authToken = process.env.TWILIO_AUTH_TOKEN;
    this.twilioPhoneNumber = process.env.TWILIO_WHATSAPP_NUMBER;

    if (!this.accountSid || !this.authToken || !this.twilioPhoneNumber) {
      console.warn('⚠️ Twilio credentials not configured. WhatsApp notifications will be disabled.');
      this.client = null;
    } else {
      this.client = twilio(this.accountSid, this.authToken);
      console.log('✅ Twilio WhatsApp service initialized');
    }
  }

  /**
   * Send a simple text message via WhatsApp
   * @param {string} phoneNumber - Recipient phone number (with country code, e.g., +1234567890)
   * @param {string} message - Message text
   * @returns {Promise<Object>} Response from Twilio
   */
  async sendMessage(phoneNumber, message) {
    try {
      if (!this.client) {
        console.warn('⚠️ Twilio not configured. Skipping WhatsApp notification.');
        return { success: false, error: 'Twilio not configured' };
      }

      console.log(`📱 Sending WhatsApp message to ${phoneNumber}...`);

      const response = await this.client.messages.create({
        from: `whatsapp:${this.twilioPhoneNumber}`,
        to: `whatsapp:${phoneNumber}`,
        body: message,
      });

      console.log('✅ WhatsApp message sent successfully:', response.sid);
      return {
        success: true,
        messageId: response.sid,
        timestamp: response.dateCreated,
      };
    } catch (error) {
      console.error('❌ Error sending WhatsApp message:', error.message);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Send a message with media
   * @param {string} phoneNumber - Recipient phone number
   * @param {string} message - Message text
   * @param {string} mediaUrl - URL of media (image, video, document)
   * @returns {Promise<Object>} Response from Twilio
   */
  async sendMediaMessage(phoneNumber, message, mediaUrl) {
    try {
      if (!this.client) {
        console.warn('⚠️ Twilio not configured. Skipping WhatsApp notification.');
        return { success: false, error: 'Twilio not configured' };
      }

      console.log(`📱 Sending WhatsApp media message to ${phoneNumber}...`);

      const response = await this.client.messages.create({
        from: `whatsapp:${this.twilioPhoneNumber}`,
        to: `whatsapp:${phoneNumber}`,
        body: message,
        mediaUrl: [mediaUrl],
      });

      console.log('✅ WhatsApp media message sent successfully:', response.sid);
      return {
        success: true,
        messageId: response.sid,
        timestamp: response.dateCreated,
      };
    } catch (error) {
      console.error('❌ Error sending WhatsApp media message:', error.message);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Check if Twilio is configured
   * @returns {boolean} True if Twilio is configured
   */
  isConfigured() {
    return !!(this.client && this.accountSid && this.authToken && this.twilioPhoneNumber);
  }

  /**
   * Get Twilio configuration status
   * @returns {Object} Configuration status
   */
  getStatus() {
    return {
      configured: this.isConfigured(),
      hasAccountSid: !!this.accountSid,
      hasAuthToken: !!this.authToken,
      hasPhoneNumber: !!this.twilioPhoneNumber,
      phoneNumber: this.twilioPhoneNumber ? this.twilioPhoneNumber.substring(0, 3) + '***' : null,
    };
  }
}

module.exports = new TwilioWhatsappService();
