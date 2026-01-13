const express = require('express');
const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());

console.log('[DEBUG] Shop Service Target:', process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3007');


app.get('/health', (req, res) => {
    res.json({ status: 'API Gateway Running' });
});


app.use('/auth', createProxyMiddleware({
    target: process.env.AUTH_SERVICE_URL || 'http://127.0.0.1:3001',
    changeOrigin: true
}));


app.use('/users', createProxyMiddleware({
    target: process.env.USER_SERVICE_URL || 'http://127.0.0.1:3002',
    changeOrigin: true,
    pathRewrite: {
        '^/users': '', 
    }
}));


app.use('/shops', createProxyMiddleware({
    target: process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3007',
    changeOrigin: true,
    pathRewrite: {
        '^/': '/shops/', 
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
    target: process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3007',
    changeOrigin: true,
    pathRewrite: {
        '^/': '/api/products/',
    }
}));

app.use('/categories', createProxyMiddleware({
    target: process.env.SHOP_SERVICE_URL || 'http://127.0.0.1:3007',
    changeOrigin: true,
    pathRewrite: {
        '^/': '/api/categories/',
    }
}));

app.use('/reviews', createProxyMiddleware({
    target: process.env.SHOP_SERVICE_URL || 'http://localhost:3007',
    changeOrigin: true,
    pathRewrite: function (path, req) {
        if (path.startsWith('/reviews')) {
            return path.replace('/reviews', '/api/reviews');
        }
        return '/api/reviews' + path;
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`[Gateway] Proxied ${req.method} /reviews${req.url} -> ${proxyReq.path}`);
    },
    onError: (err, req, res) => {
        console.error('[Gateway] Proxy Error:', err);
        res.status(500).send('Proxy Error');
    }
}));


app.use('/orders', createProxyMiddleware({
    target: process.env.ORDER_SERVICE_URL || 'http://127.0.0.1:3008',
    changeOrigin: true,
    ws: true, 
    pathRewrite: {
        '^/orders': '', 
    }
}));


app.use('/socket.io', createProxyMiddleware({
    target: process.env.ORDER_SERVICE_URL || 'http://127.0.0.1:3008',
    changeOrigin: true,
    ws: true,
}));

app.listen(3006, () => {
    console.log(`API Gateway running on port 3006`);
});
