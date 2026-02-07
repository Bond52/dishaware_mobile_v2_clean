const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema(
  {
    email: { type: String, trim: true, lowercase: true },
    authProvider: {
      type: String,
      enum: ['google', 'apple', 'email'],
      required: true,
    },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

module.exports = mongoose.model('User', UserSchema);
