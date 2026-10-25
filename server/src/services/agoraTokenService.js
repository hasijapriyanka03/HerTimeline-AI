const { RtcTokenBuilder, RtcRole } = require('agora-token');

class AgoraTokenService {
  constructor() {
    this.appId = process.env.AGORA_APP_ID;
    this.appCertificate = process.env.AGORA_APP_CERTIFICATE;

    if (!this.appId || !this.appCertificate) {
      console.warn(
        '⚠️ Agora App ID or Certificate not configured. Token generation will fail.',
      );
    }
  }

  /**
   * Generate RTC token for Agora channel
   * @param {string} channelName - Channel name
   * @param {number} uid - User ID
   * @param {number} expirationTimeInSeconds - Token expiration time (default 3600 = 1 hour)
   * @returns {string} RTC token
   */
  generateToken(
    channelName,
    uid,
    expirationTimeInSeconds = 3600,
  ) {
    try {
      if (!this.appId || !this.appCertificate) {
        throw new Error('Agora credentials not configured');
      }

      console.log(
        `🔑 Generating RTC token for channel: ${channelName}, uid: ${uid}`,
      );

      const token = RtcTokenBuilder.buildTokenWithUid(
        this.appId,
        this.appCertificate,
        channelName,
        uid,
        RtcRole.PUBLISHER,
        expirationTimeInSeconds,
      );

      console.log('✅ RTC token generated successfully');
      return token;
    } catch (error) {
      console.error('❌ Error generating RTC token:', error.message);
      throw error;
    }
  }

  /**
   * Generate token with RTM2 privileges for agent (required for Conversational AI)
   * @param {string} channelName - Channel name
   * @param {number} uid - User ID (numeric)
   * @param {number} expirationTimeInSeconds - Token expiration time (default 3600 = 1 hour)
   * @returns {string} RTC+RTM2 token
   */
  generateAgentTokenWithRtm2(channelName, uid, expirationTimeInSeconds = 3600) {
    try {
      if (!this.appId || !this.appCertificate) {
        throw new Error('Agora credentials not configured');
      }

      console.log(
        `🔑 Generating RTC+RTM2 token for channel: ${channelName}, uid: ${uid}`,
      );

      // Check if buildTokenWithRtm2 is available
      if (typeof RtcTokenBuilder.buildTokenWithRtm2 === 'function') {
        const token = RtcTokenBuilder.buildTokenWithRtm2(
          this.appId,
          this.appCertificate,
          channelName,
          uid,
          RtcRole.PUBLISHER,
          expirationTimeInSeconds,
          expirationTimeInSeconds,
          expirationTimeInSeconds,
          expirationTimeInSeconds,
          expirationTimeInSeconds,
          String(uid), // RTM user ID (string)
          expirationTimeInSeconds,
        );
        console.log('✅ RTC+RTM2 token generated successfully');
        return token;
      } else {
        // Fallback to regular token if RTM2 not available
        console.warn('⚠️ buildTokenWithRtm2 not available, using buildTokenWithUid');
        return this.generateToken(channelName, uid, expirationTimeInSeconds);
      }
    } catch (error) {
      console.error('❌ Error generating RTC+RTM2 token:', error.message);
      // Fallback to regular token
      return this.generateToken(channelName, uid, expirationTimeInSeconds);
    }
  }

  /**
   * Validate token
   * @param {string} token - Token to validate
   * @returns {boolean} True if token is valid
   */
  validateToken(token) {
    try {
      return typeof token === 'string' && token.length > 0;
    } catch (error) {
      console.error('Error validating token:', error.message);
      return false;
    }
  }
}

module.exports = new AgoraTokenService();
