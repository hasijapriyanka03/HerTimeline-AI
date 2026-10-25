const mongoose = require('mongoose');

const voucherSchema = new mongoose.Schema({
  voucher_id: {
    type: String,
    required: true,
    unique: true,
  },
  code: {
    type: String,
    required: true,
    unique: true,
  },
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  points_required: {
    type: Number,
    required: true,
    min: 0,
  },
  discount_percentage: {
    type: Number,
    default: 0,
    min: 0,
    max: 100,
  },
  discount_amount: {
    type: Number,
    default: 0,
    min: 0,
  },
  category: {
    type: String,
    enum: ['health', 'wellness', 'nutrition', 'fitness', 'mental_health', 'other'],
    default: 'other',
  },
  validity_start: {
    type: Date,
    default: Date.now,
  },
  validity_end: {
    type: Date,
  },
  is_active: {
    type: Boolean,
    default: true,
  },
  max_redemptions: {
    type: Number,
    default: -1, // -1 means unlimited
  },
  current_redemptions: {
    type: Number,
    default: 0,
  },
  created_at: {
    type: Date,
    default: Date.now,
  },
  updated_at: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Voucher', voucherSchema);
