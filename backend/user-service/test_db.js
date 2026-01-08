const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

console.log(`Connecting to ${pool.options.host}:${pool.options.port}...`);

pool.query('SELECT NOW()', (err, res) => {
    if (err) {
        console.error('DB_ERROR:', err.code, err.message);
    } else {
        console.log('DB_SUCCESS:', res.rows[0]);
    }
    pool.end();
});
