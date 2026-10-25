const express = require('express');
const router = express.Router();
const db = require('../services/database');

// Get all appointments for a user
router.get('/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    
    // Get all appointments for this user
    const appointments = db
      .get('appointments')
      .filter({ user_id: userId })
      .value() || [];

    res.json(appointments);
  } catch (error) {
    console.error('Error fetching appointments:', error);
    res.status(500).json({ error: 'Failed to fetch appointments' });
  }
});

// Create a new appointment
router.post('/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const appointmentData = req.body;

    // Ensure user_id matches
    appointmentData.user_id = userId;

    // Initialize appointments array if it doesn't exist
    if (!db.has('appointments').value()) {
      db.set('appointments', []).write();
    }

    // Add the appointment
    db.get('appointments')
      .push(appointmentData)
      .write();

    res.status(201).json({ 
      success: true, 
      message: 'Appointment created successfully',
      appointment: appointmentData 
    });
  } catch (error) {
    console.error('Error creating appointment:', error);
    res.status(500).json({ error: 'Failed to create appointment' });
  }
});

// Update an appointment
router.put('/:userId/:appointmentId', (req, res) => {
  try {
    const { userId, appointmentId } = req.params;
    const updatedData = req.body;

    const appointment = db
      .get('appointments')
      .find({ user_id: userId, id: appointmentId })
      .assign(updatedData)
      .write();

    if (appointment) {
      res.json({ 
        success: true, 
        message: 'Appointment updated successfully',
        appointment 
      });
    } else {
      res.status(404).json({ error: 'Appointment not found' });
    }
  } catch (error) {
    console.error('Error updating appointment:', error);
    res.status(500).json({ error: 'Failed to update appointment' });
  }
});

// Delete an appointment
router.delete('/:userId/:appointmentId', (req, res) => {
  try {
    const { userId, appointmentId } = req.params;

    db.get('appointments')
      .remove({ user_id: userId, id: appointmentId })
      .write();

    res.json({ 
      success: true, 
      message: 'Appointment deleted successfully' 
    });
  } catch (error) {
    console.error('Error deleting appointment:', error);
    res.status(500).json({ error: 'Failed to delete appointment' });
  }
});

module.exports = router;
