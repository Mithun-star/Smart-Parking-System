const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken, requireRole } = require('../middleware/auth');
const { validateArea } = require('../middleware/validation');

// @route   GET /api/areas
// @desc    Get all parking areas
// @access  Private (Admin & Attendant)
router.get('/', authenticateToken, async (req, res, next) => {
  try {
    const areas = await db.query('SELECT * FROM Parking_Areas ORDER BY id DESC');
    res.json({ success: true, count: areas.length, data: areas });
  } catch (err) {
    next(err);
  }
});

// @route   POST /api/areas
// @desc    Create new parking area
// @access  Private (Admin Only)
router.post('/', authenticateToken, requireRole('Admin'), validateArea, async (req, res, next) => {
  try {
    const { name, location, base_price } = req.body;
    
    // Check name uniqueness
    const existing = await db.query('SELECT id FROM Parking_Areas WHERE name = ?', [name]);
    if (existing.length > 0) {
      return res.status(400).json({ success: false, message: 'Parking area name already exists' });
    }

    const price = base_price !== undefined ? base_price : 20.00;

    const result = await db.query(
      'INSERT INTO Parking_Areas (name, location, base_price) VALUES (?, ?, ?)',
      [name, location, price]
    );

    res.status(201).json({
      success: true,
      message: 'Parking area created successfully',
      data: {
        id: result.insertId,
        name,
        location,
        slot_count: 0,
        base_price: price
      }
    });
  } catch (err) {
    next(err);
  }
});

// @route   PUT /api/areas/:id
// @desc    Update parking area details
// @access  Private (Admin Only)
router.put('/:id', authenticateToken, requireRole('Admin'), validateArea, async (req, res, next) => {
  try {
    const areaId = parseInt(req.params.id);
    const { name, location, base_price } = req.body;

    // Check if area exists
    const area = await db.query('SELECT * FROM Parking_Areas WHERE id = ?', [areaId]);
    if (area.length === 0) {
      return res.status(404).json({ success: false, message: 'Parking area not found' });
    }

    // Check name uniqueness against other areas
    const existingName = await db.query('SELECT id FROM Parking_Areas WHERE name = ? AND id != ?', [name, areaId]);
    if (existingName.length > 0) {
      return res.status(400).json({ success: false, message: 'Parking area name is already in use' });
    }

    await db.query(
      'UPDATE Parking_Areas SET name = ?, location = ?, base_price = ? WHERE id = ?',
      [name, location, base_price, areaId]
    );

    res.json({
      success: true,
      message: 'Parking area updated successfully',
      data: {
        id: areaId,
        name,
        location,
        base_price
      }
    });
  } catch (err) {
    next(err);
  }
});

// @route   DELETE /api/areas/:id
// @desc    Delete parking area
// @access  Private (Admin Only)
router.delete('/:id', authenticateToken, requireRole('Admin'), async (req, res, next) => {
  try {
    const areaId = parseInt(req.params.id);

    const area = await db.query('SELECT id FROM Parking_Areas WHERE id = ?', [areaId]);
    if (area.length === 0) {
      return res.status(404).json({ success: false, message: 'Parking area not found' });
    }

    // Deleting the area will cascade and delete all nested Slots, Parking Records, etc.
    await db.query('DELETE FROM Parking_Areas WHERE id = ?', [areaId]);

    res.json({ success: true, message: 'Parking area and all associated slots deleted successfully' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
