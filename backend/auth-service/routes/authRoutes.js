const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/login', authController.loginOrRegister);
router.post('/register/owner', authController.registerOwner);
router.post('/register/customer', authController.registerCustomer);

module.exports = router;
