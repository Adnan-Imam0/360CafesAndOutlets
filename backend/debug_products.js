const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

async function debugProducts() {
    try {
        console.log('--- Checking Tables ---');

        // 1. Check a few products
        const products = await pool.query('SELECT product_id, name, shop_id, category_id FROM products LIMIT 5');
        console.log('Products:', products.rows);

        // 2. Check categories
        const categories = await pool.query('SELECT * FROM categories LIMIT 5');
        console.log('Categories:', categories.rows);

        // 3. Test the Join Query used in Controller
        const shopId = products.rows[0]?.shop_id;
        if (shopId) {
            console.log(`\n--- Testing Join for Shop ${shopId} ---`);
            const query = `
                SELECT p.product_id, p.name, p.category_id, c.name as category 
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.category_id
                WHERE p.shop_id = $1
            `;
            const joinRes = await pool.query(query, [shopId]);
            console.log('Join Result:', joinRes.rows);
        } else {
            console.log('No products found to test join.');
        }

    } catch (err) {
        console.error(err);
    } finally {
        pool.end();
    }
}

debugProducts();
