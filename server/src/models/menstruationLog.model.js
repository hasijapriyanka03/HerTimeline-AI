const mongoose = require('mongoose');

const menstruationLogSchema = new mongoose.Schema({
  log_id: {
    type: String,
    required: true,
    unique: true,
  },
  user_id: {
    type: String,
    required: true,
    index: true,
  },
  date: {
    type: Date,
    required: true,
  },
  cycle_day: {
    type: Number,
    required: true,
  },
  flow_level: {
    type: String,
    enum: ['None', 'Spotting', 'Light', 'Medium', 'Heavy'],
    required: true,
  },
  mood: {
    type: String,
    required: true,
  },
  symptoms: [{
    type: String,
  }],
  notes: {
    type: String,
    default: '',
  },
  created_at: {
    type: Date,
    default: Date.now,
  },
});

// Index for efficient queries
menstruationLogSchema.index({ user_id: 1, date: -1 });

module.exports = mongoose.model('MenstruationLog', menstruationLogSchema);
