const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const axios = require('axios');

const CARTESIA_API_KEY = process.env.AGORA_TTS_API_KEY;
const VOICE_ID = 'e07c00bc-4134-4eae-9ea4-1a55fb45746b';

async function testCartesiaTTS() {
  try {
    console.log('🔍 Testing Cartesia TTS directly...\n');
    console.log(`🔑 API Key: ${CARTESIA_API_KEY.substring(0, 10)}...`);
    console.log(`🎤 Voice ID: ${VOICE_ID}\n`);

    const response = await axios.post(
      'https://api.cartesia.ai/tts/bytes',
      {
        model_id: 'sonic-2',
        voice: {
          mode: 'id',
          id: VOICE_ID,
        },
        transcript: 'Hello! I am your health educator. How can I help you today?',
        output_format: {
          container: 'mp3',
          sample_rate: 16000,
        },
        language: 'en',
      },
      {
        headers: {
          'X-API-Key': CARTESIA_API_KEY,
          'Cartesia-Version': '2025-04-16',
          'Content-Type': 'application/json',
        },
        responseType: 'arraybuffer',
      }
    );

    console.log('✅ Cartesia TTS works!');
    console.log(`📊 Response size: ${response.data.length} bytes`);
    console.log(`🔊 Audio generated successfully`);
  } catch (error) {
    console.error('❌ Cartesia TTS Error:');
    console.error('Status:', error.response?.status);
    console.error('Message:', error.message);
    console.error('Response:', error.response?.data?.toString());
  }
}

testCartesiaTTS();
