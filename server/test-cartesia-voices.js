const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const axios = require('axios');

const CARTESIA_API_KEY = process.env.AGORA_TTS_API_KEY;

async function listCartesiaVoices() {
  try {
    console.log('🔍 Fetching available Cartesia voices...\n');
    console.log(`🔑 API Key loaded: ${CARTESIA_API_KEY ? 'YES (' + CARTESIA_API_KEY.substring(0, 10) + '...)' : 'NO'}`);
    
    const response = await axios.get('https://api.cartesia.ai/voices', {
      headers: {
        'X-API-Key': CARTESIA_API_KEY,
        'Cartesia-Version': '2025-04-16',
        'Content-Type': 'application/json',
      },
    });

    console.log('✅ Available Cartesia Voices:\n');
    
    if (response.data.voices && Array.isArray(response.data.voices)) {
      response.data.voices.forEach((voice, index) => {
        console.log(`${index + 1}. ${voice.name}`);
        console.log(`   ID: ${voice.id}`);
        console.log(`   Language: ${voice.language || 'N/A'}`);
        console.log(`   Description: ${voice.description || 'N/A'}`);
        console.log('');
      });
    } else {
      console.log('Response structure:', JSON.stringify(response.data, null, 2));
    }
  } catch (error) {
    console.error('❌ Error fetching voices:');
    console.error('Status:', error.response?.status);
    console.error('Message:', error.message);
    console.error('Response:', error.response?.data);
  }
}

listCartesiaVoices();
