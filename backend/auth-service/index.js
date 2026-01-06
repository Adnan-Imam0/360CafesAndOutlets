const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
    res.json({ status: 'Auth Service Running' });
});

// Routes
const authRoutes = require('./routes/authRoutes');
app.use('/', authRoutes);

app.listen(PORT, () => {
    console.log(`Auth Service running on port ${PORT}`);
});
