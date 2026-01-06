const express = require('express'); // Restart trigger
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3003;

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
        res.json({ status: 'Shop Service Running', db: 'Connected' });
    } catch (err) {
        res.status(500).json({ status: 'Shop Service Error', db: err.message });
    }
});

// Routes
const shopRoutes = require('./routes/shopRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const productRoutes = require('./routes/productRoutes');

app.use('/shops', shopRoutes);
app.use('/categories', categoryRoutes);
app.use('/products', productRoutes);

app.listen(PORT, () => {
    console.log(`Shop Service running on port ${PORT}`);
});
