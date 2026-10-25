const express = require('express');
const router = express.Router();
const db = require('../services/database');

// Get user wallet
router.get('/:userId', (req, res) => {
  try {
    const { userId } = req.params;

    let wallet = db.get('userWallets')
      .find({ user_id: userId })
      .value();

    if (!wallet) {
      // Create new wallet if doesn't exist
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

    res.json(wallet);
  } catch (error) {
    console.error('Error fetching wallet:', error);
    res.status(500).json({ error: error.message });
  }
});

// Add points to wallet
router.post('/:userId/add-points', (req, res) => {
  try {
    const { userId } = req.params;
    const { amount, reason, category } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Invalid amount' });
    }

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

    // Add transaction
    const transaction = {
      transaction_id: `txn_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      amount: amount,
      type: 'earned',
      reason: reason || 'Daily streak bonus',
      category: category || 'general',
      date: new Date().toISOString(),
    };

    wallet.total_points += amount;
    wallet.points_history.push(transaction);
    wallet.updated_at = new Date().toISOString();

    db.get('userWallets')
      .find({ user_id: userId })
      .assign(wallet)
      .write();

    res.json({
      success: true,
      message: `Added ${amount} points`,
      wallet: wallet,
    });
  } catch (error) {
    console.error('Error adding points:', error);
    res.status(500).json({ error: error.message });
  }
});

// Deduct points from wallet
router.post('/:userId/deduct-points', (req, res) => {
  try {
    const { userId } = req.params;
    const { amount, reason, category } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Invalid amount' });
    }

    let wallet = db.get('userWallets')
      .find({ user_id: userId })
      .value();

    if (!wallet) {
      return res.status(404).json({ error: 'Wallet not found' });
    }

    if (wallet.total_points < amount) {
      return res.status(400).json({ error: 'Insufficient points' });
    }

    // Add transaction
    const transaction = {
      transaction_id: `txn_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      amount: amount,
      type: 'deducted',
      reason: reason || 'Streak broken penalty',
      category: category || 'general',
      date: new Date().toISOString(),
    };

    wallet.total_points -= amount;
    wallet.points_history.push(transaction);
    wallet.updated_at = new Date().toISOString();

    db.get('userWallets')
      .find({ user_id: userId })
      .assign(wallet)
      .write();

    res.json({
      success: true,
      message: `Deducted ${amount} points`,
      wallet: wallet,
    });
  } catch (error) {
    console.error('Error deducting points:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get points history
router.get('/:userId/history', (req, res) => {
  try {
    const { userId } = req.params;

    const wallet = db.get('userWallets')
      .find({ user_id: userId })
      .value();

    if (!wallet) {
      return res.json({ history: [] });
    }

    res.json({
      history: wallet.points_history || [],
    });
  } catch (error) {
    console.error('Error fetching history:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
