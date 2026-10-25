const mongoose = require('mongoose');

const userVoucherSchema = new mongoose.Schema({
  user_voucher_id: {
    type: String,
    required: true,
    unique: true,
  },
  user_id: {
    type: String,
    required: true,
    index: true,
  },
  voucher_id: {
    type: String,
    required: true,
  },
  voucher_code: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    enum: ['active', 'redeemed', 'expired'],
    default: 'active',
  },
  purchased_at: {
    type: Date,
    default: Date.now,
  },
  redeemed_at: {
    type: Date,
  },
  expires_at: {
    type: Date,
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

module.exports = mongoose.model('UserVoucher', userVoucherSchema);
