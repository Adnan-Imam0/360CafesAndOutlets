const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

// GET /api/shops/:shopId/reviews
const getShopReviews = async (req, res) => {
    const { shopId } = req.params;
    try {
        const query = `
            SELECT * FROM reviews 
            WHERE shop_id = $1 
            ORDER BY created_at DESC
        `;
        const result = await pool.query(query, [shopId]);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch reviews' });
    }
};

// POST /api/reviews (For Customer App / Seeding)
const createReview = async (req, res) => {
    const { shop_id, product_id, customer_id, customer_name, rating, comment } = req.body;
    try {
        const query = `
            INSERT INTO reviews (shop_id, product_id, customer_id, customer_name, rating, comment)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING *
        `;
        const values = [shop_id, product_id, customer_id, customer_name, rating, comment];
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to create review' });
    }
};

module.exports = {
    getShopReviews,
    createReview
};
