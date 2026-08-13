const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken } = require('../middleware/auth');

// @route   GET /api/records
// @desc    Get all parking sessions (history & active)
// @access  Private (Admin & Attendant)
router.get('/', authenticateToken, async (req, res, next) => {
  try {
    const { status, plate, area_id } = req.query;

    let q = `
      SELECT 
        r.id as record_id, r.entry_time, r.exit_time, r.calculated_fee, r.status, r.created_at,
        v.license_plate, v.type as vehicle_type, v.owner_name, v.owner_phone,
        s.slot_number, s.type as slot_type,
        a.name as area_name, a.location as area_location,
        u.username as attendant_username,
        p.id as payment_id, p.payment_method, p.transaction_id
      FROM Parking_Records r
      JOIN Vehicles v ON r.vehicle_id = v.id
      JOIN Parking_Slots s ON r.slot_id = s.id
      JOIN Parking_Areas a ON s.area_id = a.id
      JOIN Users u ON r.attendant_id = u.id
      LEFT JOIN Payments p ON p.record_id = r.id
    `;

    const params = [];
    const conditions = [];

    if (status) {
      conditions.push('r.status = ?');
      params.push(status);
    }

    if (plate) {
      conditions.push('v.license_plate LIKE ?');
      params.push(`%${plate.trim().toUpperCase()}%`);
    }

    if (area_id) {
      conditions.push('s.area_id = ?');
      params.push(parseInt(area_id));
    }

    if (conditions.length > 0) {
      q += ' WHERE ' + conditions.join(' AND ');
    }

    q += ' ORDER BY r.id DESC';

    const records = await db.query(q, params);
    res.json({ success: true, count: records.length, data: records });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
