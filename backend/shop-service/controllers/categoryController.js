const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

const createCategory = async (req, res) => {
    const { shop_id, name } = req.body;
    try {
        const query = 'INSERT INTO categories (shop_id, name) VALUES ($1, $2) RETURNING *';
        const result = await pool.query(query, [shop_id, name]);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to create category' });
    }
};

const getCategoriesByShop = async (req, res) => {
    const { shopId } = req.params;
    try {
        const result = await pool.query('SELECT * FROM categories WHERE shop_id = $1', [shopId]);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch categories' });
    }
};

module.exports = {
    createCategory,
    getCategoriesByShop
};
