const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');
const { validateLogin } = require('../middleware/validation');

// @route   POST /api/login
// @desc    Authenticate User & get token
// @access  Public
router.post('/login', validateLogin, async (req, res, next) => {
  try {
    const { username, password } = req.body;
    
    // Check if user exists (use parameterized query to prevent SQL Injection)
    const users = await db.query('SELECT * FROM Users WHERE username = ?', [username]);
    if (users.length === 0) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    
    const user = users[0];
    
    // Check if account is active
    if (user.status !== 'Active') {
      return res.status(403).json({ success: false, message: 'Your account is deactivated. Contact Admin.' });
    }
    
    // Verify password hash
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    
    // Get profile details if Attendant
    let attendantDetails = null;
    if (user.role === 'Attendant') {
      const attendants = await db.query('SELECT * FROM Parking_Attendants WHERE user_id = ?', [user.id]);
      if (attendants.length > 0) {
        attendantDetails = attendants[0];
      }
    }
    
    // Generate JWT
    const payload = {
      id: user.id,
      username: user.username,
      email: user.email,
      role: user.role,
      name: attendantDetails ? attendantDetails.name : 'System Admin',
      attendant_id: attendantDetails ? attendantDetails.id : null
    };
    
    const token = jwt.sign(
      payload,
      process.env.JWT_SECRET || 'super_secret_parking_jwt_key_2026',
      { expiresIn: '24h' }
    );
    
    res.json({
      success: true,
      message: 'Login successful',
      token: token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        name: attendantDetails ? attendantDetails.name : 'System Admin'
      }
    });
  } catch (err) {
    next(err);
  }
});

// @route   POST /api/logout
// @desc    Logout User
// @access  Public (Client clears token, simple success response)
router.post('/logout', (req, res) => {
  res.json({ success: true, message: 'Logout successful' });
});

module.exports = router;
