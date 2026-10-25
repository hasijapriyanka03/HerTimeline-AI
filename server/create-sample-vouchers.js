const axios = require('axios');

const API_URL = 'http://localhost:3000/api';

const sampleVouchers = [
  {
    code: 'HEALTH_10',
    title: '10% Health Store Discount',
    description: 'Get 10% off on health and wellness products',
    points_required: 100,
    discount_percentage: 10,
    discount_amount: 0,
    category: 'health',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 50,
  },
  {
    code: 'WELLNESS_YOGA',
    title: 'Free Yoga Class',
    description: 'Redeem for a free 60-minute yoga session',
    points_required: 150,
    discount_percentage: 0,
    discount_amount: 50,
    category: 'wellness',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 100,
  },
  {
    code: 'NUTRITION_MEAL',
    title: 'Nutrition Consultation',
    description: 'Free 30-minute consultation with a nutritionist',
    points_required: 200,
    discount_percentage: 0,
    discount_amount: 100,
    category: 'nutrition',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 30,
  },
  {
    code: 'FITNESS_MONTH',
    title: '1 Month Gym Membership',
    description: 'Free 1-month access to premium gym facilities',
    points_required: 250,
    discount_percentage: 0,
    discount_amount: 150,
    category: 'fitness',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 25,
  },
  {
    code: 'MENTAL_THERAPY',
    title: 'Mental Health Session',
    description: 'Free 45-minute therapy session with a counselor',
    points_required: 180,
    discount_percentage: 0,
    discount_amount: 80,
    category: 'mental_health',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 40,
  },
  {
    code: 'ORGANIC_BOX',
    title: 'Organic Produce Box',
    description: 'Get a box of fresh organic vegetables and fruits',
    points_required: 120,
    discount_percentage: 15,
    discount_amount: 0,
    category: 'health',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 60,
  },
  {
    code: 'MEDITATION_APP',
    title: '3 Months Premium Meditation App',
    description: 'Access to premium meditation and mindfulness content',
    points_required: 140,
    discount_percentage: 0,
    discount_amount: 60,
    category: 'mental_health',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 75,
  },
  {
    code: 'VITAMIN_PACK',
    title: 'Premium Vitamin Pack',
    description: 'Monthly supply of essential vitamins and supplements',
    points_required: 130,
    discount_percentage: 20,
    discount_amount: 0,
    category: 'health',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 80,
  },
  {
    code: 'SPA_MASSAGE',
    title: 'Spa Massage Session',
    description: 'Relaxing 60-minute full body massage at premium spa',
    points_required: 170,
    discount_percentage: 0,
    discount_amount: 90,
    category: 'wellness',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 35,
  },
  {
    code: 'COOKING_CLASS',
    title: 'Healthy Cooking Class',
    description: 'Learn to cook healthy meals with a professional chef',
    points_required: 160,
    discount_percentage: 0,
    discount_amount: 75,
    category: 'nutrition',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 45,
  },
  {
    code: 'PILATES_CLASS',
    title: '5 Pilates Classes',
    description: 'Five sessions of professional pilates training',
    points_required: 110,
    discount_percentage: 25,
    discount_amount: 0,
    category: 'fitness',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 55,
  },
  {
    code: 'SLEEP_TRACKER',
    title: 'Smart Sleep Tracker Device',
    description: 'Advanced wearable device to track your sleep patterns',
    points_required: 220,
    discount_percentage: 0,
    discount_amount: 120,
    category: 'health',
    validity_end: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
    max_redemptions: 20,
  },
];

async function createVouchers() {
  console.log('🎁 Creating sample vouchers...\n');

  for (const voucher of sampleVouchers) {
    try {
      const response = await axios.post(`${API_URL}/voucher/admin/create`, voucher);
      
      if (response.data.success) {
        console.log(`✅ Created: ${voucher.title}`);
        console.log(`   Code: ${voucher.code}`);
        console.log(`   Points Required: ${voucher.points_required}`);
        console.log(`   Category: ${voucher.category}\n`);
      }
    } catch (error) {
      console.error(`❌ Failed to create ${voucher.title}:`, error.response?.data?.error || error.message);
    }
  }

  console.log('✨ Sample vouchers creation complete!');
}

createVouchers();
