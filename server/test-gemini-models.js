const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey) {
  console.error('❌ GEMINI_API_KEY not found in .env file');
  process.exit(1);
}

const genAI = new GoogleGenerativeAI(apiKey);

const testPrompt = "What are menstrual cramps? Give a brief answer.";

const modelsToTest = [
  'gemini-pro',
  'gemini-1.5-pro',
  'gemini-2.5-flash',
  'gemini-2.5-flash',
  'models/gemini-pro',
  'models/gemini-1.5-pro',
  'models/gemini-2.5-flash',
  'models/gemini-2.0-flash-exp',
];

async function testModel(modelName) {
  try {
    console.log(`\n🧪 Testing: ${modelName}`);
    const model = genAI.getGenerativeModel({ model: modelName });
    
    const startTime = Date.now();
    const result = await model.generateContent(testPrompt);
    const response = await result.response;
    const text = response.text();
    const duration = Date.now() - startTime;
    
    console.log(`✅ SUCCESS (${duration}ms)`);
    console.log(`Response preview: ${text.substring(0, 100)}...`);
    return { modelName, success: true, duration, preview: text.substring(0, 100) };
  } catch (error) {
    console.log(`❌ FAILED: ${error.message.substring(0, 150)}`);
    return { modelName, success: false, error: error.message.substring(0, 150) };
  }
}

async function runTests() {
  console.log('🚀 Starting Gemini Model Tests');
  console.log('=' .repeat(60));
  
  const results = [];
  
  for (const modelName of modelsToTest) {
    const result = await testModel(modelName);
    results.push(result);
    await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1s between tests
  }
  
  console.log('\n' + '='.repeat(60));
  console.log('📊 TEST RESULTS SUMMARY');
  console.log('='.repeat(60));
  
  const successful = results.filter(r => r.success);
  const failed = results.filter(r => !r.success);
  
  if (successful.length > 0) {
    console.log('\n✅ WORKING MODELS:');
    successful.forEach(r => {
      console.log(`  • ${r.modelName} (${r.duration}ms)`);
    });
    
    // Find fastest
    const fastest = successful.reduce((prev, curr) => 
      prev.duration < curr.duration ? prev : curr
    );
    console.log(`\n🏆 RECOMMENDED: ${fastest.modelName} (fastest at ${fastest.duration}ms)`);
  }
  
  if (failed.length > 0) {
    console.log('\n❌ FAILED MODELS:');
    failed.forEach(r => {
      console.log(`  • ${r.modelName}`);
      console.log(`    Error: ${r.error}`);
    });
  }
  
  console.log('\n' + '='.repeat(60));
}

runTests().catch(console.error);
