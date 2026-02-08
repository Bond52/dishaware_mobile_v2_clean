require('dotenv').config();

const app = require('./app');
const connectDB = require('./db');

const PORT = process.env.PORT || 4000;

const startServer = async () => {
  try {
    await connectDB();
    app.listen(PORT, () => {
      console.log(`API démarrée sur le port ${PORT}`);
    });
  } catch (error) {
    console.error('Erreur au démarrage de l’API:', error);
    process.exit(1);
  }
};

startServer();
