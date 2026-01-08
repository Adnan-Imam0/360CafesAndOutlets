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

app.use((req, res, next) => {
    console.log(`[Gateway] Incoming: ${req.method} ${req.url} (original: ${req.originalUrl})`);
    next();
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
    changeOrigin: true,
    pathRewrite: {
        '^/users': '', // Strip /users prefix
    }
}));

// Shop Service (Shops & Products)
// Shop Service (Shops & Products)
app.use('/shops', createProxyMiddleware({
    target: process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3003',
    changeOrigin: true,
    pathRewrite: {
        '^/': '/shops/', // Re-add /shops/ prefix that express strips
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`[Gateway] Proxied ${req.method} /shops${req.url} -> ${proxyReq.path}`);
    },
    onError: (err, req, res) => {
        console.error('[Gateway] Proxy Error:', err);
        res.status(500).send('Proxy Error');
    }
}));

app.use('/products', createProxyMiddleware({
    target: process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3003',
    changeOrigin: true,
    pathRewrite: {
        '^/': '/api/products/',
    }
}));

app.use('/categories', createProxyMiddleware({
    target: process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3003',
    changeOrigin: true,
    pathRewrite: {
        '^/': '/api/categories/',
    }
}));

app.use('/reviews', createProxyMiddleware({
    target: process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3003',
    changeOrigin: true,
    pathRewrite: {
        '^/': '/reviews/', // Re-add /reviews/ prefix
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`[Gateway] Proxied ${req.method} /reviews${req.url} -> ${proxyReq.path}`);
    }
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
