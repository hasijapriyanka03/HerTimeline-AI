const { GoogleGenAI } = require('@google/genai');
require('dotenv').config();

const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey) {
  console.error('❌ GEMINI_API_KEY not found');
  process.exit(1);
}

console.log('🔑 Using API Key:', apiKey.substring(0, 10) + '...');

const ai = new GoogleGenAI({ apiKey });

async function test() {
  const modelsToTest = [
    'gemini-3-pro-preview',
    'gemini-2.5-flash',
    'gemini-2.5-flash',
    'gemini-1.5-pro',
    'gemini-2.0-flash-exp'
  ];
  
  for (const modelName of modelsToTest) {
    try {
      console.log(`\n🧪 Testing ${modelName}...\n`);
      
      const response = await ai.models.generateContent({
        model: modelName,
        contents: 'What are menstrual cramps? Give a brief answer.',
      });
      
      console.log('✅ SUCCESS!\n');
      console.log('Response:', response.text);
      console.log('\n🏆 WORKING MODEL:', modelName);
      console.log('='.repeat(60));
      return; // Stop after first success
    } catch (error) {
      console.error(`❌ ${modelName} FAILED:`, error.message.substring(0, 150));
    }
    
    // Wait 2 seconds between attempts
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
  
  console.log('\n❌ All models failed');
}

test();
