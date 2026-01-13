const express = require('express'); // Restart trigger
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = 3007; // Forced for debugging

app.use(cors());
app.use(express.json());

// Request Logging Middleware
app.use((req, res, next) => {
    console.log(`[ShopService] Received: ${req.method} ${req.url} (original: ${req.originalUrl})`);
    next();
});

// DB Connection
const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

app.get('/health', async (req, res) => {
    try {
        await pool.query('SELECT 1');
        res.json({ status: 'Shop Service Running MODIFIED', db: 'Connected' });
    } catch (err) {
        res.status(500).json({ status: 'Shop Service Error', db: err.message });
    }
});

// Routes
const shopRoutes = require('./routes/shopRoutes');
const productRoutes = require('./routes/productRoutes');
const reviewRoutes = require('./routes/reviewRoutes');

// Mount routes on both /api/ and root paths to handle Gateway rewrite issues
app.use('/api/reviews', reviewRoutes);
app.use('/reviews', reviewRoutes);

app.use('/shops', shopRoutes);
app.use('/api/shops', shopRoutes); // Restore compatibility just in case

app.use('/api/products', productRoutes);
app.use('/products', productRoutes);

const categoryRoutes = require('./routes/categoryRoutes');
app.use('/api/categories', categoryRoutes);
app.use('/categories', categoryRoutes);


app.use(express.static('uploads'));

app.get('/debug-routes', (req, res) => {
    const routes = [];
    app._router.stack.forEach((middleware) => {
        if (middleware.route) { // routes registered directly on the app
            routes.push(middleware.route.path);
        } else if (middleware.name === 'router') { // router middleware 
            middleware.handle.stack.forEach((handler) => {
                if (handler.route) {
                    routes.push(handler.route.path);
                }
            });
        }
    });
    res.json(routes);
});

// Catch-all 404
app.use((req, res) => {
    console.error(`[ShopService] 404 Not Found: ${req.method} ${req.url}`);
    res.status(404).send(`ShopService: Cannot ${req.method} ${req.url}`);
});

app.get('/debug-routes', (req, res) => {
    const routes = [];
    app._router.stack.forEach((middleware) => {
        if (middleware.route) { // routes registered directly on the app
            routes.push(middleware.route.path);
        } else if (middleware.name === 'router') { // router middleware 
            middleware.handle.stack.forEach((handler) => {
                if (handler.route) {
                    routes.push(handler.route.path);
                }
            });
        }
    });
    res.json(routes);
});

app.listen(PORT, () => {
    console.log(`Shop Service running on port ${PORT}`);
});
