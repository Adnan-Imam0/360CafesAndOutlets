const { Pool } = require('pg');
require('dotenv').config({ path: './shop-service/.env' });

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

async function createTable() {
    try {
        const query = `
            CREATE TABLE IF NOT EXISTS reviews (
                review_id SERIAL PRIMARY KEY,
                shop_id INTEGER REFERENCES shops(shop_id),
                product_id INTEGER REFERENCES products(product_id),
                customer_id VARCHAR(255) NOT NULL, -- Firebase UID reference
                customer_name VARCHAR(255),        -- Cache name for display
                rating INTEGER CHECK (rating >= 1 AND rating <= 5),
                comment TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `;
        await pool.query(query);
        console.log("✅ 'reviews' table created successfully.");

        // Seed some dummy data if empty
        const countRes = await pool.query('SELECT COUNT(*) FROM reviews');
        if (parseInt(countRes.rows[0].count) === 0) {
            console.log("🌱 Seeding dummy reviews...");
            const seedQuery = `
                INSERT INTO reviews (shop_id, customer_id, customer_name, rating, comment)
                VALUES 
                (1, 'dummy_user_1', 'Alice Johnson', 5, 'Amazing food! Best burger on campus.'),
                (1, 'dummy_user_2', 'Bob Smith', 4, 'Great service, but a bit pricey.'),
                (1, 'dummy_user_3', 'Charlie', 5, 'Love the coffee here! ☕');
            `;
            // Note: I'm hardcoding shop_id 1. Ideally I'd fetch one, but this is quick verification.
            try {
                await pool.query(seedQuery);
                console.log("✅ Dummy reviews added.");
            } catch (err) {
                console.log("⚠️ Could not seed (maybe shop_id 1 doesn't exist). Skipping seed.");
            }
        }

    } catch (e) {
        console.error("❌ Error creating table:", e);
    } finally {
        pool.end();
    }
}

createTable();
