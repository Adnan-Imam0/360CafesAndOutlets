const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

async function checkUser(email) {
    try {
        console.log(`Checking for user with email: ${email}`);

        const ownerRes = await pool.query('SELECT * FROM shop_owners WHERE email = $1', [email]);
        if (ownerRes.rows.length > 0) {
            console.log('FOUND_OWNER:', JSON.stringify(ownerRes.rows[0]));

            const ownerId = ownerRes.rows[0].owner_id;
            const shopRes = await pool.query('SELECT * FROM shops WHERE owner_id = $1', [ownerId]);

            if (shopRes.rows.length > 0) {
                console.log('FOUND_SHOP:', JSON.stringify(shopRes.rows[0]));
            } else {
                console.log('NO_SHOP_FOUND');
            }
        } else {
            console.log('OWNER_NOT_FOUND');
        }

    } catch (err) {
        console.error('DB_ERROR:', err);
    } finally {
        await pool.end();
    }
}

checkUser('adnanimam07@gmail.com');
