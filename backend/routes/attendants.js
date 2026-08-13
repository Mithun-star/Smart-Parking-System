const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const db = require('../db');
const { authenticateToken, requireRole } = require('../middleware/auth');
const { validateAttendant } = require('../middleware/validation');

// @route   GET /api/attendants
// @desc    Get all attendants with user profiles
// @access  Private (Admin Only)
router.get('/', authenticateToken, requireRole('Admin'), async (req, res, next) => {
  try {
    const q = `
      SELECT 
        a.id, a.user_id, a.name, a.phone, a.address, a.hire_date,
        u.username, u.email, u.status, u.created_at
      FROM Parking_Attendants a
      JOIN Users u ON a.user_id = u.id
      ORDER BY a.id DESC
    `;
    const attendants = await db.query(q);
    res.json({ success: true, count: attendants.length, data: attendants });
  } catch (err) {
    next(err);
  }
});

// @route   POST /api/attendants
// @desc    Create new attendant user & profile
// @access  Private (Admin Only)
router.post('/', authenticateToken, requireRole('Admin'), validateAttendant, async (req, res, next) => {
  const connection = await db.pool.getConnection();
  try {
    const { username, password, email, name, phone, address, status } = req.body;
    const hire_date = req.body.hire_date || new Date().toISOString().slice(0, 10);
    const userStatus = status || 'Active';

    // Start Transaction
    await connection.beginTransaction();

    // Check if user already exists
    const [existing] = await connection.execute(
      'SELECT id FROM Users WHERE username = ? OR email = ?',
      [username, email]
    );
    if (existing.length > 0) {
      await connection.rollback();
      return res.status(400).json({ success: false, message: 'Username or Email already registered' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    // 1. Insert into Users table
    const [userResult] = await connection.execute(
      'INSERT INTO Users (username, password_hash, email, role, status) VALUES (?, ?, ?, "Attendant", ?)',
      [username, password_hash, email, userStatus]
    );
    
    const user_id = userResult.insertId;

    // 2. Insert into Parking_Attendants details table
    const [attendantResult] = await connection.execute(
      'INSERT INTO Parking_Attendants (user_id, name, phone, address, hire_date) VALUES (?, ?, ?, ?, ?)',
      [user_id, name, phone, address || null, hire_date]
    );

    // Commit Transaction
    await connection.commit();

    res.status(201).json({
      success: true,
      message: 'Parking Attendant created successfully',
      data: {
        id: attendantResult.insertId,
        user_id,
        username,
        email,
        name,
        phone,
        address,
        hire_date,
        status: userStatus
      }
    });
  } catch (err) {
    await connection.rollback();
    next(err);
  } finally {
    connection.release();
  }
});

// @route   PUT /api/attendants/:id
// @desc    Update attendant profile & user status
// @access  Private (Admin Only)
router.put('/:id', authenticateToken, requireRole('Admin'), validateAttendant, async (req, res, next) => {
  const connection = await db.pool.getConnection();
  try {
    const attendantId = parseInt(req.params.id);
    const { email, name, phone, address, hire_date, status, password } = req.body;

    // Start Transaction
    await connection.beginTransaction();

    // Verify attendant exists
    const [attendantExists] = await connection.execute(
      'SELECT user_id FROM Parking_Attendants WHERE id = ?',
      [attendantId]
    );
    if (attendantExists.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Attendant not found' });
    }

    const user_id = attendantExists[0].user_id;

    // Check if email unique to others
    if (email) {
      const [emailCheck] = await connection.execute(
        'SELECT id FROM Users WHERE email = ? AND id != ?',
        [email, user_id]
      );
      if (emailCheck.length > 0) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: 'Email already in use by another user' });
      }
    }

    // Update Users fields
    let userQuery = 'UPDATE Users SET email = ?';
    let userParams = [email];

    if (status) {
      userQuery += ', status = ?';
      userParams.push(status);
    }

    // Optional password change
    if (password && password.trim() !== '') {
      const salt = await bcrypt.genSalt(10);
      const password_hash = await bcrypt.hash(password, salt);
      userQuery += ', password_hash = ?';
      userParams.push(password_hash);
    }

    userQuery += ' WHERE id = ?';
    userParams.push(user_id);

    await connection.execute(userQuery, userParams);

    // Update Parking_Attendants fields
    const attendantQuery = `
      UPDATE Parking_Attendants 
      SET name = ?, phone = ?, address = ?, hire_date = ?
      WHERE id = ?
    `;
    const attendantParams = [name, phone, address || null, hire_date, attendantId];
    await connection.execute(attendantQuery, attendantParams);

    // Commit Transaction
    await connection.commit();

    res.json({
      success: true,
      message: 'Attendant updated successfully',
      data: {
        id: attendantId,
        user_id,
        email,
        name,
        phone,
        address,
        hire_date,
        status
      }
    });
  } catch (err) {
    await connection.rollback();
    next(err);
  } finally {
    connection.release();
  }
});

// @route   DELETE /api/attendants/:id
// @desc    Delete attendant & associated User account
// @access  Private (Admin Only)
router.delete('/:id', authenticateToken, requireRole('Admin'), async (req, res, next) => {
  const connection = await db.pool.getConnection();
  try {
    const attendantId = parseInt(req.params.id);

    // Start Transaction
    await connection.beginTransaction();

    const [attendant] = await connection.execute(
      'SELECT user_id FROM Parking_Attendants WHERE id = ?',
      [attendantId]
    );

    if (attendant.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Attendant not found' });
    }

    const user_id = attendant[0].user_id;

    // Delete details first (cascaded by DB but explicit is safer)
    await connection.execute('DELETE FROM Parking_Attendants WHERE id = ?', [attendantId]);
    
    // Delete user account (which will also clean up cascading FKs if defined)
    await connection.execute('DELETE FROM Users WHERE id = ?', [user_id]);

    await connection.commit();
    res.json({ success: true, message: 'Attendant and account deleted successfully' });
  } catch (err) {
    await connection.rollback();
    next(err);
  } finally {
    connection.release();
  }
});

module.exports = router;
