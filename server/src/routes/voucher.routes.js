const express = require('express');
const router = express.Router();
const db = require('../services/database');

// Get all available vouchers
router.get('/available', (req, res) => {
  try {
    const vouchers = db.get('vouchers')
      .filter(v => v.is_active && (!v.validity_end || new Date(v.validity_end) > new Date()))
      .value();

    res.json({
      vouchers: vouchers || [],
    });
  } catch (error) {
    console.error('Error fetching vouchers:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get user's purchased vouchers
router.get('/:userId/my-vouchers', (req, res) => {
  try {
    const { userId } = req.params;

    const userVouchers = db.get('userVouchers')
      .filter({ user_id: userId })
      .value();

    res.json({
      vouchers: userVouchers || [],
    });
  } catch (error) {
    console.error('Error fetching user vouchers:', error);
    res.status(500).json({ error: error.message });
  }
});

// Purchase a voucher
router.post('/:userId/purchase', (req, res) => {
  try {
    const { userId } = req.params;
    const { voucher_id } = req.body;

    if (!voucher_id) {
      return res.status(400).json({ error: 'Voucher ID required' });
    }

    // Get voucher
    const voucher = db.get('vouchers')
      .find({ voucher_id: voucher_id })
      .value();

    if (!voucher) {
      return res.status(404).json({ error: 'Voucher not found' });
    }

    if (!voucher.is_active) {
      return res.status(400).json({ error: 'Voucher is not active' });
    }

    if (voucher.validity_end && new Date(voucher.validity_end) < new Date()) {
      return res.status(400).json({ error: 'Voucher has expired' });
    }

    if (voucher.max_redemptions !== -1 && voucher.current_redemptions >= voucher.max_redemptions) {
      return res.status(400).json({ error: 'Voucher redemption limit reached' });
    }

    // Get user wallet
    let wallet = db.get('userWallets')
      .find({ user_id: userId })
      .value();

    if (!wallet) {
      return res.status(404).json({ error: 'Wallet not found' });
    }

    if (wallet.total_points < voucher.points_required) {
      return res.status(400).json({
        error: 'Insufficient points',
        required: voucher.points_required,
        available: wallet.total_points,
      });
    }

    // Deduct points
    wallet.total_points -= voucher.points_required;
    const transaction = {
      transaction_id: `txn_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      amount: voucher.points_required,
      type: 'redeemed',
      reason: `Purchased voucher: ${voucher.title}`,
      category: 'voucher',
      date: new Date().toISOString(),
    };
    wallet.points_history.push(transaction);
    wallet.updated_at = new Date().toISOString();

    db.get('userWallets')
      .find({ user_id: userId })
      .assign(wallet)
      .write();

    // Create user voucher
    const userVoucher = {
      user_voucher_id: `uv_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      user_id: userId,
      voucher_id: voucher_id,
      voucher_code: voucher.code,
      status: 'active',
      purchased_at: new Date().toISOString(),
      expires_at: voucher.validity_end || new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    db.get('userVouchers')
      .push(userVoucher)
      .write();

    // Update voucher redemption count
    voucher.current_redemptions += 1;
    db.get('vouchers')
      .find({ voucher_id: voucher_id })
      .assign(voucher)
      .write();

    res.json({
      success: true,
      message: `Successfully purchased ${voucher.title}`,
      user_voucher: userVoucher,
      remaining_points: wallet.total_points,
    });
  } catch (error) {
    console.error('Error purchasing voucher:', error);
    res.status(500).json({ error: error.message });
  }
});

// Redeem a voucher
router.post('/:userId/redeem/:userVoucherId', (req, res) => {
  try {
    const { userId, userVoucherId } = req.params;

    const userVoucher = db.get('userVouchers')
      .find({ user_voucher_id: userVoucherId, user_id: userId })
      .value();

    if (!userVoucher) {
      return res.status(404).json({ error: 'Voucher not found' });
    }

    if (userVoucher.status === 'redeemed') {
      return res.status(400).json({ error: 'Voucher already redeemed' });
    }

    if (userVoucher.status === 'expired') {
      return res.status(400).json({ error: 'Voucher has expired' });
    }

    if (userVoucher.expires_at && new Date(userVoucher.expires_at) < new Date()) {
      userVoucher.status = 'expired';
      db.get('userVouchers')
        .find({ user_voucher_id: userVoucherId })
        .assign(userVoucher)
        .write();
      return res.status(400).json({ error: 'Voucher has expired' });
    }

    // Mark as redeemed
    userVoucher.status = 'redeemed';
    userVoucher.redeemed_at = new Date().toISOString();
    userVoucher.updated_at = new Date().toISOString();

    db.get('userVouchers')
      .find({ user_voucher_id: userVoucherId })
      .assign(userVoucher)
      .write();

    res.json({
      success: true,
      message: 'Voucher redeemed successfully',
      user_voucher: userVoucher,
    });
  } catch (error) {
    console.error('Error redeeming voucher:', error);
    res.status(500).json({ error: error.message });
  }
});

// Create a new voucher (admin)
router.post('/admin/create', (req, res) => {
  try {
    const {
      code,
      title,
      description,
      points_required,
      discount_percentage,
      discount_amount,
      category,
      validity_end,
      max_redemptions,
    } = req.body;

    if (!code || !title || !points_required) {
      return res.status(400).json({
        error: 'Code, title, and points_required are required',
      });
    }

    const voucher = {
      voucher_id: `voucher_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      code: code,
      title: title,
      description: description || '',
      points_required: points_required,
      discount_percentage: discount_percentage || 0,
      discount_amount: discount_amount || 0,
      category: category || 'other',
      validity_start: new Date().toISOString(),
      validity_end: validity_end || null,
      is_active: true,
      max_redemptions: max_redemptions || -1,
      current_redemptions: 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    db.get('vouchers')
      .push(voucher)
      .write();

    res.status(201).json({
      success: true,
      message: 'Voucher created successfully',
      voucher: voucher,
    });
  } catch (error) {
    console.error('Error creating voucher:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
