const express = require('express');
const mockAuth = require('../middleware/mockAuth');
const {
  createOrReplaceProfile,
  getMyProfile,
  updateProfile,
  deleteProfile,
} = require('../controllers/profileController');

const router = express.Router();

router.use(mockAuth);

router.post('/', createOrReplaceProfile);
router.get('/me', getMyProfile);
router.put('/', updateProfile);
router.delete('/', deleteProfile);

module.exports = router;
