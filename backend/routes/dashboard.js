const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken } = require('../middleware/auth');

// @route   GET /api/dashboard/stats
// @desc    Retrieve system metrics for admin/attendant dashboard
// @access  Private (Admin & Attendant)
router.get('/stats', authenticateToken, async (req, res, next) => {
  try {
    // 1. Slot Stats
    const slotsCount = await db.query(
      `SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) as available,
        SUM(CASE WHEN status = 'Occupied' THEN 1 ELSE 0 END) as occupied,
        SUM(CASE WHEN status = 'Maintenance' THEN 1 ELSE 0 END) as maintenance
       FROM Parking_Slots`
    );
    const slotStats = slotsCount[0] || { total: 0, available: 0, occupied: 0, maintenance: 0 };

    // 2. Vehicle Stats
    const vehicleStats = await db.query('SELECT COUNT(*) as total FROM Vehicles');
    const totalVehicles = vehicleStats[0]?.total || 0;

    // 3. Active Sessions
    const activeStats = await db.query('SELECT COUNT(*) as total FROM Parking_Records WHERE status = "Active"');
    const activeSessions = activeStats[0]?.total || 0;

    // 4. Today's Revenue (payments done today in local timezone or server UTC)
    // SQL: DATE(payment_date) = CURDATE()
    const todayRevenueStats = await db.query(
      `SELECT COALESCE(SUM(amount), 0) as total FROM Payments WHERE DATE(payment_date) = CURDATE()`
    );
    const todayRevenue = parseFloat(todayRevenueStats[0]?.total || 0);

    // 5. Monthly Revenue (payments in the current month)
    // SQL: YEAR(payment_date) = YEAR(CURDATE()) AND MONTH(payment_date) = MONTH(CURDATE())
    const monthRevenueStats = await db.query(
      `SELECT COALESCE(SUM(amount), 0) as total 
       FROM Payments 
       WHERE YEAR(payment_date) = YEAR(CURDATE()) AND MONTH(payment_date) = MONTH(CURDATE())`
    );
    const monthlyRevenue = parseFloat(monthRevenueStats[0]?.total || 0);

    // 6. Recent Transactions (last 5 payments)
    const recentTxns = await db.query(
      `SELECT 
        p.id, p.amount, p.payment_method, p.payment_date, p.transaction_id,
        v.license_plate, a.name as area_name
       FROM Payments p
       JOIN Parking_Records r ON p.record_id = r.id
       JOIN Vehicles v ON r.vehicle_id = v.id
       JOIN Parking_Slots s ON r.slot_id = s.id
       JOIN Parking_Areas a ON s.area_id = a.id
       ORDER BY p.id DESC
       LIMIT 5`
    );

    res.json({
      success: true,
      data: {
        slots: {
          total: slotStats.total || 0,
          available: slotStats.available || 0,
          occupied: slotStats.occupied || 0,
          maintenance: slotStats.maintenance || 0
        },
        total_vehicles: totalVehicles,
        active_sessions: activeSessions,
        revenue: {
          today: todayRevenue,
          monthly: monthlyRevenue
        },
        recent_transactions: recentTxns
      }
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
