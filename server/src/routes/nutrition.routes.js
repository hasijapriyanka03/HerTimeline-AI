const express = require('express');
const router = express.Router();
const nutritionEngine = require('../services/nutritionEngine');
const UserPregnancy = require('../models/userPregnancy.model');

// Get nutrition recommendations
router.get('/:userId/:week', (req, res) => {
  try {
    const profile = UserPregnancy.findByUserId(req.params.userId);
    
    if (!profile) {
      return res.status(404).json({ error: 'User profile not found' });
    }
    
    const recommendations = nutritionEngine.getRecommendations(
      parseInt(req.params.week),
      profile.allergies
    );
    
    res.json(recommendations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
