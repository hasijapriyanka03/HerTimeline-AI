const express = require('express');
const router = express.Router();

const breathingSessions = new Map();

// Get breathing game stats
router.get('/game/:userId', (req, res) => {
  try {
    const sessions = breathingSessions.get(req.params.userId) || [];
    
    const stats = {
      totalSessions: sessions.length,
      totalDuration: sessions.reduce((sum, s) => sum + s.duration, 0),
      completedSessions: sessions.filter(s => s.completed).length,
      lastSession: sessions.length > 0 ? sessions[sessions.length - 1] : null,
    };
    
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update breathing game session
router.post('/game/:userId', (req, res) => {
  try {
    const { duration, completed, timestamp } = req.body;
    
    if (!breathingSessions.has(req.params.userId)) {
      breathingSessions.set(req.params.userId, []);
    }
    
    breathingSessions.get(req.params.userId).push({
      duration,
      completed,
      timestamp: timestamp || new Date().toISOString(),
    });
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
