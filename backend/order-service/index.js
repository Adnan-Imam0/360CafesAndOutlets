const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 3004;

// Firebase Admin Setup
const admin = require('firebase-admin');

let serviceAccount;
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
} else {
    serviceAccount = require('./service-account.json');
}

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});
const messaging = admin.messaging();

// Socket.io Setup
const io = new Server(server, {
    cors: {
        origin: "*", // Allow all origins for now
        methods: ["GET", "POST"]
    }
});

io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);

    socket.on('join_room', (room) => {
        socket.join(room);
        console.log(`Socket ${socket.id} joined room ${room}`);
    });

    socket.on('disconnect', () => {
        console.log('Client disconnected:', socket.id);
    });
});

app.use(cors());
app.use(express.json());

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
        res.json({ status: 'Order Service Running', db: 'Connected' });
    } catch (err) {
        res.status(500).json({ status: 'Order Service Error', db: err.message });
    }
});

// Routes
// Pass io to routes via middleware
app.use((req, res, next) => {
    req.io = io;
    req.messaging = messaging;
    next();
});

const orderRoutes = require('./routes/orderRoutes');
app.use('/', orderRoutes);

server.listen(PORT, () => {
    console.log(`Order Service running on port ${PORT}`);
});
