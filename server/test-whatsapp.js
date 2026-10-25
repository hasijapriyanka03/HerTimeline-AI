require('dotenv').config({ path: require('path').join(__dirname, '.env') });
const twilioService = require('./src/services/twilioWhatsappService');

async function testWhatsApp() {
  console.log('\n🧪 Testing WhatsApp Notification Service\n');

  // Check Twilio configuration
  console.log('1️⃣ Checking Twilio Configuration...');
  const status = twilioService.getStatus();
  console.log('Status:', JSON.stringify(status, null, 2));

  if (!status.configured) {
    console.error('❌ Twilio is not configured!');
    console.error('Missing:');
    if (!status.hasAccountSid) console.error('  - TWILIO_ACCOUNT_SID');
    if (!status.hasAuthToken) console.error('  - TWILIO_AUTH_TOKEN');
    if (!status.hasPhoneNumber) console.error('  - TWILIO_WHATSAPP_NUMBER');
    process.exit(1);
  }

  console.log('✅ Twilio is configured\n');

  // Test sending a message
  console.log('2️⃣ Sending Test WhatsApp Message...');
  console.log('To: +919811226924');
  console.log('Message: This is a test WhatsApp message from Mensa app\n');

  try {
    const result = await twilioService.sendMessage(
      '+919811226924',
      '🌸 Menstrual Phase\nStay hydrated and rest well. You\'re doing great! 💪\n\nYour next period is expected in 27 days'
    );

    console.log('Result:', JSON.stringify(result, null, 2));

    if (result.success) {
      console.log('\n✅ Message sent successfully!');
      console.log('Message ID:', result.messageId);
      console.log('\n📱 Check your WhatsApp for the message');
      console.log('⏱️ It may take a few seconds to arrive');
    } else {
      console.error('\n❌ Failed to send message');
      console.error('Error:', result.error);
    }
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

testWhatsApp();
