const axios = require('axios');

class WhatsAppNotificationService {
  constructor() {
    this.whatsappApiUrl = process.env.WHATSAPP_API_URL || 'https://graph.instagram.com/v18.0';
    this.whatsappPhoneNumberId = process.env.WHATSAPP_PHONE_NUMBER_ID;
    this.whatsappAccessToken = process.env.WHATSAPP_ACCESS_TOKEN;
    this.whatsappBusinessAccountId = process.env.WHATSAPP_BUSINESS_ACCOUNT_ID;

    if (!this.whatsappAccessToken) {
      console.warn('⚠️ WhatsApp Access Token not configured. WhatsApp notifications will be disabled.');
    }
  }

  /**
   * Send a text message via WhatsApp
   * @param {string} phoneNumber - Recipient phone number (with country code, e.g., +1234567890)
   * @param {string} message - Message text
   * @returns {Promise<Object>} Response from WhatsApp API
   */
  async sendTextMessage(phoneNumber, message) {
    try {
      if (!this.whatsappAccessToken || !this.whatsappPhoneNumberId) {
        console.warn('⚠️ WhatsApp not configured. Skipping WhatsApp notification.');
        return { success: false, error: 'WhatsApp not configured' };
      }

      const url = `${this.whatsappApiUrl}/${this.whatsappPhoneNumberId}/messages`;

      const payload = {
        messaging_product: 'whatsapp',
        to: phoneNumber,
        type: 'text',
        text: {
          body: message,
        },
      };

      console.log(`📱 Sending WhatsApp message to ${phoneNumber}...`);

      const response = await axios.post(url, payload, {
        headers: {
          Authorization: `Bearer ${this.whatsappAccessToken}`,
          'Content-Type': 'application/json',
        },
      });

      console.log('✅ WhatsApp message sent successfully:', response.data.messages[0].id);
      return {
        success: true,
        messageId: response.data.messages[0].id,
        timestamp: response.data.messages[0].timestamp,
      };
    } catch (error) {
      console.error('❌ Error sending WhatsApp message:', error.response?.data || error.message);
      return {
        success: false,
        error: error.response?.data?.error?.message || error.message,
      };
    }
  }

  /**
   * Send a template message via WhatsApp
   * @param {string} phoneNumber - Recipient phone number
   * @param {string} templateName - Template name
   * @param {Array} parameters - Template parameters
   * @returns {Promise<Object>} Response from WhatsApp API
   */
  async sendTemplateMessage(phoneNumber, templateName, parameters = []) {
    try {
      if (!this.whatsappAccessToken || !this.whatsappPhoneNumberId) {
        console.warn('⚠️ WhatsApp not configured. Skipping WhatsApp notification.');
        return { success: false, error: 'WhatsApp not configured' };
      }

      const url = `${this.whatsappApiUrl}/${this.whatsappPhoneNumberId}/messages`;

      const payload = {
        messaging_product: 'whatsapp',
        to: phoneNumber,
        type: 'template',
        template: {
          name: templateName,
          language: {
            code: 'en_US',
          },
          components: [
            {
              type: 'body',
              parameters: parameters.map(param => ({ type: 'text', text: param })),
            },
          ],
        },
      };

      console.log(`📱 Sending WhatsApp template message to ${phoneNumber}...`);

      const response = await axios.post(url, payload, {
        headers: {
          Authorization: `Bearer ${this.whatsappAccessToken}`,
          'Content-Type': 'application/json',
        },
      });

      console.log('✅ WhatsApp template message sent successfully:', response.data.messages[0].id);
      return {
        success: true,
        messageId: response.data.messages[0].id,
        timestamp: response.data.messages[0].timestamp,
      };
    } catch (error) {
      console.error('❌ Error sending WhatsApp template message:', error.response?.data || error.message);
      return {
        success: false,
        error: error.response?.data?.error?.message || error.message,
      };
    }
  }

  /**
   * Send a notification with both text and media
   * @param {string} phoneNumber - Recipient phone number
   * @param {string} message - Message text
   * @param {string} mediaUrl - URL of media (image, video, document)
   * @param {string} mediaType - Type of media: 'image', 'video', 'document', 'audio'
   * @returns {Promise<Object>} Response from WhatsApp API
   */
  async sendMediaMessage(phoneNumber, message, mediaUrl, mediaType = 'image') {
    try {
      if (!this.whatsappAccessToken || !this.whatsappPhoneNumberId) {
        console.warn('⚠️ WhatsApp not configured. Skipping WhatsApp notification.');
        return { success: false, error: 'WhatsApp not configured' };
      }

      const url = `${this.whatsappApiUrl}/${this.whatsappPhoneNumberId}/messages`;

      const mediaTypeMap = {
        image: 'image',
        video: 'video',
        document: 'document',
        audio: 'audio',
      };

      const payload = {
        messaging_product: 'whatsapp',
        to: phoneNumber,
        type: mediaType,
        [mediaType]: {
          link: mediaUrl,
        },
        caption: message,
      };

      console.log(`📱 Sending WhatsApp ${mediaType} message to ${phoneNumber}...`);

      const response = await axios.post(url, payload, {
        headers: {
          Authorization: `Bearer ${this.whatsappAccessToken}`,
          'Content-Type': 'application/json',
        },
      });

      console.log('✅ WhatsApp media message sent successfully:', response.data.messages[0].id);
      return {
        success: true,
        messageId: response.data.messages[0].id,
        timestamp: response.data.messages[0].timestamp,
      };
    } catch (error) {
      console.error('❌ Error sending WhatsApp media message:', error.response?.data || error.message);
      return {
        success: false,
        error: error.response?.data?.error?.message || error.message,
      };
    }
  }

  /**
   * Send a notification with buttons
   * @param {string} phoneNumber - Recipient phone number
   * @param {string} message - Message text
   * @param {Array} buttons - Array of button objects {id, title}
   * @returns {Promise<Object>} Response from WhatsApp API
   */
  async sendButtonMessage(phoneNumber, message, buttons = []) {
    try {
      if (!this.whatsappAccessToken || !this.whatsappPhoneNumberId) {
        console.warn('⚠️ WhatsApp not configured. Skipping WhatsApp notification.');
        return { success: false, error: 'WhatsApp not configured' };
      }

      const url = `${this.whatsappApiUrl}/${this.whatsappPhoneNumberId}/messages`;

      const payload = {
        messaging_product: 'whatsapp',
        to: phoneNumber,
        type: 'interactive',
        interactive: {
          type: 'button',
          body: {
            text: message,
          },
          action: {
            buttons: buttons.map((btn, index) => ({
              type: 'reply',
              reply: {
                id: btn.id || `btn_${index}`,
                title: btn.title,
              },
            })),
          },
        },
      };

      console.log(`📱 Sending WhatsApp button message to ${phoneNumber}...`);

      const response = await axios.post(url, payload, {
        headers: {
          Authorization: `Bearer ${this.whatsappAccessToken}`,
          'Content-Type': 'application/json',
        },
      });

      console.log('✅ WhatsApp button message sent successfully:', response.data.messages[0].id);
      return {
        success: true,
        messageId: response.data.messages[0].id,
        timestamp: response.data.messages[0].timestamp,
      };
    } catch (error) {
      console.error('❌ Error sending WhatsApp button message:', error.response?.data || error.message);
      return {
        success: false,
        error: error.response?.data?.error?.message || error.message,
      };
    }
  }

  /**
   * Check if WhatsApp is configured
   * @returns {boolean} True if WhatsApp is configured
   */
  isConfigured() {
    return !!(this.whatsappAccessToken && this.whatsappPhoneNumberId);
  }

  /**
   * Get WhatsApp configuration status
   * @returns {Object} Configuration status
   */
  getStatus() {
    return {
      configured: this.isConfigured(),
      hasAccessToken: !!this.whatsappAccessToken,
      hasPhoneNumberId: !!this.whatsappPhoneNumberId,
      apiUrl: this.whatsappApiUrl,
    };
  }
}

module.exports = new WhatsAppNotificationService();
