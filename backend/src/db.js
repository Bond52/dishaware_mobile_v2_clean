const mongoose = require('mongoose');

const connectDB = async () => {
  if (!process.env.MONGO_URI) {
    throw new Error('MONGO_URI manquant dans les variables d’environnement.');
  }

  await mongoose.connect(process.env.MONGO_URI);
};

module.exports = connectDB;
