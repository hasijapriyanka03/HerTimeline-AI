const http = require('http');

// Test the period reminder endpoint
const testData = {
  userId: 'user_d_g_com',
  daysUntil: 3,
};

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/notifications/period-reminder-ai',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
};

const req = http.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('Status:', res.statusCode);
    console.log('Response:', data);
    try {
      const parsed = JSON.parse(data);
      console.log('\n✅ Period Reminder Generated:');
      console.log('Title:', parsed.reminder?.title);
      console.log('Body:', parsed.reminder?.body);
      console.log('\n📨 Notification Result:');
      console.log('Success:', parsed.notificationResult?.success);
      console.log('WhatsApp:', parsed.notificationResult?.results?.whatsapp?.success);
      console.log('Local:', parsed.notificationResult?.results?.local?.success);
    } catch (e) {
      console.error('Error parsing response:', e);
    }
  });
});

req.on('error', (e) => {
  console.error('Request error:', e);
});

console.log('📤 Sending period reminder test request...');
console.log('Data:', testData);
req.write(JSON.stringify(testData));
req.end();
