const express = require('express');
const router = express.Router();
const db = require('../services/database');

// Get streak for a category
router.get('/:userId/:category', (req, res) => {
  try {
    const { userId, category } = req.params;

    let streak = db.get('streaks')
      .find({ user_id: userId, category: category })
      .value();

    if (!streak) {
      // Create new streak if doesn't exist
      streak = {
        streak_id: `streak_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        user_id: userId,
        category: category,
        current_streak: 0,
        longest_streak: 0,
        last_check_in_date: null,
        check_in_dates: [],
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      db.get('streaks')
        .push(streak)
        .write();
    }

    res.json(streak);
  } catch (error) {
    console.error('Error fetching streak:', error);
    res.status(500).json({ error: error.message });
  }
});

// Check in for a category (daily)
router.post('/:userId/:category/check-in', (req, res) => {
  try {
    const { userId, category } = req.params;

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

      return res.json({
        success: true,
        message: 'Streak started! +10 points',
        streak: streak,
        points_awarded: 10,
      });
    }

    // Check if already checked in today
    const today = new Date().toDateString();
    const lastCheckIn = streak.last_check_in_date
      ? new Date(streak.last_check_in_date).toDateString()
      : null;

    if (lastCheckIn === today) {
      return res.status(400).json({
        error: 'Already checked in today',
        streak: streak,
      });
    }

    // Check if streak should continue or break
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toDateString();

    let pointsAwarded = 10;
    let streakContinues = false;

    if (lastCheckIn === yesterdayStr) {
      // Streak continues
      streak.current_streak += 1;
      streakContinues = true;
      pointsAwarded = 10;
    } else {
      // Streak broken - deduct points and reset
      deductStreakPenalty(userId, category, streak.current_streak);
      streak.current_streak = 1;
      pointsAwarded = 10;
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

    res.json({
      success: true,
      message: streakContinues
        ? `Streak continued! Day ${streak.current_streak} +10 points`
        : `Streak restarted! Day 1 +10 points`,
      streak: streak,
      points_awarded: pointsAwarded,
      streak_continues: streakContinues,
    });
  } catch (error) {
    console.error('Error checking in:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get all streaks for user
router.get('/:userId/all', (req, res) => {
  try {
    const { userId } = req.params;

    const streaks = db.get('streaks')
      .filter({ user_id: userId })
      .value();

    res.json({
      streaks: streaks || [],
    });
  } catch (error) {
    console.error('Error fetching streaks:', error);
    res.status(500).json({ error: error.message });
  }
});

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

// Get streak summary for user across all categories
router.get('/:userId/summary', (req, res) => {
  try {
    const { userId } = req.params;

    const streaks = db.get('streaks')
      .filter({ user_id: userId })
      .value();

    const summary = {
      total_active_streaks: 0,
      streaks_by_category: {},
      total_points_earned: 0,
    };

    if (streaks && streaks.length > 0) {
      streaks.forEach(streak => {
        if (streak.current_streak > 0) {
          summary.total_active_streaks += 1;
        }
        summary.streaks_by_category[streak.category] = {
          current_streak: streak.current_streak,
          longest_streak: streak.longest_streak,
          last_check_in: streak.last_check_in_date,
        };
      });
    }

    // Calculate total points earned from streaks
    const wallet = db.get('userWallets')
      .find({ user_id: userId })
      .value();

    if (wallet && wallet.points_history) {
      summary.total_points_earned = wallet.points_history
        .filter(t => t.type === 'earned')
        .reduce((sum, t) => sum + t.amount, 0);
    }

    res.json(summary);
  } catch (error) {
    console.error('Error fetching streak summary:', error);
    res.status(500).json({ error: error.message });
  }
});

// Validate and update streaks (called daily)
router.post('/:userId/validate', (req, res) => {
  try {
    const { userId } = req.params;

    const streaks = db.get('streaks')
      .filter({ user_id: userId })
      .value();

    const results = [];

    if (streaks && streaks.length > 0) {
      streaks.forEach(streak => {
        const today = new Date().toDateString();
        const lastCheckIn = streak.last_check_in_date
          ? new Date(streak.last_check_in_date).toDateString()
          : null;

        // If last check-in was not today and not yesterday, streak is broken
        if (lastCheckIn !== today) {
          const yesterday = new Date();
          yesterday.setDate(yesterday.getDate() - 1);
          const yesterdayStr = yesterday.toDateString();

          if (lastCheckIn !== yesterdayStr && streak.current_streak > 0) {
            // Streak broken - deduct penalty
            deductStreakPenalty(userId, streak.category, streak.current_streak);
            streak.current_streak = 0;
            streak.updated_at = new Date().toISOString();

            db.get('streaks')
              .find({ streak_id: streak.streak_id })
              .assign(streak)
              .write();

            results.push({
              category: streak.category,
              status: 'broken',
              message: `${streak.category} streak broken after ${streak.longest_streak} days`,
            });
          }
        }
      });
    }

    res.json({
      success: true,
      message: 'Streaks validated',
      results: results,
    });
  } catch (error) {
    console.error('Error validating streaks:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
