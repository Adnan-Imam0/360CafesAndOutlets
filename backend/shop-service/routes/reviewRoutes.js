const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');

console.log('[DEBUG] reviewRoutes loaded');

// Debug Ping
router.get('/ping', (req, res) => {
    console.log('[DEBUG] GET /ping hit');
    res.send('pong');
});

// Define Review Routes
router.get('/shop/:shopId', (req, res, next) => {
    console.log(`[DEBUG] GET /shop/${req.params.shopId} hit`);
    next();
}, reviewController.getShopReviews);
router.post('/', reviewController.createReview);

module.exports = router;
