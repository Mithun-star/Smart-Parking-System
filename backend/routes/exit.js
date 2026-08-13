const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken } = require('../middleware/auth');

// @route   PUT /api/exit
// @desc    Calculate parking fee, register exit time, and free the slot
// @access  Private (Admin & Attendant)
router.put('/', authenticateToken, async (req, res, next) => {
  const connection = await db.pool.getConnection();
  try {
    const { license_plate, record_id, slot_id } = req.body;

    if (!license_plate && !record_id && !slot_id) {
      return res.status(400).json({
        success: false,
        message: 'Provide at least one identifier: license_plate, record_id, or slot_id'
      });
    }

    // Start Transaction
    await connection.beginTransaction();

    // 1. Find active parking record
    let findRecordQuery = `
      SELECT 
        r.id as record_id, r.entry_time, r.slot_id,
        v.license_plate, v.type as vehicle_type,
        s.slot_number,
        a.name as area_name, a.base_price
      FROM Parking_Records r
      JOIN Vehicles v ON r.vehicle_id = v.id
      JOIN Parking_Slots s ON r.slot_id = s.id
      JOIN Parking_Areas a ON s.area_id = a.id
      WHERE r.status = "Active"
    `;
    
    const params = [];
    if (record_id) {
      findRecordQuery += ' AND r.id = ?';
      params.push(parseInt(record_id));
    } else if (license_plate) {
      findRecordQuery += ' AND v.license_plate = ?';
      params.push(license_plate.trim().toUpperCase());
    } else if (slot_id) {
      findRecordQuery += ' AND r.slot_id = ?';
      params.push(parseInt(slot_id));
    }

    const [records] = await connection.execute(findRecordQuery, params);

    if (records.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'No active parking session found for the provided details' });
    }

    const record = records[0];
    const exitTime = new Date();
    const entryTime = new Date(record.entry_time);

    // 2. Calculate duration in milliseconds
    const durationMs = exitTime - entryTime;
    const durationMins = Math.max(1, Math.round(durationMs / (1000 * 60))); // at least 1 min
    
    // Calculate hours (round up partial hours)
    // Rule: First hour ₹20, Additional hours ₹20 (dynamically determined by base_price)
    const durationHours = Math.ceil(durationMs / (1000 * 60 * 60));
    const hoursToCharge = Math.max(1, durationHours); // at least 1 hour charge
    
    const basePrice = parseFloat(record.base_price || 20.00);
    const calculatedFee = hoursToCharge * basePrice;

    // 3. Update exit time and fee in Parking_Records
    // Note: Record status is marked 'Completed' (it has checked out, payment will follow to settle)
    await connection.execute(
      'UPDATE Parking_Records SET exit_time = ?, calculated_fee = ?, status = "Completed" WHERE id = ?',
      [exitTime, calculatedFee, record.record_id]
    );

    // 4. Free the parking slot (set back to Available)
    await connection.execute(
      'UPDATE Parking_Slots SET status = "Available" WHERE id = ?',
      [record.slot_id]
    );

    // Commit Transaction
    await connection.commit();

    res.json({
      success: true,
      message: 'Vehicle exit processed successfully. Slot is now free.',
      invoice: {
        record_id: record.record_id,
        license_plate: record.license_plate,
        vehicle_type: record.vehicle_type,
        slot_number: record.slot_number,
        area_name: record.area_name,
        entry_time: entryTime,
        exit_time: exitTime,
        duration_minutes: durationMins,
        hours_charged: hoursToCharge,
        hourly_rate: basePrice,
        calculated_fee: calculatedFee
      }
    });
  } catch (err) {
    await connection.rollback();
    next(err);
  } finally {
    connection.release();
  }
});

module.exports = router;
