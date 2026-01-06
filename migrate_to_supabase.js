const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Connection String from User (Removing brackets from password if present)
// User sent: postgresql://postgres:[Cafeandoutle]@...
// Assuming password is 'Cafeandoutle'
const connectionString = 'postgresql://postgres:Cafeandoutle@db.vzbkiglixzwyzywyptcg.supabase.co:5432/postgres';

const client = new Client({
    connectionString: connectionString,
    ssl: { rejectUnauthorized: false } // Required for Supabase/Heroku/Render usually
});

async function migrate() {
    try {
        console.log('Connecting to Supabase...');
        await client.connect();
        console.log('Connected!');

        const sqlPath = path.join(__dirname, 'init.sql');
        const sql = fs.readFileSync(sqlPath, 'utf8');

        console.log('Running init.sql...');
        await client.query(sql);

        console.log('Migration Successful! Tables created.');
    } catch (err) {
        console.error('Migration Failed:', err);
    } finally {
        await client.end();
    }
}

migrate();
