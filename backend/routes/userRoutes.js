const express = require('express');
const router = express.Router();
const UserController = require('../controllers/userController');
const { validateUserRegistration, validateUserUpdate } = require('../middleware/validation');
const { upload } = require('../middleware/cloudinaryUpload');

// User routes
router.post('/register', validateUserRegistration, UserController.register);
router.get('/:id', UserController.getUserById);
router.put('/:id', upload.single('profile_picture'), validateUserUpdate, UserController.updateUser);
router.delete('/:id', UserController.deleteUser);
router.get('/', UserController.getAllUsers);
router.get('/search', UserController.searchUsers);
router.get('/city/:city', UserController.getUsersByCity);


module.exports = router;