const mongoose = require('mongoose');

const getIdFromAuthHeader = (header) => {
  if (!header) return null;
  const [type, token] = header.split(' ');
  if (type?.toLowerCase() !== 'bearer') return null;
  return token || null;
};

const mockAuth = (req, res, next) => {
  const headerUserId = req.header('x-user-id');
  const bearerId = getIdFromAuthHeader(req.header('authorization'));
  const envId = process.env.MOCK_USER_ID;

  const userId = bearerId || headerUserId || envId;
  if (!userId) {
    return res.status(401).json({
      error: 'AUTH_REQUIRED',
      message: 'Ajoutez un token ou un x-user-id (mock).',
    });
  }

  if (!mongoose.Types.ObjectId.isValid(userId)) {
    return res.status(400).json({
      error: 'INVALID_USER_ID',
      message: 'Le userId doit être un ObjectId Mongo valide.',
    });
  }

  req.userId = userId;
  req.authProvider = req.header('x-auth-provider') || 'email';
  req.userEmail = req.header('x-user-email');

  return next();
};

module.exports = mockAuth;
