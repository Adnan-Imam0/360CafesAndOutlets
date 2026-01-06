const express = require('express');
const router = express.Router();
const shopController = require('../controllers/shopController');

const upload = require('../middleware/uploadMiddleware');

router.post('/', upload.single('image'), shopController.createShop);
router.get('/', shopController.getAllShops);
router.get('/:id', shopController.getShopById);
router.put('/:id', upload.single('image'), shopController.updateShop);
router.get('/owner/:ownerId', shopController.getShopByOwnerId);

module.exports = router;
