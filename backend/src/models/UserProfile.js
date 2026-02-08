const mongoose = require('mongoose');

const UserProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    firstName: { type: String, trim: true },
    lastName: { type: String, trim: true },
    dailyCalories: { type: Number, default: 2000 },
    allergies: { type: [String], default: [] },
    diets: { type: [String], default: [] },
    favoriteCuisines: { type: [String], default: [] },
    favoriteIngredients: { type: [String], default: [] },
    activityLevel: {
      type: String,
      enum: ['sedentary', 'light', 'moderate', 'active', 'very_active'],
    },
    orderFrequency: { type: String },
    hasCompletedOnboarding: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model('UserProfile', UserProfileSchema);
