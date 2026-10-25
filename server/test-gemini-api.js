const axios = require('axios');
require('dotenv').config();

async function testGeminiAPI() {
  const apiKey = process.env.AGORA_LLM_API_KEY;
  const model = process.env.AGORA_LLM_MODEL || 'gemini-2.5-flash';

  if (!apiKey) {
    console.error('❌ AGORA_LLM_API_KEY not set in .env');
    return;
  }

  console.log('🧪 Testing Gemini API...');
  console.log(`📌 API Key: ${apiKey.substring(0, 20)}...`);
  console.log(`📌 Model: ${model}`);
  console.log('');

  try {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:streamGenerateContent?alt=sse&key=${apiKey}`;

    console.log(`📤 Sending test request to: ${url.substring(0, 80)}...`);

    const response = await axios.post(
      url,
      {
        contents: [
          {
            parts: [
              {
                text: 'Say hello in one word',
              },
            ],
          },
        ],
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
        timeout: 10000,
      },
    );

    console.log('✅ API is working!');
    console.log('📊 Response status:', response.status);
    console.log('📊 Response data:', JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error('❌ API test failed!');
    console.error('Error:', error.message);

    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));

      if (error.response.status === 429) {
        console.error('');
        console.error('🚨 RATE LIMITED - Your API key has hit the rate limit');
        console.error('💡 Wait a few minutes and try again, or get a new API key');
      } else if (error.response.status === 403) {
        console.error('');
        console.error('🚨 FORBIDDEN - Check your API key and permissions');
        console.error('💡 Go to Google Cloud Console and verify:');
        console.error('   1. API key is valid');
        console.error('   2. Generative Language API is enabled');
        console.error('   3. Quota limits are not exceeded');
      } else if (error.response.status === 400) {
        console.error('');
        console.error('🚨 BAD REQUEST - Check your request format');
        console.error('💡 Verify the model name and request body are correct');
      }
    }
  }
}

testGeminiAPI();
