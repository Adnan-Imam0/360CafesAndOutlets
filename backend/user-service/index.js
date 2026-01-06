const express = require('express'); // Restart trigger
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3002;

app.use(cors());
app.use(express.json());

// DB Connection
const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

app.get('/health', async (req, res) => {
    try {
        await pool.query('SELECT 1');
        res.json({ status: 'User Service Running', db: 'Connected' });
    } catch (err) {
        res.status(500).json({ status: 'User Service Error', db: err.message });
    }
});

// Routes
const userRoutes = require('./routes/userRoutes');
app.use('/', userRoutes);

app.listen(PORT, () => {
    console.log(`User Service running on port ${PORT}`);
});
