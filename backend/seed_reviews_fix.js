const { Pool } = require('pg');
require('dotenv').config({ path: './shop-service/.env' });

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

async function seedClean() {
    try {
        console.log("🔍 Fetching existing shop...");
        const shopRes = await pool.query('SELECT shop_id, shop_name FROM shops LIMIT 1');

        if (shopRes.rows.length === 0) {
            console.log("❌ No shops found! Cannot seed reviews.");
            return;
        }

        const shop = shopRes.rows[0];
        console.log(`✅ Found shop: ${shop.shop_name} (ID: ${shop.shop_id})`);

        // Insert reviews for this specific shop ID
        const seedQuery = `
            INSERT INTO reviews (shop_id, customer_id, customer_name, rating, comment)
            VALUES 
            ($1, 'dummy_user_1', 'Alice Johnson', 5, 'Amazing food! Best burger on campus.'),
            ($1, 'dummy_user_2', 'Bob Smith', 4, 'Great service, but a bit pricey.'),
            ($1, 'dummy_user_3', 'Charlie', 5, 'Love the coffee here! ☕')
            RETURNING *;
        `;

        const res = await pool.query(seedQuery, [shop.shop_id]);
        console.log(`✅ Successfully seeded ${res.rowCount} reviews for shop ${shop.shop_id}.`);

    } catch (e) {
        console.error("❌ Error seeding reviews:", e);
    } finally {
        pool.end();
    }
}

seedClean();
