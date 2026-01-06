const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const upload = require('../middleware/uploadMiddleware');

router.get('/customer/:id', userController.getCustomerProfile);
router.get('/owner/:id', userController.getOwnerProfile);
router.get('/owner/firebase/:uid', userController.getOwnerByFirebaseUid);
router.post('/owner', userController.registerOwner);
router.post('/address', userController.addAddress);
router.get('/address/customer/:customerId', userController.getAddresses);
router.post('/customer', userController.registerCustomer);
router.put('/customer/:id', upload.single('image'), userController.updateCustomerProfile);
router.get('/customer/firebase/:uid', userController.getCustomerByFirebaseUid);
router.patch('/customers/:uid/fcm', userController.updateFcmToken);


module.exports = router;
