const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

const getCustomerProfile = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('SELECT * FROM customers WHERE customer_id = $1', [id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Customer not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch profile' });
    }
};

const getOwnerProfile = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('SELECT * FROM shop_owners WHERE owner_id = $1', [id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Owner not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch profile' });
    }
};

const addAddress = async (req, res) => {
    const { customer_id, address_label, full_address, city, postal_code, latitude, longitude, is_default } = req.body;
    try {
        const query = `
            INSERT INTO customer_addresses (customer_id, address_label, full_address, city, postal_code, latitude, longitude, is_default)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            RETURNING *
        `;
        const values = [customer_id, address_label, full_address, city, postal_code, latitude, longitude, is_default];
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to add address', details: err.message });
    }
};

const registerOwner = async (req, res) => {
    const {
        firebase_uid, email, username,
        first_name, last_name, phone, cnic, permanent_address
    } = req.body;

    try {
        const query = `
            INSERT INTO shop_owners (
                firebase_uid, email, username, 
                first_name, last_name, phone, cnic, permanent_address
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            RETURNING owner_id, firebase_uid, email, first_name;
        `;
        // Use email as default username if not provided
        const finalUsername = username || email.split('@')[0] + Math.floor(Math.random() * 1000);

        const values = [
            firebase_uid, email, finalUsername,
            first_name, last_name, phone, cnic, permanent_address
        ];

        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Register Owner Error:', err);
        if (err.code === '23505') { // Unique violation
            return res.status(409).json({ error: 'User already exists (Email/CNIC/Phone)' });
        }
        res.status(500).json({ error: 'Failed to register owner', details: err.message });
    }
};

const getAddresses = async (req, res) => {
    const { customerId } = req.params;
    try {
        const result = await pool.query('SELECT * FROM customer_addresses WHERE customer_id = $1 ORDER BY is_default DESC', [customerId]);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch addresses' });
    }
};

const getOwnerByFirebaseUid = async (req, res) => {
    const { uid } = req.params;
    try {
        const result = await pool.query('SELECT * FROM shop_owners WHERE firebase_uid = $1', [uid]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Owner not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch owner by UID' });
    }
};

const registerCustomer = async (req, res) => {
    const { firebase_uid, phone_number, display_name } = req.body;
    try {
        const query = `
            INSERT INTO customers (firebase_uid, phone_number, display_name)
            VALUES ($1, $2, $3)
            ON CONFLICT (firebase_uid) 
            DO UPDATE SET 
                phone_number = COALESCE(EXCLUDED.phone_number, customers.phone_number),
                display_name = COALESCE(EXCLUDED.display_name, customers.display_name)
            RETURNING *;
        `;
        const values = [firebase_uid, phone_number, display_name];
        const result = await pool.query(query, values);
        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error('Register Customer Error:', err);
        if (err.code === '23505') {
            return res.status(409).json({ error: 'Customer already exists' });
        }
        res.status(500).json({ error: 'Failed to register customer' });
    }
};

const getCustomerByFirebaseUid = async (req, res) => {
    const { uid } = req.params;
    try {
        const result = await pool.query('SELECT * FROM customers WHERE firebase_uid = $1', [uid]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Customer not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch customer by UID' });
    }
};

const updateCustomerProfile = async (req, res) => {
    const { id } = req.params;
    const { phone_number, display_name } = req.body;
    try {
        // Build dynamic query
        let query = 'UPDATE customers SET ';
        const values = [];
        let index = 1;

        if (phone_number) {
            query += `phone_number = $${index}, `;
            values.push(phone_number);
            index++;
        }
        if (display_name) {
            query += `display_name = $${index}, `;
            values.push(display_name);
            index++;
        }

        if (req.file) {
            query += `profile_picture_url = $${index}, `;
            values.push(req.file.path);
            index++;
        }

        // Remove trailing comma and space
        query = query.slice(0, -2);
        query += ` WHERE customer_id = $${index} RETURNING *`;
        values.push(id);

        const result = await pool.query(query, values);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Customer not found' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        console.error('Update Customer Error:', err);
        res.status(500).json({ error: 'Failed to update customer' });
    }
};

const updateFcmToken = async (req, res) => {
    const { uid } = req.params;
    const { fcm_token } = req.body;
    console.log(`[USER-SERVICE] Received FCM token update for ${uid}: ${fcm_token ? fcm_token.substring(0, 10) + '...' : 'null'}`);
    try {
        const query = 'UPDATE customers SET fcm_token = $1 WHERE firebase_uid = $2 RETURNING *';
        const result = await pool.query(query, [fcm_token, uid]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Customer not found' });
        }
        res.json({ message: 'FCM token updated', customer: result.rows[0] });
    } catch (err) {
        console.error('Update FCM Token Error:', err);
        res.status(500).json({ error: 'Failed to update FCM token' });
    }
};

module.exports = {
    getCustomerProfile,
    getOwnerProfile,
    addAddress,
    getAddresses,
    registerOwner,
    getOwnerByFirebaseUid,
    registerCustomer,
    getCustomerByFirebaseUid,
    updateCustomerProfile,
    updateFcmToken
};
