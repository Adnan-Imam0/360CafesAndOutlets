const { Pool } = require('pg');
// const admin = require('../config/firebase');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

const verifyToken = async (idToken) => {
    // In real app: return await admin.auth().verifyIdToken(idToken);
    // Mock for development:
    return { uid: 'mock_firebase_uid_' + Date.now(), email: 'mock@example.com', phone_number: '+1234567890' };
};

const loginOrRegister = async (req, res) => {
    const { idToken, role } = req.body; // role: 'customer' or 'owner'

    try {
        const decodedToken = await verifyToken(idToken);
        const { uid, email, phone_number } = decodedToken;
        const firebase_uid = uid;

        let user;
        let table = role === 'owner' ? 'shop_owners' : 'customers';
        let idField = role === 'owner' ? 'owner_id' : 'customer_id';

        // Check if user exists
        const checkQuery = `SELECT * FROM ${table} WHERE firebase_uid = $1`;
        const checkResult = await pool.query(checkQuery, [firebase_uid]);

        if (checkResult.rows.length > 0) {
            user = checkResult.rows[0];
            return res.json({ message: 'Login successful', user });
        } else {
            // User needs to register (create profile)
            // Ideally we return a strict response saying "User not found, please register"
            // But if we want auto-register (barebones):
            return res.status(404).json({ message: 'User not found, please complete registration', firebase_uid, email, phone_number });
        }

    } catch (err) {
        console.error(err);
        res.status(401).json({ error: 'Invalid token' });
    }
};

const registerOwner = async (req, res) => {
    const { firebase_uid, email, username, first_name, last_name, phone, cnic, permanent_address, business_license_number, tax_id } = req.body;

    try {
        const query = `
            INSERT INTO shop_owners (firebase_uid, email, username, first_name, last_name, phone, cnic, permanent_address, business_license_number, tax_id)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            RETURNING *
        `;
        const values = [firebase_uid, email, username, first_name, last_name, phone, cnic, permanent_address, business_license_number, tax_id];
        const result = await pool.query(query, values);
        res.status(201).json({ message: 'Owner registered successfully', user: result.rows[0] });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Registration failed', details: err.message });
    }
};

const registerCustomer = async (req, res) => {
    const { firebase_uid, phone_number, display_name } = req.body;
    try {
        const query = `
            INSERT INTO customers (firebase_uid, phone_number, display_name)
            VALUES ($1, $2, $3)
            RETURNING *
        `;
        const result = await pool.query(query, [firebase_uid, phone_number, display_name]);
        res.status(201).json({ message: 'Customer registered successfully', user: result.rows[0] });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Registration failed', details: err.message });
    }
}

module.exports = {
    loginOrRegister,
    registerOwner,
    registerCustomer
};
