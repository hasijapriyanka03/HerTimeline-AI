const express = require('express');
const router = express.Router();
const DailyLog = require('../models/dailyLogs.model');
const db = require('../services/database');

// Get all logs for a user
router.get('/:userId', (req, res) => {
  try {
    const logs = DailyLog.findByUserId(req.params.userId);
    res.json(logs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add a daily log
router.post('/:userId', (req, res) => {
  try {
    const userId = req.params.userId;
    const log = DailyLog.create({
      ...req.body,
      user_id: userId,
    });
    
    // Check in for streak when log is created
    checkInStreak(userId, 'pregnancy');
    
    res.status(201).json(log);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Helper function to check in for streak
function checkInStreak(userId, category) {
  try {
    let streak = db.get('streaks')
      .find({ user_id: userId, category: category })
      .value();

    if (!streak) {
      // Create new streak
      streak = {
        streak_id: `streak_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        user_id: userId,
        category: category,
        current_streak: 1,
        longest_streak: 1,
        last_check_in_date: new Date().toISOString(),
        check_in_dates: [new Date().toISOString()],
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      db.get('streaks')
        .push(streak)
        .write();

      // Award points
      awardStreakPoints(userId, category, 1);
      return;
    }

    // Check if already checked in today
    const today = new Date().toDateString();
    const lastCheckIn = streak.last_check_in_date
      ? new Date(streak.last_check_in_date).toDateString()
      : null;

    if (lastCheckIn === today) {
      return; // Already checked in today
    }

    // Check if streak should continue or break
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toDateString();

    if (lastCheckIn === yesterdayStr) {
      // Streak continues
      streak.current_streak += 1;
    } else {
      // Streak broken - deduct points and reset
      deductStreakPenalty(userId, category, streak.current_streak);
      streak.current_streak = 1;
    }

    // Update longest streak
    if (streak.current_streak > streak.longest_streak) {
      streak.longest_streak = streak.current_streak;
    }

    // Add check-in date
    streak.last_check_in_date = new Date().toISOString();
    streak.check_in_dates.push(new Date().toISOString());
    streak.updated_at = new Date().toISOString();

    db.get('streaks')
      .find({ user_id: userId, category: category })
      .assign(streak)
      .write();

    // Award points
    awardStreakPoints(userId, category, streak.current_streak);
  } catch (error) {
    console.error('Error checking in streak:', error);
  }
}

// Helper function to award streak points
function awardStreakPoints(userId, category, streakDay) {
  try {
    let wallet = db.get('userWallets')
      .find({ user_id: userId })
      .value();

    if (!wallet) {
      wallet = {
        wallet_id: `wallet_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        user_id: userId,
        total_points: 0,
        points_history: [],
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      db.get('userWallets')
        .push(wallet)
        .write();
    }

    const transaction = {
      transaction_id: `txn_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      amount: 10,
      type: 'earned',
      reason: `Day ${streakDay} streak bonus`,
      category: category,
      date: new Date().toISOString(),
    };

    wallet.total_points += 10;
    wallet.points_history.push(transaction);
    wallet.updated_at = new Date().toISOString();

    db.get('userWallets')
      .find({ user_id: userId })
      .assign(wallet)
      .write();

    console.log(`✅ Awarded 10 points to ${userId} for ${category} streak day ${streakDay}`);
  } catch (error) {
    console.error('Error awarding points:', error);
  }
}

// Helper function to deduct streak penalty
function deductStreakPenalty(userId, category, streakDays) {
  try {
    let wallet = db.get('userWallets')
      .find({ user_id: userId })
      .value();

    if (!wallet) {
      return;
    }

    const transaction = {
      transaction_id: `txn_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      amount: 5,
      type: 'deducted',
      reason: `Streak broken after ${streakDays} days`,
      category: category,
      date: new Date().toISOString(),
    };

    wallet.total_points = Math.max(0, wallet.total_points - 5);
    wallet.points_history.push(transaction);
    wallet.updated_at = new Date().toISOString();

    db.get('userWallets')
      .find({ user_id: userId })
      .assign(wallet)
      .write();

    console.log(`⚠️ Deducted 5 points from ${userId} for broken ${category} streak`);
  } catch (error) {
    console.error('Error deducting penalty:', error);
  }
}

module.exports = router;
