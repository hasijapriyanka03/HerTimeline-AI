const low = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');
const path = require('path');
const fs = require('fs');

// Ensure data directory exists
const dataDir = path.join(__dirname, '../../data');
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
  console.log('Created data directory:', dataDir);
}

// Database file path
const dbPath = path.join(dataDir, 'db.json');

// Create empty db.json if it doesn't exist
if (!fs.existsSync(dbPath)) {
  fs.writeFileSync(dbPath, JSON.stringify({
    users: [],
    userProfiles: [],
    menstruationLogs: [],
    cycleData: [],
    pregnancyProfiles: [],
    pregnancyLogs: [],
    dailyLogs: [],
    menopauseLogs: [],
    fcmTokens: [],
    appointments: [],
    userWallets: [],
    streaks: [],
    vouchers: [],
    userVouchers: [],
  }, null, 2));
  console.log('Created database file:', dbPath);
}

// Create database adapter
const adapter = new FileSync(dbPath);
const db = low(adapter);

// Initialize database with default structure (if empty)
db.defaults({
  users: [],
  userProfiles: [],
  menstruationLogs: [],
  cycleData: [],
  pregnancyProfiles: [],
  pregnancyLogs: [],
  dailyLogs: [],
  menopauseLogs: [],
  fcmTokens: [],
  appointments: [],
  userWallets: [],
  streaks: [],
  vouchers: [],
  userVouchers: [],
}).write();

console.log('Database initialized successfully');

module.exports = db;
