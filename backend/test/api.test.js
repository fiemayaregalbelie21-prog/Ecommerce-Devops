const { test } = require('node:test');
const assert = require('node:assert');
const request = require('supertest');
const app = require('../src/index');

test('GET /health returns a status field', async () => {
  const res = await request(app).get('/health');
  assert.ok(res.body.status === 'ok' || res.body.status === 'degraded');
});

test('POST /api/orders rejects an invalid payload', async () => {
  const res = await request(app).post('/api/orders').send({ userId: 1 });
  assert.strictEqual(res.status, 400);
});

test('POST /api/wishlist/:userId rejects a non-numeric productId', async () => {
  const res = await request(app).post('/api/wishlist/1').send({ productId: 'not-a-number' });
  assert.strictEqual(res.status, 400);
});

test('GET /unknown-route returns 404', async () => {
  const res = await request(app).get('/unknown-route');
  assert.strictEqual(res.status, 404);
});
