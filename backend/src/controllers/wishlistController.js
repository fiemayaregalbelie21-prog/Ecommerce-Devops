const { pool } = require('../db/pool');

// Wishlist sync: the Flutter app already persists the wishlist locally (Hive)
// for offline-first UX. This backend mirrors it server-side so it can be
// restored on a new device after login -- a realistic reason for a DB-backed
// service to exist alongside a mostly-FakeStoreAPI-driven app.

async function getWishlist(req, res) {
  const { userId } = req.params;
  try {
    const result = await pool.query(
      `SELECT product_id FROM wishlist_items WHERE user_id = $1 ORDER BY added_at DESC`,
      [userId]
    );
    res.status(200).json(result.rows.map((r) => r.product_id));
  } catch (err) {
    console.error('getWishlist failed:', err);
    res.status(500).json({ error: 'Failed to fetch wishlist' });
  }
}

async function addToWishlist(req, res) {
  const { userId } = req.params;
  const { productId } = req.body;

  if (typeof productId !== 'number') {
    return res.status(400).json({ error: 'Invalid payload. Expected { productId: number }' });
  }

  try {
    await pool.query(
      `INSERT INTO wishlist_items (user_id, product_id, added_at)
       VALUES ($1, $2, NOW())
       ON CONFLICT (user_id, product_id) DO NOTHING`,
      [userId, productId]
    );
    res.status(201).json({ userId: Number(userId), productId });
  } catch (err) {
    console.error('addToWishlist failed:', err);
    res.status(500).json({ error: 'Failed to add to wishlist' });
  }
}

async function removeFromWishlist(req, res) {
  const { userId, productId } = req.params;
  try {
    await pool.query(
      `DELETE FROM wishlist_items WHERE user_id = $1 AND product_id = $2`,
      [userId, productId]
    );
    res.status(204).send();
  } catch (err) {
    console.error('removeFromWishlist failed:', err);
    res.status(500).json({ error: 'Failed to remove from wishlist' });
  }
}

module.exports = { getWishlist, addToWishlist, removeFromWishlist };
