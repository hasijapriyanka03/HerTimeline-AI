// Use dynamic import for ES module compatibility
let nodemailer;

class EmailService {
  constructor() {
    this.transporter = null;
    this.isInitialized = false;
  }

  async initializeTransporter() {
    if (this.isInitialized) return true;

    try {
      // Dynamically import nodemailer (ES module)
      const nodemailerModule = await import('nodemailer');
      nodemailer = nodemailerModule.default || nodemailerModule;

      this.transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_APP_PASSWORD,
        },
      });

      // Test connection
      await this.transporter.verify();
      console.log('✅ Email service initialized and verified');
      this.isInitialized = true;
      return true;
    } catch (error) {
      console.error('❌ Failed to initialize email service:', error.message);
      return false;
    }
  }

  async sendEmergencyAlert(userProfile, emergencyContact) {
    if (!this.isInitialized) {
      const initialized = await this.initializeTransporter();
      if (!initialized) {
        throw new Error('Email service not available');
      }
    }

    try {
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: emergencyContact.email,
        subject: `🚨 EMERGENCY ALERT - ${userProfile.name}`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #fff5f5; border: 3px solid #ff4444; border-radius: 10px;">
            <div style="text-align: center; margin-bottom: 20px;">
              <h1 style="color: #ff4444; margin: 0;">🚨 EMERGENCY ALERT 🚨</h1>
            </div>
            
            <div style="background-color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
              <h2 style="color: #333; margin-top: 0;">Emergency Contact Needed</h2>
              <p style="font-size: 16px; color: #666; line-height: 1.6;">
                <strong>${userProfile.name}</strong> has triggered an emergency alert and needs immediate assistance.
              </p>
              <p style="font-size: 16px; color: #666; line-height: 1.6;">
                <strong>Please contact them immediately!</strong>
              </p>
            </div>

            <div style="background-color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
              <h3 style="color: #333; margin-top: 0;">User Details:</h3>
              <table style="width: 100%; border-collapse: collapse;">
                <tr>
                  <td style="padding: 8px 0; color: #666;"><strong>Name:</strong></td>
                  <td style="padding: 8px 0; color: #333;">${userProfile.name}</td>
                </tr>
                <tr>
                  <td style="padding: 8px 0; color: #666;"><strong>Age:</strong></td>
                  <td style="padding: 8px 0; color: #333;">${userProfile.age} years</td>
                </tr>
                ${
                  userProfile.blood_type
                    ? `
                <tr>
                  <td style="padding: 8px 0; color: #666;"><strong>Blood Type:</strong></td>
                  <td style="padding: 8px 0; color: #333;">${userProfile.blood_type}</td>
                </tr>
                `
                    : ''
                }
                ${
                  userProfile.tracker_type
                    ? `
                <tr>
                  <td style="padding: 8px 0; color: #666;"><strong>Health Tracker:</strong></td>
                  <td style="padding: 8px 0; color: #333;">${userProfile.tracker_type.charAt(0).toUpperCase() + userProfile.tracker_type.slice(1)}</td>
                </tr>
                `
                    : ''
                }
              </table>
            </div>

            ${
              userProfile.medical_conditions &&
              userProfile.medical_conditions.length > 0
                ? `
            <div style="background-color: #fff3cd; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #ffc107;">
              <h3 style="color: #856404; margin-top: 0;">⚠️ Medical Conditions:</h3>
              <ul style="margin: 0; padding-left: 20px; color: #856404;">
                ${userProfile.medical_conditions.map((condition) => `<li>${condition}</li>`).join('')}
              </ul>
            </div>
            `
                : ''
            }

            ${
              userProfile.allergies && userProfile.allergies.length > 0
                ? `
            <div style="background-color: #f8d7da; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #dc3545;">
              <h3 style="color: #721c24; margin-top: 0;">🚫 Allergies:</h3>
              <ul style="margin: 0; padding-left: 20px; color: #721c24;">
                ${userProfile.allergies.map((allergy) => `<li>${allergy}</li>`).join('')}
              </ul>
            </div>
            `
                : ''
            }

            ${
              userProfile.medications && userProfile.medications.length > 0
                ? `
            <div style="background-color: #d1ecf1; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #17a2b8;">
              <h3 style="color: #0c5460; margin-top: 0;">💊 Current Medications:</h3>
              <ul style="margin: 0; padding-left: 20px; color: #0c5460;">
                ${userProfile.medications.map((med) => `<li>${med}</li>`).join('')}
              </ul>
            </div>
            `
                : ''
            }

            <div style="background-color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
              <h3 style="color: #333; margin-top: 0;">📞 Contact Information:</h3>
              ${
                emergencyContact.phone
                  ? `
              <p style="font-size: 16px; color: #666; margin: 10px 0;">
                <strong>Phone:</strong> <a href="tel:${emergencyContact.phone}" style="color: #007bff; text-decoration: none;">${emergencyContact.phone}</a>
              </p>
              `
                  : ''
              }
              ${
                emergencyContact.email
                  ? `
              <p style="font-size: 16px; color: #666; margin: 10px 0;">
                <strong>Email:</strong> <a href="mailto:${emergencyContact.email}" style="color: #007bff; text-decoration: none;">${emergencyContact.email}</a>
              </p>
              `
                  : ''
              }
            </div>

            <div style="background-color: #ff4444; color: white; padding: 15px; border-radius: 8px; text-align: center;">
              <p style="margin: 0; font-size: 14px;">
                <strong>This is an automated emergency alert from Mensa Health App</strong><br>
                Alert sent at: ${new Date().toLocaleString()}
              </p>
            </div>
          </div>
        `,
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log('✅ Emergency email sent:', info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error('❌ Error sending emergency email:', error);
      return { success: false, error: error.message };
    }
  }

  async testConnection() {
    if (!this.isInitialized) {
      return await this.initializeTransporter();
    }

    try {
      await this.transporter.verify();
      console.log('✅ Email service is ready');
      return true;
    } catch (error) {
      console.error('❌ Email service error:', error);
      return false;
    }
  }
}

module.exports = new EmailService();
