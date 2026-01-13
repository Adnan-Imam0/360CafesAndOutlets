const { Pool } = require('pg');
const fs = require('fs');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

const emailToCheck = 'fahadrahimnigwari@gmail.com';
const logFile = 'check_log.txt';

function log(message) {
    console.log(message);
    fs.appendFileSync(logFile, message + '\n');
}

// Clear log file
if (fs.existsSync(logFile)) fs.unlinkSync(logFile);

async function checkUser() {
    try {
        log(`Checking for user with email: ${emailToCheck}`);

        // Check shop_owners
        const ownerRes = await pool.query('SELECT * FROM shop_owners WHERE email = $1', [emailToCheck]);

        if (ownerRes.rows.length > 0) {
            log('User found in shop_owners table:');
            log(JSON.stringify(ownerRes.rows[0], null, 2));
        } else {
            log('User NOT found in shop_owners table.');
        }

        // Just in case, check if there is an email column in customers
        try {
            const customerRes = await pool.query('SELECT * FROM customers LIMIT 1');
            if (customerRes.rows.length > 0) {
                const columns = Object.keys(customerRes.rows[0]);
                if (columns.includes('email')) {
                    const customerEmailRes = await pool.query('SELECT * FROM customers WHERE email = $1', [emailToCheck]);
                    if (customerEmailRes.rows.length > 0) {
                        log('User found in customers table:');
                        log(JSON.stringify(customerEmailRes.rows[0], null, 2));
                    } else {
                        log('User NOT found in customers table (checked email column).');
                    }
                } else {
                    log('customers table does not appear to have an email column.');
                }
            } else {
                log('customers table is empty.');
            }
        } catch (e) {
            log('Error checking customers table: ' + e.message);
        }

    } catch (err) {
        log('Error executing query: ' + err);
    } finally {
        pool.end();
    }
}

checkUser();
