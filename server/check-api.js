const axios = require('axios');

const apiKey = 'AIzaSyACXZ5XpLB-eTMARR-uZtYZevRP87Wtxzk';
const model = 'gemini-2.5-flash';

async function test() {
  try {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:streamGenerateContent?alt=sse&key=${apiKey}`;
    
    console.log('Testing Gemini API...');
    const response = await axios.post(url, {
      contents: [{
        parts: [{ text: 'Hello' }]
      }]
    }, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 10000
    });
    
    console.log('✅ API is working! Status:', response.status);
  } catch (error) {
    console.error('❌ API Error:', error.response?.status);
    console.error('Message:', error.response?.data?.error?.message || error.message);
    
    if (error.response?.status === 429) {
      console.error('\n🚨 RATE LIMITED - Your API key has hit the rate limit');
      console.error('💡 Solution: Get a new API key from Google Cloud Console');
    } else if (error.response?.status === 403) {
      console.error('\n🚨 FORBIDDEN - API key issue');
      console.error('💡 Check: 1) API key is valid 2) Generative Language API is enabled 3) Quota not exceeded');
    }
  }
}

test();
