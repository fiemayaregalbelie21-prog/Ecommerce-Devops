const { pool } = require('../db/pool');

// Orders here represent a *record of checkout events* from the Flutter app.
// Product/price truth still comes from FakeStoreAPI; this backend just persists
// the user's order history server-side so it survives app reinstall/device change.

async function createOrder(req, res) {
  const { userId, items, total } = req.body;

  if (!userId || !Array.isArray(items) || items.length === 0 || typeof total !== 'number') {
    return res.status(400).json({
      error: 'Invalid payload. Expected { userId: number, items: array, total: number }',
    });
  }

  try {
    const result = await pool.query(
      `INSERT INTO orders (user_id, items, total, created_at)
       VALUES ($1, $2, $3, NOW())
       RETURNING id, user_id, items, total, created_at`,
      [userId, JSON.stringify(items), total]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('createOrder failed:', err);
    res.status(500).json({ error: 'Failed to create order' });
  }
}

async function getOrdersForUser(req, res) {
  const { userId } = req.params;

  try {
    const result = await pool.query(
      `SELECT id, user_id, items, total, created_at
       FROM orders
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId]
    );
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('getOrdersForUser failed:', err);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
}

module.exports = { createOrder, getOrdersForUser };
