const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

const createShop = async (req, res) => {
    const { owner_id, shop_name, shop_type, address, phone_number } = req.body;
    let { profile_picture_url } = req.body;
    if (req.file) {
        profile_picture_url = req.file.path;
    }
    try {
        const query = `
            INSERT INTO shops (owner_id, shop_name, shop_type, address, phone_number, profile_picture_url)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING *;
        `;
        const values = [owner_id, shop_name, shop_type, address, phone_number, profile_picture_url];
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to create shop' });
    }
};

const getAllShops = async (req, res) => {
    const { search, type } = req.query;
    try {
        let query = `
            SELECT s.*, 
                   COALESCE(AVG(r.rating), 0) as average_rating, 
                   COUNT(r.review_id) as review_count
            FROM shops s
            LEFT JOIN reviews r ON s.shop_id = r.shop_id
            WHERE 1=1
        `;
        const values = [];
        let valueIndex = 1;

        if (search) {
            query += ` AND s.shop_name ILIKE $${valueIndex}`;
            values.push(`%${search}%`);
            valueIndex++;
        }

        if (type && type !== 'All') {
            query += ` AND s.shop_type ILIKE $${valueIndex}`;
            values.push(type);
            valueIndex++;
        }

        query += `
            GROUP BY s.shop_id
            ORDER BY s.shop_id ASC;
        `;

        const result = await pool.query(query, values);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch shops' });
    }
};

const getShopById = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('SELECT * FROM shops WHERE shop_id = $1', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Shop not found' });
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch shop' });
    }
};

const getShopByOwnerId = async (req, res) => {
    const { ownerId } = req.params;
    try {
        const result = await pool.query('SELECT * FROM shops WHERE owner_id = $1', [ownerId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Shop not found for this owner' });
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch shop by owner' });
    }
};

const updateShop = async (req, res) => {
    const { id } = req.params;
    const { shop_name, address, phone_number } = req.body;
    let { profile_picture_url } = req.body;
    if (req.file) {
        profile_picture_url = req.file.path;
    }
    try {
        const query = `
            UPDATE shops 
            SET shop_name = $1, address = $2, phone_number = $3, profile_picture_url = $4
            WHERE shop_id = $5
            RETURNING *;
        `;
        const values = [shop_name, address, phone_number, profile_picture_url, id];
        const result = await pool.query(query, values);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Shop not found' });
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update shop' });
    }
};

const toggleShopStatus = async (req, res) => {
    console.error(`[ShopController] toggleShopStatus hit. Params: ${JSON.stringify(req.params)} Body: ${JSON.stringify(req.body)}`);
    const { id } = req.params;
    const { is_open } = req.body;

    try {
        const query = `
            UPDATE shops 
            SET is_open = $1
            WHERE shop_id = $2
            RETURNING *;
        `;
        const values = [is_open, id];
        const result = await pool.query(query, values);

        console.error(`[ShopController] DB Result: ${JSON.stringify(result.rows)}`);

        if (result.rows.length === 0) {
            console.error('[ShopController] Shop not found in DB');
            return res.status(404).json({ error: 'Shop not found' });
        }

        console.error('[ShopController] Sending success response...');
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update shop status' });
    }
};

module.exports = {
    createShop,
    getAllShops,
    getShopById,
    getShopByOwnerId,
    updateShop,
    toggleShopStatus
};
