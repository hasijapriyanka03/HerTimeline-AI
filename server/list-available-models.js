const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey) {
  console.error('❌ GEMINI_API_KEY not found in .env file');
  process.exit(1);
}

console.log('🔑 API Key:', apiKey.substring(0, 10) + '...' + apiKey.substring(apiKey.length - 4));

const genAI = new GoogleGenerativeAI(apiKey);

async function listModels() {
  try {
    console.log('\n🔍 Fetching available models...\n');
    
    // Try to list models using the API
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`
    );
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const data = await response.json();
    
    if (data.models && data.models.length > 0) {
      console.log('✅ Available Models:\n');
      data.models.forEach(model => {
        console.log(`  📦 ${model.name}`);
        console.log(`     Display Name: ${model.displayName}`);
        console.log(`     Supported Methods: ${model.supportedGenerationMethods?.join(', ') || 'N/A'}`);
        console.log('');
      });
      
      // Filter models that support generateContent
      const contentModels = data.models.filter(m => 
        m.supportedGenerationMethods?.includes('generateContent')
      );
      
      console.log('\n🎯 Models supporting generateContent:');
      contentModels.forEach(m => console.log(`  • ${m.name}`));
    } else {
      console.log('⚠️ No models found');
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('\nFull error:', error);
  }
}

listModels();
