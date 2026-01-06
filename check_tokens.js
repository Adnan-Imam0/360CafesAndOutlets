const { Pool } = require('pg');
require('dotenv').config({ path: 'backend/user-service/.env' }); // Load user-service env

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

async function checkTokens() {
    try {
        const res = await pool.query('SELECT customer_id, display_name, fcm_token FROM customers');
        console.log('Customer Tokens:', res.rows);
    } catch (e) {
        console.error(e);
    } finally {
        pool.end();
    }
}

checkTokens();
