const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');

router.post('/', orderController.createOrder);
router.get('/customer/:customerId', orderController.getOrdersByCustomer);
router.get('/shop/:shopId', orderController.getOrdersByShop);
router.get('/:id', orderController.getOrderById);
router.patch('/:id/status', orderController.updateOrderStatus);
router.get('/analytics/shop/:shopId', orderController.getShopStats);

module.exports = router;
