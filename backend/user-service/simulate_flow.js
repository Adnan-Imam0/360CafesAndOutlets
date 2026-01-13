const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

async function simulateFlow() {
    const client = await pool.connect();
    try {
        console.log('--- START SIMULATION ---');

        // 1. Setup: Ensure user exists but shop does not (Simulate "User already exists" scenario)
        const email = 'fahadrahimnigwari@gmail.com';
        console.log(`Checking user: ${email}`);

        let ownerRes = await client.query('SELECT * FROM shop_owners WHERE email = $1', [email]);
        let ownerId;

        if (ownerRes.rows.length === 0) {
            console.log('Creating owner for test...');
            const insertRes = await client.query(`
                INSERT INTO shop_owners (
                    firebase_uid, email, username, first_name, last_name, phone, cnic, permanent_address
                ) VALUES (
                    $1, $2, $3, $4, $5, $6, $7, $8
                ) RETURNING owner_id
            `, ['test_uid_123', email, 'fahad_test', 'Fahad', 'Rahim', '03001234567', '1234512345671', 'Test Address']);
            ownerId = insertRes.rows[0].owner_id;
            console.log(`Created owner with ID: ${ownerId}`);
        } else {
            ownerId = ownerRes.rows[0].owner_id;
            console.log(`Owner exists with ID: ${ownerId}`);
        }

        // Delete any existing shop for this owner to simulate "Create Shop" flow
        await client.query('DELETE FROM shops WHERE owner_id = $1', [ownerId]);
        console.log('Cleared existing shops for this owner.');

        // 2. Simulate Frontend Logic in Backend (Pseudocode execution)
        console.log('\n--- EXECUTING FRONTEND LOGIC SIMULATION ---');

        // Step A: Try to Register Owner (Should fail with conflict)
        console.log('Attempting to register owner (Duplicate)...');
        try {
            await client.query(`
                INSERT INTO shop_owners (
                    firebase_uid, email, username, first_name, last_name, phone, cnic, permanent_address
                ) VALUES (
                    $1, $2, $3, $4, $5, $6, $7, $8
                )
            `, ['test_uid_123', email, 'fahad_test', 'Fahad', 'Rahim', '03001234567', '1234512345671', 'Test Address']);
        } catch (e) {
            if (e.code === '23505') {
                console.log('SUCCESS: Caught expected Unique Violation (409 Conflict).');
            } else {
                console.log('UNEXPECTED ERROR:', e);
            }
        }

        // Step B: Fetch Existing Owner (Fallback)
        console.log('Fetching existing owner by Firebase UID...');
        const fetchRes = await client.query('SELECT * FROM shop_owners WHERE firebase_uid = $1', ['test_uid_123']);
        if (fetchRes.rows.length > 0) {
            console.log(`SUCCESS: Fetched existing owner ID: ${fetchRes.rows[0].owner_id}`);

            // Step C: Create Shop
            console.log('Creating Shop...');
            const shopRes = await client.query(`
                INSERT INTO shops (owner_id, shop_name, shop_type, address, phone_number, status)
                VALUES ($1, $2, $3, $4, $5, $6)
                RETURNING shop_id;
            `, [fetchRes.rows[0].owner_id, 'Fahad Cafe', 'Cafe', 'Test Address', '03001234567', 'pending']);

            console.log(`SUCCESS: Shop created with ID: ${shopRes.rows[0].shop_id}`);
        } else {
            console.log('FAILURE: Could not fetch existing owner.');
        }

    } catch (err) {
        console.error('Simulation Error:', err);
    } finally {
        client.release();
        pool.end();
    }
}

simulateFlow();
