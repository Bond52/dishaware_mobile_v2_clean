const express = require('express');
const profileRoutes = require('./routes/profileRoutes');

const app = express();

app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/profile', profileRoutes);

module.exports = app;
