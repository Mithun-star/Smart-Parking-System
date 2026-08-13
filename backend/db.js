const mysql = require('mysql2/promise');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');
require('dotenv').config();

let useSqlite = false;
let sqliteDb = null;
let pool = null;

// Mock connection class for SQLite mimicking mysql2 pool connections
class SqliteConnection {
  constructor(db) {
    this.db = db;
  }

  async execute(sql, params = []) {
    return new Promise((resolve, reject) => {
      // 1. Convert MySQL placeholders / parameters and formats safely
      // SQLite uses standard ? just like MySQL, so queries require zero changes.
      // But we must handle the return formats for updates/inserts to match mysql2.
      const cleanedSql = sql.trim().replace(/COALESCE\(\?, \w+\)/gi, (match) => {
        // SQLite supports COALESCE.
        return match;
      });

      const lowerSql = cleanedSql.toLowerCase();
      const isInsert = lowerSql.startsWith('insert');
      const isUpdate = lowerSql.startsWith('update') || lowerSql.startsWith('delete');

      if (isInsert || isUpdate) {
        this.db.run(cleanedSql, params, function (err) {
          if (err) return reject(err);
          // Return identical mysql2 result structure: [result] where result carries insertId/affectedRows
          resolve([{
            insertId: this.lastID,
            affectedRows: this.changes
          }]);
        });
      } else {
        this.db.all(cleanedSql, params, (err, rows) => {
          if (err) return reject(err);
          resolve([rows]);
        });
      }
    });
  }

  async query(sql, params = []) {
    return this.execute(sql, params);
  }

  async beginTransaction() {
    return new Promise((resolve, reject) => {
      this.db.run('BEGIN TRANSACTION', err => {
        if (err) reject(err);
        else resolve();
      });
    });
  }

  async commit() {
    return new Promise((resolve, reject) => {
      this.db.run('COMMIT', err => {
        if (err) reject(err);
        else resolve();
      });
    });
  }

  async rollback() {
    return new Promise((resolve, reject) => {
      this.db.run('ROLLBACK', err => {
        if (err) reject(err);
        else resolve();
      });
    });
  }

  release() {
    // SQLite doesn't need to return connection back to pool
  }
}

// Mock pool matching mysql2 API
const mockPool = {
  getConnection: async () => {
    return new SqliteConnection(sqliteDb);
  },
  execute: async (sql, params = []) => {
    const conn = new SqliteConnection(sqliteDb);
    return conn.execute(sql, params);
  },
  query: async (sql, params = []) => {
    const conn = new SqliteConnection(sqliteDb);
    return conn.query(sql, params);
  }
};

// SQLite Initializer & Seeder
async function initializeSqlite() {
  const dbDir = path.join(__dirname, '../database');
  if (!fs.existsSync(dbDir)) {
    fs.mkdirSync(dbDir, { recursive: true });
  }

  const dbPath = path.join(dbDir, 'smart_parking.db');
  console.log(`\n================================================`);
  console.log(`💾 DATABASE REDIRECT: Booting SQLite Mode`);
  console.log(`📂 DB Path: ${dbPath}`);
  console.log(`================================================\n`);

  sqliteDb = new sqlite3.Database(dbPath);

  const runCmd = (sql) => new Promise((resolve, reject) => {
    sqliteDb.run(sql, (err) => {
      if (err) reject(err);
      else resolve();
    });
  });

  try {
    // 1. Create Tables
    await runCmd(`
      CREATE TABLE IF NOT EXISTS Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        role TEXT NOT NULL DEFAULT 'Attendant',
        status TEXT NOT NULL DEFAULT 'Active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await runCmd(`
      CREATE TABLE IF NOT EXISTS Parking_Attendants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT,
        hire_date TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE
      )
    `);

    await runCmd(`
      CREATE TABLE IF NOT EXISTS Parking_Areas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        location TEXT NOT NULL,
        slot_count INTEGER NOT NULL DEFAULT 0,
        base_price REAL NOT NULL DEFAULT 20.00,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await runCmd(`
      CREATE TABLE IF NOT EXISTS Vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        license_plate TEXT UNIQUE NOT NULL,
        type TEXT NOT NULL DEFAULT 'Four-Wheeler',
        owner_name TEXT,
        owner_phone TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await runCmd(`
      CREATE TABLE IF NOT EXISTS Parking_Slots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        area_id INTEGER NOT NULL,
        slot_number TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'Four-Wheeler',
        status TEXT NOT NULL DEFAULT 'Available',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (area_id) REFERENCES Parking_Areas (id) ON DELETE CASCADE,
        UNIQUE (area_id, slot_number)
      )
    `);

    await runCmd(`
      CREATE TABLE IF NOT EXISTS Parking_Records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        slot_id INTEGER NOT NULL,
        attendant_id INTEGER NOT NULL,
        entry_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        exit_time DATETIME,
        calculated_fee REAL DEFAULT 0.00,
        status TEXT NOT NULL DEFAULT 'Active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (vehicle_id) REFERENCES Vehicles (id) ON DELETE CASCADE,
        FOREIGN KEY (slot_id) REFERENCES Parking_Slots (id) ON DELETE CASCADE,
        FOREIGN KEY (attendant_id) REFERENCES Users (id) ON DELETE CASCADE
      )
    `);

    await runCmd(`
      CREATE TABLE IF NOT EXISTS Payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        record_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL DEFAULT 'Cash',
        payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        transaction_id TEXT UNIQUE NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (record_id) REFERENCES Parking_Records (id) ON DELETE CASCADE
      )
    `);

    // 2. Check and Seed Default Data if empty
    const checkUsers = await new Promise((resolve) => {
      sqliteDb.get('SELECT COUNT(*) as count FROM Users', (err, row) => resolve(row ? row.count : 0));
    });

    if (checkUsers === 0) {
      console.log('🌱 Seeding default credentials, areas, slots, and test data in SQLite...');

      // Seed Users (bcrypt hashes for admin123 / attendant123)
      await runCmd(`INSERT INTO Users (id, username, password_hash, email, role, status) VALUES 
        (1, 'admin', '$2a$10$7WG9aDiEu90gaEBGLfN6oe8s25ciIs7niiYrOnFwAIfYvnVJSirtS', 'admin@smartparking.com', 'Admin', 'Active'),
        (2, 'attendant', '$2a$10$.o5fP7qfZ8dVx4S/6ZcRxOJlUQzO0pHANM5/yGysnFAVfw4/NL7/m', 'attendant@smartparking.com', 'Attendant', 'Active'),
        (3, 'ramesh', '$2a$10$.o5fP7qfZ8dVx4S/6ZcRxOJlUQzO0pHANM5/yGysnFAVfw4/NL7/m', 'ramesh@smartparking.com', 'Attendant', 'Active')`);

      await runCmd(`INSERT INTO Parking_Attendants (id, user_id, name, phone, address, hire_date) VALUES 
        (1, 2, 'Rahul Sharma', '+91 9876543210', 'Block-C, Sector 62, Noida, UP', '2026-01-10'),
        (2, 3, 'Ramesh Kumar', '+91 8765432109', 'Nai Sarak, Chandni Chowk, Delhi', '2026-02-15')`);

      await runCmd(`INSERT INTO Parking_Areas (id, name, location, slot_count, base_price) VALUES 
        (1, 'Basement A (General)', 'Basement Floor 1, North Block', 10, 20.00),
        (2, 'Ground Level B (VIP & EV)', 'Main Entrance Level, South Block', 5, 40.00),
        (3, 'Roof Deck C (Two-Wheeler)', 'Level 4 Open Air Deck', 15, 10.00)`);

      // Seed Slots
      for (let i = 1; i <= 10; i++) {
        let num = i < 10 ? `0${i}` : `${i}`;
        let status = (i === 1) ? 'Occupied' : (i === 4 ? 'Maintenance' : 'Available');
        await runCmd(`INSERT INTO Parking_Slots (area_id, slot_number, type, status) VALUES (1, 'A-${num}', 'Four-Wheeler', '${status}')`);
      }
      for (let i = 1; i <= 5; i++) {
        let status = (i === 1) ? 'Occupied' : (i === 5 ? 'Maintenance' : 'Available');
        let type = (i === 3 || i === 5) ? 'Heavy-Vehicle' : 'Four-Wheeler';
        await runCmd(`INSERT INTO Parking_Slots (area_id, slot_number, type, status) VALUES (2, 'B-0${i}', '${type}', '${status}')`);
      }
      for (let i = 1; i <= 15; i++) {
        let num = i < 10 ? `0${i}` : `${i}`;
        await runCmd(`INSERT INTO Parking_Slots (area_id, slot_number, type, status) VALUES (3, 'C-${num}', 'Two-Wheeler', 'Available')`);
      }

      await runCmd(`INSERT INTO Vehicles (id, license_plate, type, owner_name, owner_phone) VALUES 
        (1, 'DL3CAN1234', 'Four-Wheeler', 'Amit Patel', '+91 9999988888'),
        (2, 'HR26BR5678', 'Four-Wheeler', 'Sonia Sen', '+91 9898989898'),
        (3, 'MH02EE9999', 'Two-Wheeler', 'Rahul Bose', '+91 9797979797'),
        (4, 'KA03MM4321', 'Four-Wheeler', 'Vijay K', '+91 9696969696')`);

      // Seed Parking Records
      await runCmd(`INSERT INTO Parking_Records (id, vehicle_id, slot_id, attendant_id, entry_time, exit_time, calculated_fee, status) VALUES 
        (1, 1, 2, 2, '2026-05-29 09:00:00', '2026-05-29 12:15:00', 60.00, 'Completed'),
        (2, 3, 11, 3, '2026-05-29 10:30:00', '2026-05-29 11:10:00', 20.00, 'Completed'),
        (3, 2, 1, 2, '2026-05-29 18:30:00', NULL, 0.00, 'Active'),
        (4, 4, 11, 2, '2026-05-29 21:00:00', NULL, 0.00, 'Active')`);

      await runCmd(`INSERT INTO Payments (id, record_id, amount, payment_method, payment_date, transaction_id) VALUES 
        (1, 1, 60.00, 'Cash', '2026-05-29 12:16:00', 'TXN987654321'),
        (2, 2, 20.00, 'UPI', '2026-05-29 11:11:00', 'TXN876543210')`);
      
      console.log('✔ SQLite seeding completed successfully.');
    }
  } catch (err) {
    console.error('❌ SQLite Initialization Error:', err);
  }
}

// Perform Startup Connection Probe
(async () => {
  try {
    // Attempt standard connection pool check to MySQL
    pool = mysql.createPool({
      host: process.env.DB_HOST || '127.0.0.1',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASS || '',
      database: process.env.DB_NAME || 'smart_parking',
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      connectTimeout: 2000 // Quick timeout to failover fast
    });

    // Test a simple query to verify pool viability
    const connection = await pool.getConnection();
    connection.release();
    
    useSqlite = false;
    console.log('✔ Established connection with MySQL database pool successfully.');
  } catch (err) {
    // Failover directly to SQLite
    useSqlite = true;
    pool = mockPool;
    await initializeSqlite();
  }
})();

// Helper query function compatible with both pools
const query = async (sql, params) => {
  try {
    if (useSqlite) {
      const conn = new SqliteConnection(sqliteDb);
      const [rows] = await conn.execute(sql, params);
      return rows;
    } else {
      const [results] = await pool.execute(sql, params);
      return results;
    }
  } catch (err) {
    console.error('Database query error:', err);
    throw err;
  }
};

module.exports = {
  get pool() {
    return pool;
  },
  query
};
