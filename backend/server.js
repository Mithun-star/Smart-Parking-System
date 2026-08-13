const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const db = require('./db');
const errorHandler = require('./middleware/errorHandler');

// Route imports
const authRoutes = require('./routes/auth');
const attendantsRoutes = require('./routes/attendants');
const areasRoutes = require('./routes/areas');
const slotsRoutes = require('./routes/slots');
const vehiclesRoutes = require('./routes/vehicles');
const entryRoutes = require('./routes/entry');
const exitRoutes = require('./routes/exit');
const paymentsRoutes = require('./routes/payments');
const recordsRoutes = require('./routes/records');
const dashboardRoutes = require('./routes/dashboard');

const app = express();
const PORT = process.env.PORT || 5000;

// Security and utility middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve frontend static assets if requested
app.use(express.static(path.join(__dirname, '../frontend')));

// Register Routes
app.use('/api', authRoutes);
app.use('/api/attendants', attendantsRoutes);
app.use('/api/areas', areasRoutes);
app.use('/api/slots', slotsRoutes);
app.use('/api/vehicles', vehiclesRoutes);
app.use('/api/entry', entryRoutes);
app.use('/api/exit', exitRoutes);
app.use('/api/payments', paymentsRoutes);
app.use('/api/records', recordsRoutes);
app.use('/api/dashboard', dashboardRoutes);

// Simple Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Smart Parking API Server is running.' });
});

// Root Redirect/Fallbacks
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// Centralized error handler
app.use(errorHandler);

// Database Pool Verification & Start
const startServer = async () => {
  try {
    // Check connection to pool
    const connection = await db.pool.getConnection();
    console.log('✔ Connected to MySQL Database Pool successfully.');
    connection.release();

    app.listen(PORT, () => {
      console.log(`================================================`);
      console.log(`🚀 Smart Parking System running on PORT ${PORT}`);
      console.log(`👉 Backend URL: http://localhost:${PORT}`);
      console.log(`================================================`);
    });
  } catch (err) {
    console.error('❌ Failed to establish database pool connection on startup:');
    console.error(err.message);
    console.log('\nStarting web server in offline/restricted mode...');
    
    // Start anyway so developer gets meaningful API errors rather than dead port
    app.listen(PORT, () => {
      console.log(`⚠ Server running on PORT ${PORT} (Database offline)`);
    });
  }
};

startServer();
