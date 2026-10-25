const express = require('express');
const router = express.Router();
const UserPregnancy = require('../models/userPregnancy.model');

// Get pregnancy profile
router.get('/:userId/pregnancy', (req, res) => {
  try {
    const profile = UserPregnancy.findByUserId(req.params.userId);
    
    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }
    
    res.json(profile);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create or update pregnancy profile
router.post('/:userId/pregnancy', (req, res) => {
  try {
    const existing = UserPregnancy.findByUserId(req.params.userId);
    
    let profile;
    if (existing) {
      profile = UserPregnancy.update(req.params.userId, req.body);
    } else {
      profile = UserPregnancy.create({
        ...req.body,
        user_id: req.params.userId,
      });
    }
    
    res.status(existing ? 200 : 201).json(profile);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
