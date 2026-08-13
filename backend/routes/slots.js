const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken, requireRole } = require('../middleware/auth');
const { validateSlot } = require('../middleware/validation');

// @route   GET /api/slots
// @desc    Get all parking slots with area details
// @access  Private (Admin & Attendant)
router.get('/', authenticateToken, async (req, res, next) => {
  try {
    const { area_id, status } = req.query;
    
    let q = `
      SELECT 
        s.id, s.area_id, s.slot_number, s.type, s.status, s.created_at,
        a.name as area_name, a.location as area_location, a.base_price
      FROM Parking_Slots s
      JOIN Parking_Areas a ON s.area_id = a.id
    `;
    
    const params = [];
    const conditions = [];

    if (area_id) {
      conditions.push('s.area_id = ?');
      params.push(parseInt(area_id));
    }

    if (status) {
      conditions.push('s.status = ?');
      params.push(status);
    }

    if (conditions.length > 0) {
      q += ' WHERE ' + conditions.join(' AND ');
    }

    q += ' ORDER BY a.name ASC, s.slot_number ASC';

    const slots = await db.query(q, params);
    res.json({ success: true, count: slots.length, data: slots });
  } catch (err) {
    next(err);
  }
});

// @route   POST /api/slots
// @desc    Create a new parking slot inside an area
// @access  Private (Admin Only)
router.post('/', authenticateToken, requireRole('Admin'), validateSlot, async (req, res, next) => {
  const connection = await db.pool.getConnection();
  try {
    const { area_id, slot_number, type, status } = req.body;
    const slotType = type || 'Four-Wheeler';
    const slotStatus = status || 'Available';

    await connection.beginTransaction();

    // 1. Verify area exists
    const [area] = await connection.execute('SELECT id, slot_count FROM Parking_Areas WHERE id = ?', [area_id]);
    if (area.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Parking area not found' });
    }

    // 2. Check if slot number already exists in this area
    const [existing] = await connection.execute(
      'SELECT id FROM Parking_Slots WHERE area_id = ? AND slot_number = ?',
      [area_id, slot_number]
    );
    if (existing.length > 0) {
      await connection.rollback();
      return res.status(400).json({ success: false, message: `Slot '${slot_number}' already exists in this area` });
    }

    // 3. Insert new slot
    const [result] = await connection.execute(
      'INSERT INTO Parking_Slots (area_id, slot_number, type, status) VALUES (?, ?, ?, ?)',
      [area_id, slot_number, slotType, slotStatus]
    );

    // 4. Update the area slot_count
    await connection.execute(
      'UPDATE Parking_Areas SET slot_count = slot_count + 1 WHERE id = ?',
      [area_id]
    );

    await connection.commit();

    res.status(201).json({
      success: true,
      message: 'Parking slot added successfully',
      data: {
        id: result.insertId,
        area_id,
        slot_number,
        type: slotType,
        status: slotStatus
      }
    });
  } catch (err) {
    await connection.rollback();
    next(err);
  } finally {
    connection.release();
  }
});

// @route   PUT /api/slots/:id
// @desc    Update parking slot status or config
// @access  Private (Admin & Attendant)
router.put('/:id', authenticateToken, validateSlot, async (req, res, next) => {
  try {
    const slotId = parseInt(req.params.id);
    const { slot_number, type, status } = req.body;

    // Verify slot exists
    const slotDetails = await db.query('SELECT * FROM Parking_Slots WHERE id = ?', [slotId]);
    if (slotDetails.length === 0) {
      return res.status(404).json({ success: false, message: 'Parking slot not found' });
    }

    const currentSlot = slotDetails[0];

    // Attendants can only toggle status, Admin can edit everything
    if (req.user.role !== 'Admin') {
      if (slot_number || type) {
        return res.status(403).json({ success: false, message: 'Only Admins can modify slot metadata. Attendants can only change status.' });
      }
    }

    // Build update parameters dynamically
    let updateFields = [];
    let params = [];

    if (slot_number && req.user.role === 'Admin') {
      // Check slot number duplicate in the same area
      const existing = await db.query(
        'SELECT id FROM Parking_Slots WHERE area_id = ? AND slot_number = ? AND id != ?',
        [currentSlot.area_id, slot_number, slotId]
      );
      if (existing.length > 0) {
        return res.status(400).json({ success: false, message: `Slot number '${slot_number}' already exists in this area` });
      }
      updateFields.push('slot_number = ?');
      params.push(slot_number);
    }

    if (type && req.user.role === 'Admin') {
      updateFields.push('type = ?');
      params.push(type);
    }

    if (status) {
      updateFields.push('status = ?');
      params.push(status);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({ success: false, message: 'No fields provided for update' });
    }

    updateFields.push('updated_at = CURRENT_TIMESTAMP');
    params.push(slotId);

    const q = `UPDATE Parking_Slots SET ${updateFields.join(', ')} WHERE id = ?`;
    await db.query(q, params);

    res.json({
      success: true,
      message: 'Parking slot updated successfully',
      data: {
        id: slotId,
        slot_number: slot_number || currentSlot.slot_number,
        type: type || currentSlot.type,
        status: status || currentSlot.status
      }
    });
  } catch (err) {
    next(err);
  }
});

// @route   DELETE /api/slots/:id
// @desc    Delete a parking slot
// @access  Private (Admin Only)
router.delete('/:id', authenticateToken, requireRole('Admin'), async (req, res, next) => {
  const connection = await db.pool.getConnection();
  try {
    const slotId = parseInt(req.params.id);

    await connection.beginTransaction();

    // Verify slot exists and get its area
    const [slot] = await connection.execute('SELECT area_id FROM Parking_Slots WHERE id = ?', [slotId]);
    if (slot.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Parking slot not found' });
    }

    const area_id = slot[0].area_id;

    // 1. Delete slot (Cascades delete to Parking_Records, Payments)
    await connection.execute('DELETE FROM Parking_Slots WHERE id = ?', [slotId]);

    // 2. Decrement slot count in Parking_Areas
    await connection.execute(
      'UPDATE Parking_Areas SET slot_count = GREATEST(0, slot_count - 1) WHERE id = ?',
      [area_id]
    );

    await connection.commit();
    res.json({ success: true, message: 'Parking slot deleted successfully' });
  } catch (err) {
    await connection.rollback();
    next(err);
  } finally {
    connection.release();
  }
});

module.exports = router;
