const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');

const checklistStatuses = new Map();

// Get checklist for a specific week
router.get('/:userId/:week', (req, res) => {
  try {
    const { userId, week } = req.params;
    const weekKey = `week_${week}`;
    
    // Load checklist templates
    const templatesPath = path.join(__dirname, '../data/checklist_templates.json');
    const templates = JSON.parse(fs.readFileSync(templatesPath, 'utf8'));
    
    if (!templates[weekKey]) {
      return res.json([]);
    }
    
    // Get user's completion status
    const userKey = `${userId}_${week}`;
    const completedTasks = checklistStatuses.get(userKey) || new Set();
    
    const checklist = templates[weekKey].map(task => ({
      user_id: userId,
      week: parseInt(week),
      task,
      completed: completedTasks.has(task),
    }));
    
    res.json(checklist);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update checklist task
router.post('/:userId/:week', (req, res) => {
  try {
    const { userId, week } = req.params;
    const { task, completed } = req.body;
    
    const userKey = `${userId}_${week}`;
    
    if (!checklistStatuses.has(userKey)) {
      checklistStatuses.set(userKey, new Set());
    }
    
    const completedTasks = checklistStatuses.get(userKey);
    
    if (completed) {
      completedTasks.add(task);
    } else {
      completedTasks.delete(task);
    }
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
