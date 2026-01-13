const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

async function checkImages() {
    try {
        const res = await pool.query('SELECT shop_id, shop_name, profile_picture_url FROM shops');

        console.log('\n--- Shop Image Audit ---');
        res.rows.forEach(shop => {
            let status = 'OK';
            const url = shop.profile_picture_url;

            if (!url) status = 'MISSING';
            else if (url.includes('via.placeholder.com')) status = 'PLACEHOLDER';
            else if (!url.startsWith('http')) status = 'INVALID (Local Path?)';

            console.log(`[${shop.shop_id}] ${shop.shop_name}: [${status}]`);
            console.log(`      URL: ${url ? url.substring(0, 60) + '...' : 'null'}`);
        });

    } catch (err) {
        console.error(err);
    } finally {
        pool.end();
    }
}

checkImages();
