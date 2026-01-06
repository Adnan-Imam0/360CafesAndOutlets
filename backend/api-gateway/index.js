const express = require('express');
const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());

// Health Check
app.get('/health', (req, res) => {
    res.json({ status: 'API Gateway Running' });
});

// Proxy Routes
// Auth Service
app.use('/auth', createProxyMiddleware({
    target: process.env.AUTH_SERVICE_URL || 'http://127.0.0.1:3001',
    changeOrigin: true
}));

// User Service
app.use('/users', createProxyMiddleware({
    target: process.env.USER_SERVICE_URL || 'http://127.0.0.1:3002',
    changeOrigin: true
}));

// Shop Service (Shops & Products)
// Shop Service (Shops & Products)
app.use('/shops', createProxyMiddleware({
    // Shop Service expects /shops because it mounts app.use('/shops', ...)
    target: (process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3003') + '/shops',
    changeOrigin: true
}));
app.use('/products', createProxyMiddleware({
    target: (process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3003') + '/products',
    changeOrigin: true
}));
app.use('/categories', createProxyMiddleware({
    target: (process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3003') + '/categories',
    changeOrigin: true
}));

// Order Service
app.use('/orders', createProxyMiddleware({
    target: process.env.ORDER_SERVICE_URL || 'http://127.0.0.1:3005',
    changeOrigin: true,
    ws: true, // Enable WebSockets
    pathRewrite: {
        '^/orders': '', // Strip /orders prefix so it hits /socket.io on the target
    }
}));

app.listen(PORT, () => {
    console.log(`API Gateway running on port ${PORT}`);
});
