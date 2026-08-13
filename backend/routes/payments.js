const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken } = require('../middleware/auth');
const { validatePayment } = require('../middleware/validation');

// @route   GET /api/payments
// @desc    Get all payments history
// @access  Private (Admin & Attendant)
router.get('/', authenticateToken, async (req, res, next) => {
  try {
    const q = `
      SELECT 
        p.id as payment_id, p.amount, p.payment_method, p.payment_date, p.transaction_id, p.created_at,
        r.entry_time, r.exit_time, r.calculated_fee,
        v.license_plate, v.type as vehicle_type,
        s.slot_number,
        a.name as area_name
      FROM Payments p
      JOIN Parking_Records r ON p.record_id = r.id
      JOIN Vehicles v ON r.vehicle_id = v.id
      JOIN Parking_Slots s ON r.slot_id = s.id
      JOIN Parking_Areas a ON s.area_id = a.id
      ORDER BY p.id DESC
    `;
    const payments = await db.query(q);
    res.json({ success: true, count: payments.length, data: payments });
  } catch (err) {
    next(err);
  }
});

// @route   POST /api/payment
// @desc    Record a new payment for a parking session
// @access  Private (Admin & Attendant)
router.post('/', authenticateToken, validatePayment, async (req, res, next) => {
  try {
    const { record_id, amount, payment_method, transaction_id } = req.body;

    // 1. Verify parking record exists and is Completed
    const record = await db.query('SELECT * FROM Parking_Records WHERE id = ?', [record_id]);
    if (record.length === 0) {
      return res.status(404).json({ success: false, message: 'Parking record not found' });
    }

    const pr = record[0];
    if (pr.status !== 'Completed') {
      return res.status(400).json({ success: false, message: 'Process vehicle exit first before collecting payment' });
    }

    // 2. Check if payment already exists for this record
    const existingPayment = await db.query('SELECT id FROM Payments WHERE record_id = ?', [record_id]);
    if (existingPayment.length > 0) {
      return res.status(400).json({ success: false, message: 'Payment has already been processed for this record' });
    }

    // 3. Generate secure transaction ID if not provided
    const txnId = transaction_id || 'TXN' + Date.now() + Math.floor(1000 + Math.random() * 9000);

    // 4. Save payment
    const result = await db.query(
      'INSERT INTO Payments (record_id, amount, payment_method, transaction_id) VALUES (?, ?, ?, ?)',
      [record_id, amount, payment_method, txnId]
    );

    res.status(201).json({
      success: true,
      message: 'Payment processed successfully',
      payment: {
        id: result.insertId,
        record_id,
        amount,
        payment_method,
        transaction_id: txnId,
        payment_date: new Date()
      }
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
