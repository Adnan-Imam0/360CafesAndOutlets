const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
const dns = require('dns');

const hostname = 'db.vzbkiglixzwyzywyptcg.supabase.co';
const password = 'Cafeandoutle'; // No brackets

async function migrate() {
    try {
        console.log(`Resolving ${hostname}...`);

        // Force IPv4 lookup
        dns.lookup(hostname, { family: 4 }, async (err, address) => {
            if (err) {
                console.error('DNS Lookup Failed:', err);
                return;
            }
            console.log(`Resolved to IP: ${address}`);

            // Construct connection string with IP but set SNI (Server Name Indication) for SSL
            // Note: Supabase might reject direct IP connection if SNI isn't set correctly in SSL options.
            // Let's try standard connection first but knowing resolutions works.

            const client = new Client({
                host: hostname, // PG Client will resolve it again, but let's confirm environment can do it.
                // If this fails, we can use 'host: address' and 'ssl: { servername: hostname }'
                port: 5432,
                user: 'postgres',
                password: password,
                database: 'postgres',
                ssl: { rejectUnauthorized: false }
            });

            console.log('Connecting to Postgres...');
            await client.connect();
            console.log('Connected! Running init.sql...');

            const sqlPath = path.join(__dirname, 'init.sql');
            const sql = fs.readFileSync(sqlPath, 'utf8');

            await client.query(sql);
            console.log('Migration Successful! Tables created.');
            await client.end();
        });

    } catch (err) {
        console.error('Migration Failed:', err);
    }
}

migrate();
