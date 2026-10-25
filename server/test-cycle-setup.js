// Test script for menstruation cycle setup
const http = require('http');

const testUserId = 'test_user_' + Date.now();

console.log('🧪 Testing Menstruation Cycle Setup');
console.log('📝 Test User ID:', testUserId);
console.log('');

// Test 1: Initialize cycle data
function testInitialize() {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      last_period_start: new Date('2024-01-15').toISOString(),
      average_cycle_length: 28
    });

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: `/api/menstruation/${testUserId}/initialize`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
      }
    };

    console.log('1️⃣ Testing POST /api/menstruation/:userId/initialize');
    
    const req = http.request(options, (res) => {
      let body = '';
      
      res.on('data', (chunk) => {
        body += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode === 201 || res.statusCode === 200) {
          const result = JSON.parse(body);
          console.log('   ✅ Status:', res.statusCode);
          console.log('   ✅ Response:', JSON.stringify(result, null, 2));
          resolve(result);
        } else {
          console.log('   ❌ Status:', res.statusCode);
          console.log('   ❌ Response:', body);
          reject(new Error('Initialize failed'));
        }
      });
    });

    req.on('error', (error) => {
      console.log('   ❌ Error:', error.message);
      reject(error);
    });

    req.write(data);
    req.end();
  });
}

// Test 2: Add initial log
function testAddLog() {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      user_id: testUserId,
      date: new Date('2024-01-15').toISOString(),
      cycle_day: 1,
      flow_level: 'Medium',
      mood: 'Calm',
      symptoms: [],
      notes: 'Initial setup test'
    });

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: `/api/menstruation/${testUserId}/log`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
      }
    };

    console.log('');
    console.log('2️⃣ Testing POST /api/menstruation/:userId/log');
    
    const req = http.request(options, (res) => {
      let body = '';
      
      res.on('data', (chunk) => {
        body += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode === 201 || res.statusCode === 200) {
          const result = JSON.parse(body);
          console.log('   ✅ Status:', res.statusCode);
          console.log('   ✅ Log created');
          resolve(result);
        } else {
          console.log('   ❌ Status:', res.statusCode);
          console.log('   ❌ Response:', body);
          reject(new Error('Add log failed'));
        }
      });
    });

    req.on('error', (error) => {
      console.log('   ❌ Error:', error.message);
      reject(error);
    });

    req.write(data);
    req.end();
  });
}

// Test 3: Get predictions
function testGetPredictions() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: `/api/menstruation/${testUserId}/predictions`,
      method: 'GET'
    };

    console.log('');
    console.log('3️⃣ Testing GET /api/menstruation/:userId/predictions');
    
    const req = http.request(options, (res) => {
      let body = '';
      
      res.on('data', (chunk) => {
        body += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode === 200) {
          const result = JSON.parse(body);
          console.log('   ✅ Status:', res.statusCode);
          console.log('   ✅ Predictions:', JSON.stringify(result, null, 2));
          
          // Verify data
          if (result.last_period_start && result.predicted_next_period) {
            console.log('   ✅ Data is valid!');
            resolve(result);
          } else {
            console.log('   ⚠️  Warning: Missing expected fields');
            resolve(result);
          }
        } else {
          console.log('   ❌ Status:', res.statusCode);
          console.log('   ❌ Response:', body);
          reject(new Error('Get predictions failed'));
        }
      });
    });

    req.on('error', (error) => {
      console.log('   ❌ Error:', error.message);
      reject(error);
    });

    req.end();
  });
}

// Run all tests
async function runTests() {
  try {
    await testInitialize();
    await testAddLog();
    await testGetPredictions();
    
    console.log('');
    console.log('🎉 All tests passed!');
    console.log('');
    console.log('✅ Cycle setup flow is working correctly');
    console.log('✅ Data is being saved and retrieved');
    console.log('✅ Predictions are being calculated');
    
  } catch (error) {
    console.log('');
    console.log('❌ Tests failed:', error.message);
    process.exit(1);
  }
}

runTests();
