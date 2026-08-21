const express = require('express');
const { createOrder, getOrdersForUser } = require('../controllers/ordersController');

const router = express.Router();

router.post('/', createOrder);
router.get('/:userId', getOrdersForUser);

module.exports = router;
