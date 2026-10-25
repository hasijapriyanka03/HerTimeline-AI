const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

// Initialize database
const db = require('./services/database');
console.log('✅ Database initialized');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
const userRoutes = require('./routes/users.routes');
const userProfileRoutes = require('./routes/userProfile.routes');
const logsRoutes = require('./routes/logs.routes');
const aiRoutes = require('./routes/ai.routes');
const ollamaRoutes = require('./routes/ollama.routes');
const nutritionRoutes = require('./routes/nutrition.routes');
const checklistRoutes = require('./routes/checklist.routes');
const breathingRoutes = require('./routes/breathing.routes');
const menstruationRoutes = require('./routes/menstruation.routes');
const menopauseRoutes = require('./routes/menopause.routes');
const notificationRoutes = require('./routes/notifications.routes');
const appointmentsRoutes = require('./routes/appointments.routes');
const emergencyRoutes = require('./routes/emergency.routes');
const ocrRoutes = require('./routes/ocr.routes');
const audioEmotionRoutes = require('./routes/audioEmotion.routes');
const agoraConversationalAIRoutes = require('./routes/agoraConversationalAI.routes');
const walletRoutes = require('./routes/wallet.routes');
const streakRoutes = require('./routes/streak.routes');
const voucherRoutes = require('./routes/voucher.routes');
const pregnancyRoutes = require('./routes/pregnancy.routes');

app.use('/api/user', userRoutes);
app.use('/api/user', userProfileRoutes);
app.use('/api/logs', logsRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/ollama', ollamaRoutes);
app.use('/api/nutrition', nutritionRoutes);
app.use('/api/checklist', checklistRoutes);
app.use('/api/breathing', breathingRoutes);
app.use('/api/menstruation', menstruationRoutes);
app.use('/api/menopause', menopauseRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/appointments', appointmentsRoutes);
app.use('/api/emergency', emergencyRoutes);
app.use('/api/ocr', ocrRoutes);
app.use('/api/audio-emotion', audioEmotionRoutes);
app.use('/api/agora-ai', agoraConversationalAIRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/streak', streakRoutes);
app.use('/api/voucher', voucherRoutes);
app.use('/api/pregnancy', pregnancyRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Mensa Pregnancy Tracker API is running' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
});

module.exports = app;
