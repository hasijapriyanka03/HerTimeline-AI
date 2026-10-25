const mongoose = require('mongoose');

const userWalletSchema = new mongoose.Schema({
  user_id: {
    type: String,
    required: true,
    unique: true,
    index: true,
  },
  total_points: {
    type: Number,
    default: 0,
    min: 0,
  },
  points_history: [{
    transaction_id: String,
    amount: Number,
    type: {
      type: String,
      enum: ['earned', 'deducted', 'redeemed'],
    },
    reason: String,
    category: {
      type: String,
      enum: ['menstruation', 'menopause', 'pregnancy'],
    },
    date: {
      type: Date,
      default: Date.now,
    },
  }],
  created_at: {
    type: Date,
    default: Date.now,
  },
  updated_at: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('UserWallet', userWalletSchema);
