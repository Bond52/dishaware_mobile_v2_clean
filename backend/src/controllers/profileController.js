const User = require('../models/User');
const UserProfile = require('../models/UserProfile');

const ACTIVITY_LEVELS = [
  'sedentary',
  'light',
  'moderate',
  'active',
  'very_active',
];

const sanitizeArray = (value) =>
  Array.isArray(value) ? value.map(String) : undefined;

const validateProfilePayload = (payload) => {
  const errors = [];
  const data = {};

  if (payload.firstName !== undefined) data.firstName = String(payload.firstName);
  if (payload.lastName !== undefined) data.lastName = String(payload.lastName);

  if (payload.dailyCalories !== undefined) {
    const parsed = Number(payload.dailyCalories);
    if (Number.isNaN(parsed)) {
      errors.push('dailyCalories doit être un nombre.');
    } else {
      data.dailyCalories = parsed;
    }
  }

  if (payload.allergies !== undefined) data.allergies = sanitizeArray(payload.allergies);
  if (payload.diets !== undefined) data.diets = sanitizeArray(payload.diets);
  if (payload.favoriteCuisines !== undefined) {
    data.favoriteCuisines = sanitizeArray(payload.favoriteCuisines);
  }
  if (payload.favoriteIngredients !== undefined) {
    data.favoriteIngredients = sanitizeArray(payload.favoriteIngredients);
  }

  if (payload.activityLevel !== undefined) {
    if (!ACTIVITY_LEVELS.includes(payload.activityLevel)) {
      errors.push('activityLevel invalide.');
    } else {
      data.activityLevel = payload.activityLevel;
    }
  }

  if (payload.orderFrequency !== undefined) {
    data.orderFrequency = String(payload.orderFrequency);
  }

  if (payload.hasCompletedOnboarding !== undefined) {
    data.hasCompletedOnboarding = Boolean(payload.hasCompletedOnboarding);
  }

  return { data, errors };
};

const ensureUser = async ({ userId, authProvider, email }) => {
  let user = await User.findById(userId);
  if (!user) {
    user = await User.create({
      _id: userId,
      email,
      authProvider: authProvider || 'email',
    });
  }
  return user;
};

const createOrReplaceProfile = async (req, res) => {
  try {
    const { data, errors } = validateProfilePayload(req.body);
    if (errors.length > 0) {
      return res.status(400).json({ error: 'VALIDATION_ERROR', details: errors });
    }

    await ensureUser({
      userId: req.userId,
      authProvider: req.authProvider,
      email: req.userEmail,
    });

    const profile = await UserProfile.findOneAndUpdate(
      { userId: req.userId },
      { ...data, userId: req.userId },
      { new: true, upsert: true, setDefaultsOnInsert: true }
    );

    return res.status(201).json(profile);
  } catch (error) {
    return res.status(500).json({ error: 'SERVER_ERROR', message: error.message });
  }
};

const getMyProfile = async (req, res) => {
  try {
    const profile = await UserProfile.findOne({ userId: req.userId });
    if (!profile) {
      return res.status(404).json({ error: 'NOT_FOUND' });
    }
    return res.json(profile);
  } catch (error) {
    return res.status(500).json({ error: 'SERVER_ERROR', message: error.message });
  }
};

const updateProfile = async (req, res) => {
  try {
    const { data, errors } = validateProfilePayload(req.body);
    if (errors.length > 0) {
      return res.status(400).json({ error: 'VALIDATION_ERROR', details: errors });
    }

    const profile = await UserProfile.findOneAndUpdate(
      { userId: req.userId },
      { $set: data },
      { new: true }
    );

    if (!profile) {
      return res.status(404).json({ error: 'NOT_FOUND' });
    }

    return res.json(profile);
  } catch (error) {
    return res.status(500).json({ error: 'SERVER_ERROR', message: error.message });
  }
};

const deleteProfile = async (req, res) => {
  try {
    await UserProfile.deleteOne({ userId: req.userId });
    return res.json({ success: true });
  } catch (error) {
    return res.status(500).json({ error: 'SERVER_ERROR', message: error.message });
  }
};

module.exports = {
  createOrReplaceProfile,
  getMyProfile,
  updateProfile,
  deleteProfile,
};
