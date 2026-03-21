const mongoose = require('mongoose');

const getIdFromAuthHeader = (header) => {
  if (!header) return null;
  const [type, token] = header.split(' ');
  if (type?.toLowerCase() !== 'bearer') return null;
  return token || null;
};

/** Un JWT n’est pas un ObjectId : ne jamais le prendre comme req.userId si x-user-id est valide. */
const pickObjectId = (...candidates) => {
  for (const id of candidates) {
    if (id && mongoose.Types.ObjectId.isValid(id)) {
      return id;
    }
  }
  return null;
};

const looksLikeJwt = (s) =>
  typeof s === 'string' &&
  s.split('.').length === 3 &&
  s.length > 40;

const mockAuth = (req, res, next) => {
  const headerUserId = req.header('x-user-id');
  const bearerId = getIdFromAuthHeader(req.header('authorization'));
  const envId = process.env.MOCK_USER_ID;

  // Priorité : ObjectId dans x-user-id, Bearer (si OID), env — sinon x-user-id « opaque » (mock_, UUID…)
  let userId = pickObjectId(headerUserId, bearerId, envId);
  if (!userId && headerUserId) {
    const h = String(headerUserId).trim();
    if (h.length > 0 && !looksLikeJwt(h)) {
      userId = h;
    }
  }

  if (!userId) {
    const hasAnyHint = Boolean(headerUserId || bearerId || envId);
    if (!hasAnyHint) {
      return res.status(401).json({
        error: 'AUTH_REQUIRED',
        message: 'Ajoutez un token ou un x-user-id (mock).',
      });
    }
    return res.status(400).json({
      error: 'INVALID_USER_ID',
      message: 'x-user-id invalide',
    });
  }

  req.userId = userId;
  req.authProvider = req.header('x-auth-provider') || 'email';
  req.userEmail = req.header('x-user-email');

  return next();
};

module.exports = mockAuth;
