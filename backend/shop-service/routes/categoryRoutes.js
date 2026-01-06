const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');

router.post('/', categoryController.createCategory);
router.get('/shop/:shopId', categoryController.getCategoriesByShop);

module.exports = router;
