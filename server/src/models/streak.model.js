const mongoose = require('mongoose');

const streakSchema = new mongoose.Schema({
  streak_id: {
    type: String,
    required: true,
    unique: true,
  },
  user_id: {
    type: String,
    required: true,
    index: true,
  },
  category: {
    type: String,
    enum: ['menstruation', 'menopause', 'pregnancy'],
    required: true,
  },
  current_streak: {
    type: Number,
    default: 0,
    min: 0,
  },
  longest_streak: {
    type: Number,
    default: 0,
    min: 0,
  },
  last_check_in_date: {
    type: Date,
  },
  check_in_dates: [
    {
      type: Date,
    },
  ],
  created_at: {
    type: Date,
    default: Date.now,
  },
  updated_at: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Streak', streakSchema);
