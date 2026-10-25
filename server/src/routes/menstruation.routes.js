const express = require('express');
const router = express.Router();
const db = require('../services/database');

// Add or update menstruation log (upsert)
router.post('/:userId/log', (req, res) => {
  try {
    const { userId } = req.params;
    const { date } = req.body;
    
    // Normalize date to start of day
    const logDate = new Date(date);
    const normalizedDate = new Date(logDate.getFullYear(), logDate.getMonth(), logDate.getDate()).toISOString();
    
    // Check if log exists for this date
    const existingLogIndex = db.get('menstruationLogs')
      .findIndex(log => log.user_id === userId && log.date === normalizedDate)
      .value();

    let isNewLog = false;
    if (existingLogIndex >= 0) {
      // Update existing log
      const existingLog = db.get('menstruationLogs').nth(existingLogIndex).value();
      
      const updatedLog = {
        ...existingLog,
        ...req.body,
        date: normalizedDate,
        updated_at: new Date().toISOString(),
      };
      
      db.get('menstruationLogs')
        .nth(existingLogIndex)
        .assign(updatedLog)
        .write();
      
      // Update cycle data
      updateCycleData(userId);
      
      res.json(updatedLog);
    } else {
      // Create new log
      const log = {
        log_id: `log_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        user_id: userId,
        ...req.body,
        date: normalizedDate,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      db.get('menstruationLogs')
        .push(log)
        .write();
      
      // Update cycle data
      updateCycleData(userId);
      
      // Check in for streak
      checkInStreak(userId, 'menstruation');

      isNewLog = true;
      res.status(201).json(log);
    }
  } catch (error) {
    console.error('Error adding/updating log:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get menstruation logs
router.get('/:userId/logs', (req, res) => {
  try {
    const logs = db.get('menstruationLogs')
      .filter({ user_id: req.params.userId })
      .sortBy('date')
      .reverse()
      .value();
    
    res.json(logs);
  } catch (error) {
    console.error('Error fetching logs:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get predictions
router.get('/:userId/predictions', (req, res) => {
  try {
    const data = db.get('cycleData')
      .find({ user_id: req.params.userId })
      .value();
    
    if (!data) {
      return res.json({
        predicted_next_period: null,
        average_cycle_length: 28,
        cycle_regularity: 0,
        last_period_start: null,
      });
    }

    res.json(data);
  } catch (error) {
    console.error('Error fetching predictions:', error);
    res.status(500).json({ error: error.message });
  }
});

// Initialize cycle data (for setup)
router.post('/:userId/initialize', (req, res) => {
  try {
    const { userId } = req.params;
    const { last_period_start, average_cycle_length } = req.body;
    
    console.log('🔵 Initialize cycle request:', { userId, last_period_start, average_cycle_length });
    
    if (!last_period_start || !average_cycle_length) {
      console.log('❌ Missing required fields');
      return res.status(400).json({ 
        error: 'last_period_start and average_cycle_length are required' 
      });
    }

    const lastPeriod = new Date(last_period_start);
    const nextPeriod = new Date(lastPeriod);
    nextPeriod.setDate(nextPeriod.getDate() + average_cycle_length);

    const cycleData = {
      user_id: userId,
      average_cycle_length: average_cycle_length,
      last_period_start: lastPeriod.toISOString(),
      predicted_next_period: nextPeriod.toISOString(),
      cycle_regularity: 0, // Will improve as more data is logged
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    console.log('📊 Cycle data to save:', cycleData);

    // Check if cycle data already exists
    const existing = db.get('cycleData')
      .find({ user_id: userId })
      .value();

    if (existing) {
      console.log('🔄 Updating existing cycle data');
      // Update existing
      db.get('cycleData')
        .find({ user_id: userId })
        .assign(cycleData)
        .write();
    } else {
      console.log('✨ Creating new cycle data');
      // Create new
      db.get('cycleData')
        .push(cycleData)
        .write();
    }

    console.log('✅ Cycle data initialized successfully');
    res.status(201).json(cycleData);
  } catch (error) {
    console.error('❌ Error initializing cycle data:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get statistics
router.get('/:userId/stats', (req, res) => {
  try {
    const logs = db.get('menstruationLogs')
      .filter({ user_id: req.params.userId })
      .sortBy('date')
      .reverse()
      .value();
    
    if (logs.length === 0) {
      return res.json({
        total_logs: 0,
        common_symptoms: [],
        mood_patterns: {},
        flow_patterns: {},
        insights: [],
      });
    }

    // Calculate statistics
    const symptoms = {};
    const moods = {};
    const flows = {};

    logs.forEach(log => {
      // Count symptoms
      log.symptoms?.forEach(symptom => {
        symptoms[symptom] = (symptoms[symptom] || 0) + 1;
      });

      // Count moods
      moods[log.mood] = (moods[log.mood] || 0) + 1;

      // Count flow levels
      flows[log.flow_level] = (flows[log.flow_level] || 0) + 1;
    });

    // Get top symptoms
    const commonSymptoms = Object.entries(symptoms)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([symptom, count]) => ({
        symptom,
        count,
        percentage: Math.round((count / logs.length) * 100),
      }));

    res.json({
      total_logs: logs.length,
      common_symptoms: commonSymptoms,
      mood_patterns: moods,
      flow_patterns: flows,
      insights: generateInsights(req.params.userId, logs, commonSymptoms),
    });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ error: error.message });
  }
});

// Helper function to update cycle data
function updateCycleData(userId) {
  try {
    const logs = db.get('menstruationLogs')
      .filter({ user_id: userId })
      .sortBy('date')
      .reverse()
      .value();
  
    if (logs.length < 2) return;

    // Find period start dates (when flow changes from None to any flow)
    const periodStarts = [];
    for (let i = 0; i < logs.length - 1; i++) {
      const current = logs[i];
      const previous = logs[i + 1];
      
      if (current.flow_level !== 'None' && 
          (previous.flow_level === 'None' || i === logs.length - 2)) {
        periodStarts.push(new Date(current.date));
      }
    }

    if (periodStarts.length >= 2) {
      // Calculate average cycle length
      const cycleLengths = [];
      for (let i = 0; i < periodStarts.length - 1; i++) {
        const diff = Math.abs(periodStarts[i] - periodStarts[i + 1]);
        const days = Math.ceil(diff / (1000 * 60 * 60 * 24));
        cycleLengths.push(days);
      }

      const avgLength = Math.round(
        cycleLengths.reduce((a, b) => a + b, 0) / cycleLengths.length
      );

      // Calculate regularity (how consistent the cycles are)
      const variance = cycleLengths.reduce((sum, length) => {
        return sum + Math.pow(length - avgLength, 2);
      }, 0) / cycleLengths.length;
      
      const regularity = Math.max(0, 100 - (variance * 5));

      // Predict next period
      const lastPeriod = periodStarts[0];
      const nextPeriod = new Date(lastPeriod);
      nextPeriod.setDate(nextPeriod.getDate() + avgLength);

      const cycleData = {
        user_id: userId,
        average_cycle_length: avgLength,
        last_period_start: lastPeriod.toISOString(),
        predicted_next_period: nextPeriod.toISOString(),
        cycle_regularity: Math.round(regularity),
        updated_at: new Date().toISOString(),
      };

      // Update or create cycle data
      const existing = db.get('cycleData')
        .find({ user_id: userId })
        .value();

      if (existing) {
        db.get('cycleData')
          .find({ user_id: userId })
          .assign(cycleData)
          .write();
      } else {
        db.get('cycleData')
          .push(cycleData)
          .write();
      }
    }
  } catch (error) {
    console.error('Error updating cycle data:', error);
  }
}

// Helper function to generate AI insights
function generateInsights(userId, logs, commonSymptoms) {
  const insights = [];

  try {
    // Cycle regularity insight
    const data = db.get('cycleData')
      .find({ user_id: userId })
      .value();
      
    if (data) {
      if (data.cycle_regularity >= 90) {
        insights.push({
          type: 'positive',
          title: 'Regular Cycle',
          message: `Your cycle has been very regular with an average length of ${data.average_cycle_length} days. This is a good sign of hormonal balance.`,
        });
      } else if (data.cycle_regularity < 70) {
        insights.push({
          type: 'warning',
          title: 'Irregular Cycle',
          message: 'Your cycle shows some irregularity. Consider tracking for a few more months. If it persists, consult your healthcare provider.',
        });
      } else {
        insights.push({
          type: 'info',
          title: 'Cycle Pattern',
          message: `Your cycle has an average length of ${data.average_cycle_length} days with ${data.cycle_regularity}% regularity.`,
        });
      }
    }

    // Symptom insights
    if (commonSymptoms.length > 0) {
      const topSymptom = commonSymptoms[0];
      insights.push({
        type: 'info',
        title: 'Common Symptoms',
        message: `You most frequently experience ${topSymptom.symptom.toLowerCase()} (${topSymptom.percentage}% of logged days). This is common during menstruation.`,
      });
    }

    // Recommendations
    insights.push({
      type: 'recommendation',
      title: 'Health Tips',
      message: '• Stay hydrated during your period\n• Light exercise can help with cramps\n• Iron-rich foods can help prevent fatigue\n• Track symptoms for better predictions',
    });
  } catch (error) {
    console.error('Error generating insights:', error);
  }

  return insights;
}

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
