const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

const createProduct = async (req, res) => {
    const { shop_id, category_id, name, description, price, is_available } = req.body;
    let { image_url } = req.body;
    if (req.file) {
        image_url = req.file.path;
    }
    try {
        const query = `
            INSERT INTO products (shop_id, category_id, name, description, price, image_url, is_available)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING *
        `;
        const values = [shop_id, category_id, name, description, price, image_url, is_available !== undefined ? is_available : true];
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to create product' });
    }
};

const getProductsByShop = async (req, res) => {
    const { shopId } = req.params;
    try {
        const result = await pool.query('SELECT * FROM products WHERE shop_id = $1', [shopId]);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch products' });
    }
};

const getProductsByCategory = async (req, res) => {
    const { categoryId } = req.params;
    try {
        const result = await pool.query('SELECT * FROM products WHERE category_id = $1', [categoryId]);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch products' });
    }
};

const updateProduct = async (req, res) => {
    const { id } = req.params;
    const { shop_id, category_id, name, description, price, is_available } = req.body;
    let { image_url } = req.body;
    if (req.file) {
        image_url = req.file.path;
    }
    try {
        const query = `
            UPDATE products
            SET shop_id = $1, category_id = $2, name = $3, description = $4, price = $5, image_url = $6, is_available = $7
            WHERE product_id = $8
            RETURNING *
        `;
        const values = [shop_id, category_id, name, description, price, image_url, is_available, id];
        const result = await pool.query(query, values);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Product not found' });
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update product' });
    }
};

const deleteProduct = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('DELETE FROM products WHERE product_id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Product not found' });
        }
        res.json({ message: 'Product deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to delete product' });
    }
};

module.exports = {
    createProduct,
    getProductsByShop,
    getProductsByCategory,
    updateProduct,
    deleteProduct
};
