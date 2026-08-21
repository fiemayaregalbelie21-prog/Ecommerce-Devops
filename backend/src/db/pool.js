const { Pool } = require('pg');

// Connection settings are pulled entirely from environment variables so the
// same image works locally, in Docker Compose, and in CI without code changes.
// In docker-compose.yml, DB_HOST is set to the Postgres *service name* ("db"),
// which Docker's internal DNS resolves to the database container's address.
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'ecommerce',
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

pool.on('error', (err) => {
  // Prevents an idle client error from crashing the whole process.
  console.error('Unexpected error on idle Postgres client', err);
});

async function waitForDb(retries = 10, delayMs = 2000) {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      await pool.query('SELECT 1');
      console.log('Connected to Postgres');
      return;
    } catch (err) {
      console.log(`Postgres not ready (attempt ${attempt}/${retries}): ${err.message}`);
      await new Promise((res) => setTimeout(res, delayMs));
    }
  }
  throw new Error('Could not connect to Postgres after multiple retries');
}

module.exports = { pool, waitForDb };
