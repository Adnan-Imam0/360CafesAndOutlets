const express = require('express');
const router = express.Router();
const shopController = require('../controllers/shopController');
const upload = require('../middleware/uploadMiddleware');

// Simple Logging
router.use((req, res, next) => {
    console.error(`[ShopRouter] Entering. Method: ${req.method} URL: "${req.url}"`);
    next();
});

// Toggle Shop Status
router.patch('/:id/status', shopController.toggleShopStatus);

// Shop CRUD
router.post('/', upload.single('image'), shopController.createShop);
router.get('/', shopController.getAllShops);
router.get('/owner/:ownerId', shopController.getShopByOwnerId);
router.get('/:id', shopController.getShopById);
router.put('/:id', upload.single('image'), shopController.updateShop);

module.exports = router;
