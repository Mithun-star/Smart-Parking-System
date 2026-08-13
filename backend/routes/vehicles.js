const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken } = require('../middleware/auth');
const { validateVehicle } = require('../middleware/validation');

// @route   GET /api/vehicles
// @desc    Get all vehicles or search by license plate
// @access  Private (Admin & Attendant)
router.get('/', authenticateToken, async (req, res, next) => {
  try {
    const { plate } = req.query;
    
    let vehicles;
    if (plate) {
      vehicles = await db.query(
        'SELECT * FROM Vehicles WHERE license_plate LIKE ? ORDER BY id DESC',
        [`%${plate.trim().toUpperCase()}%`]
      );
    } else {
      vehicles = await db.query('SELECT * FROM Vehicles ORDER BY id DESC');
    }

    res.json({ success: true, count: vehicles.length, data: vehicles });
  } catch (err) {
    next(err);
  }
});

// @route   POST /api/vehicles
// @desc    Create a new vehicle record manually
// @access  Private (Admin & Attendant)
router.post('/', authenticateToken, validateVehicle, async (req, res, next) => {
  try {
    const { license_plate, type, owner_name, owner_phone } = req.body;

    // Check if plate already registered
    const existing = await db.query('SELECT * FROM Vehicles WHERE license_plate = ?', [license_plate]);
    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Vehicle with this license plate is already registered',
        data: existing[0]
      });
    }

    const result = await db.query(
      'INSERT INTO Vehicles (license_plate, type, owner_name, owner_phone) VALUES (?, ?, ?, ?)',
      [license_plate, type, owner_name || null, owner_phone || null]
    );

    res.status(201).json({
      success: true,
      message: 'Vehicle registered successfully',
      data: {
        id: result.insertId,
        license_plate,
        type,
        owner_name,
        owner_phone
      }
    });
  } catch (err) {
    next(err);
  }
});

// @route   PUT /api/vehicles/:id
// @desc    Update vehicle details
// @access  Private (Admin & Attendant)
router.put('/:id', authenticateToken, validateVehicle, async (req, res, next) => {
  try {
    const vehicleId = parseInt(req.params.id);
    const { license_plate, type, owner_name, owner_phone } = req.body;

    // Verify vehicle exists
    const vehicle = await db.query('SELECT id FROM Vehicles WHERE id = ?', [vehicleId]);
    if (vehicle.length === 0) {
      return res.status(404).json({ success: false, message: 'Vehicle not found' });
    }

    // Check if license plate is taken by another vehicle record
    const plateCheck = await db.query(
      'SELECT id FROM Vehicles WHERE license_plate = ? AND id != ?',
      [license_plate, vehicleId]
    );
    if (plateCheck.length > 0) {
      return res.status(400).json({ success: false, message: 'License plate is already registered to another vehicle' });
    }

    await db.query(
      'UPDATE Vehicles SET license_plate = ?, type = ?, owner_name = ?, owner_phone = ? WHERE id = ?',
      [license_plate, type, owner_name || null, owner_phone || null, vehicleId]
    );

    res.json({
      success: true,
      message: 'Vehicle details updated successfully',
      data: {
        id: vehicleId,
        license_plate,
        type,
        owner_name,
        owner_phone
      }
    });
  } catch (err) {
    next(err);
  }
});

// @route   DELETE /api/vehicles/:id
// @desc    Delete vehicle record
// @access  Private (Admin Only)
router.delete('/:id', authenticateToken, async (req, res, next) => {
  try {
    const vehicleId = parseInt(req.params.id);

    const vehicle = await db.query('SELECT id FROM Vehicles WHERE id = ?', [vehicleId]);
    if (vehicle.length === 0) {
      return res.status(404).json({ success: false, message: 'Vehicle not found' });
    }

    await db.query('DELETE FROM Vehicles WHERE id = ?', [vehicleId]);

    res.json({ success: true, message: 'Vehicle record deleted successfully' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
