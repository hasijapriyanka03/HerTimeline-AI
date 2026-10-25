const mongoose = require('mongoose');

const cycleDataSchema = new mongoose.Schema({
  user_id: {
    type: String,
    required: true,
    unique: true,
    index: true,
  },
  average_cycle_length: {
    type: Number,
    default: 28,
  },
  last_period_start: {
    type: Date,
  },
  predicted_next_period: {
    type: Date,
  },
  cycle_regularity: {
    type: Number,
    default: 0,
    min: 0,
    max: 100,
  },
  updated_at: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('CycleData', cycleDataSchema);
