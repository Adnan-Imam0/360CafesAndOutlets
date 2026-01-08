const { Pool } = require('pg');
require('dotenv').config({ path: './shop-service/.env' });

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

async function debug() {
    try {
        console.log('--- Categories ---');
        const cats = await pool.query('SELECT * FROM categories');
        console.table(cats.rows);

        console.log('\n--- Products (shop_id 1) ---');
        const prods = await pool.query('SELECT product_id, name, category_id, shop_id FROM products LIMIT 10');
        console.table(prods.rows);

        console.log('\n--- Join Test ---');
        const joinQuery = `
            SELECT p.product_id, p.name, p.category_id, c.category_id as joined_cat_id, c.name as category_name
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.category_id
        `;
        const joinRes = await pool.query(joinQuery);
        console.table(joinRes.rows);

    } catch (e) {
        console.error(e);
    } finally {
        pool.end();
    }
}

debug();
