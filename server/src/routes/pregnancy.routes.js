const express = require('express');
const router = express.Router();
const db = require('../services/database');

// Add or update pregnancy log (upsert)
router.post('/:userId/log', (req, res) => {
  try {
    const { userId } = req.params;
    const { date } = req.body;
    
    // Normalize date to start of day
    const logDate = new Date(date);
    const normalizedDate = new Date(logDate.getFullYear(), logDate.getMonth(), logDate.getDate()).toISOString();
    
    // Check if log exists for this date
    const existingLogIndex = db.get('pregnancyLogs')
      .findIndex(log => log.user_id === userId && log.date === normalizedDate)
      .value();

    const logData = {
      ...req.body,
      user_id: userId,
      date: normalizedDate,
      updated_at: new Date().toISOString(),
    };

    if (existingLogIndex >= 0) {
      // Update existing log
      db.get('pregnancyLogs')
        .nth(existingLogIndex)
        .assign(logData)
        .write();
      
      res.json({ success: true, message: 'Log updated successfully' });
    } else {
      // Create new log
      logData.created_at = new Date().toISOString();
      
      db.get('pregnancyLogs')
        .push(logData)
        .write();

      // Check in for streak
      checkInStreak(userId, 'pregnancy');

      res.json({ success: true, message: 'Log saved successfully' });
    }
  } catch (error) {
    console.error('Error saving pregnancy log:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get pregnancy logs
router.get('/:userId/logs', (req, res) => {
  try {
    const { userId } = req.params;
    
    const logs = db.get('pregnancyLogs')
      .filter({ user_id: userId })
      .sortBy('date')
      .reverse()
      .value();

    res.json(logs);
  } catch (error) {
    console.error('Error fetching pregnancy logs:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get pregnancy profile
router.get('/:userId/profile', (req, res) => {
  try {
    const { userId } = req.params;

    const profile = db.get('pregnancyProfiles')
      .find({ user_id: userId })
      .value();

    if (!profile) {
      return res.status(404).json({ error: 'Pregnancy profile not found' });
    }

    res.json(profile);
  } catch (error) {
    console.error('Error fetching pregnancy profile:', error);
    res.status(500).json({ error: error.message });
  }
});

// Create or update pregnancy profile
router.post('/:userId/profile', (req, res) => {
  try {
    const { userId } = req.params;
    const { lmp_date, due_date, allergies, preferences } = req.body;

    let profile = db.get('pregnancyProfiles')
      .find({ user_id: userId })
      .value();

    if (profile) {
      // Update existing
      profile = {
        ...profile,
        lmp_date: lmp_date || profile.lmp_date,
        due_date: due_date || profile.due_date,
        allergies: allergies || profile.allergies,
        preferences: preferences || profile.preferences,
        updated_at: new Date().toISOString(),
      };

      db.get('pregnancyProfiles')
        .find({ user_id: userId })
        .assign(profile)
        .write();
    } else {
      // Create new
      profile = {
        pregnancy_id: `preg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        user_id: userId,
        lmp_date: lmp_date,
        due_date: due_date,
        allergies: allergies || [],
        preferences: preferences || [],
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      db.get('pregnancyProfiles')
        .push(profile)
        .write();
    }

    res.json({
      success: true,
      message: 'Pregnancy profile saved successfully',
      profile: profile,
    });
  } catch (error) {
    console.error('Error saving pregnancy profile:', error);
    res.status(500).json({ error: error.message });
  }
});

// Generate pregnancy report
router.post('/:userId/generate-report', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const logs = db.get('pregnancyLogs')
      .filter({ user_id: userId })
      .sortBy('date')
      .reverse()
      .take(30) // Last 30 days
      .value();

    if (logs.length === 0) {
      return res.json({
        summary: 'Start tracking your pregnancy to get personalized insights!',
        recommendations: [],
      });
    }

    // Count symptom frequency
    const symptomCounts = {};
    logs.forEach(log => {
      if (log.symptoms) {
        log.symptoms.forEach(symptom => {
          symptomCounts[symptom] = (symptomCounts[symptom] || 0) + 1;
        });
      }
    });

    const topSymptoms = Object.entries(symptomCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([symptom]) => symptom);

    // Generate summary
    let summary = `Based on ${logs.length} days of tracking:\n\n`;
    
    if (topSymptoms.length > 0) {
      summary += `• Most common symptoms: ${topSymptoms.join(', ')}\n\n`;
    }

    summary += 'Keep tracking to see more personalized insights!';

    res.json({
      summary,
      statistics: {
        totalDays: logs.length,
        topSymptoms,
      },
      recommendations: [
        'Stay hydrated and eat nutritious meals',
        'Get regular prenatal checkups',
        'Practice gentle exercise like walking',
        'Get adequate rest and sleep',
        'Manage stress with relaxation techniques',
      ],
    });
  } catch (error) {
    console.error('Error generating pregnancy report:', error);
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
