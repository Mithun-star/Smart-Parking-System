const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken } = require('../middleware/auth');
const { validateEntry } = require('../middleware/validation');

// @route   POST /api/entry
// @desc    Perform vehicle entry (Check-in)
// @access  Private (Admin & Attendant)
router.post('/', authenticateToken, validateEntry, async (req, res, next) => {
  const connection = await db.pool.getConnection();
  try {
    const { license_plate, slot_id, type, owner_name, owner_phone } = req.body;
    const attendant_id = req.user.id; // User who recorded this entry

    // Start Transaction
    await connection.beginTransaction();

    // 1. Check Slot Availability
    const [slotData] = await connection.execute(
      `SELECT s.*, a.name as area_name, a.base_price 
       FROM Parking_Slots s 
       JOIN Parking_Areas a ON s.area_id = a.id 
       WHERE s.id = ?`,
      [slot_id]
    );

    if (slotData.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Parking slot not found' });
    }

    const slot = slotData[0];
    if (slot.status !== 'Available') {
      await connection.rollback();
      return res.status(400).json({ success: false, message: `Parking slot ${slot.slot_number} is currently ${slot.status}` });
    }

    // 2. Create vehicle if not existing, or get existing vehicle ID
    let vehicleId;
    const [existingVehicle] = await connection.execute(
      'SELECT id FROM Vehicles WHERE license_plate = ?',
      [license_plate]
    );

    if (existingVehicle.length === 0) {
      // Insert new vehicle
      const [vehicleResult] = await connection.execute(
        'INSERT INTO Vehicles (license_plate, type, owner_name, owner_phone) VALUES (?, ?, ?, ?)',
        [license_plate, type || 'Four-Wheeler', owner_name || null, owner_phone || null]
      );
      vehicleId = vehicleResult.insertId;
    } else {
      vehicleId = existingVehicle[0].id;
      // Optionally update vehicle info if details provided
      if (owner_name || owner_phone) {
        await connection.execute(
          'UPDATE Vehicles SET owner_name = COALESCE(?, owner_name), owner_phone = COALESCE(?, owner_phone) WHERE id = ?',
          [owner_name || null, owner_phone || null, vehicleId]
        );
      }
    }

    // 3. Ensure vehicle does not already have an active parking session
    const [activeSession] = await connection.execute(
      'SELECT id FROM Parking_Records WHERE vehicle_id = ? AND status = "Active"',
      [vehicleId]
    );
    if (activeSession.length > 0) {
      await connection.rollback();
      return res.status(400).json({ success: false, message: 'Vehicle already has an active check-in session' });
    }

    // 4. Create parking record
    const entryTime = new Date();
    const [recordResult] = await connection.execute(
      'INSERT INTO Parking_Records (vehicle_id, slot_id, attendant_id, entry_time, status) VALUES (?, ?, ?, ?, "Active")',
      [vehicleId, slot_id, attendant_id, entryTime]
    );
    const recordId = recordResult.insertId;

    // 5. Update slot status to Occupied
    await connection.execute(
      'UPDATE Parking_Slots SET status = "Occupied" WHERE id = ?',
      [slot_id]
    );

    // Commit Transaction
    await connection.commit();

    // Respond with beautiful receipt details
    res.status(201).json({
      success: true,
      message: 'Vehicle checked in successfully',
      receipt: {
        record_id: recordId,
        vehicle_id: vehicleId,
        license_plate: license_plate,
        vehicle_type: type || slot.type,
        slot_number: slot.slot_number,
        area_name: slot.area_name,
        entry_time: entryTime,
        base_price: slot.base_price,
        recorded_by: req.user.name
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
