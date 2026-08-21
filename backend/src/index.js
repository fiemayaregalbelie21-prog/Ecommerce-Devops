require('dotenv').config();
const express = require('express');
const cors = require('cors');

const { waitForDb } = require('./db/pool');
const healthRoutes = require('./routes/health');
const orderRoutes = require('./routes/orders');
const wishlistRoutes = require('./routes/wishlist');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

app.use('/health', healthRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/wishlist', wishlistRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

async function start() {
  // Don't accept traffic until the DB is reachable - avoids a thundering herd
  // of failed requests during container startup when Postgres is still booting.
  await waitForDb();
  app.listen(PORT, () => {
    console.log(`Backend listening on port ${PORT}`);
  });
}

// Only auto-start the server when run directly (not when imported by tests).
if (require.main === module) {
  start().catch((err) => {
    console.error('Failed to start server:', err);
    process.exit(1);
  });
}

module.exports = app;
