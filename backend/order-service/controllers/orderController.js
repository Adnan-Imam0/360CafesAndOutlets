const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER || 'admin',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'cafe_360',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT || 5432,
});

const createOrder = async (req, res) => {
    const { customer_id, shop_id, delivery_address_id, total_amount, customer_name, customer_phone, delivery_address, items } = req.body;

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        
        const orderQuery = `
            INSERT INTO orders (customer_id, shop_id, delivery_address_id, total_amount, customer_name, customer_phone, delivery_address)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING *
        `;
        const orderValues = [customer_id, shop_id, delivery_address_id, total_amount, customer_name, customer_phone, delivery_address];
        const orderResult = await client.query(orderQuery, orderValues);
        const order = orderResult.rows[0];

        
        const itemQuery = `
            INSERT INTO order_items (order_id, product_id, quantity, price_per_item, product_name)
            VALUES ($1, $2, $3, $4, $5)
        `;

        for (const item of items) {
            await client.query(itemQuery, [order.order_id, item.product_id, item.quantity, item.price, item.name]);
        }

        await client.query('COMMIT');

        
        if (req.io) {
            req.io.to(`shop_${shop_id}`).emit('new_order', order);
            console.log(`Emitted new_order to shop_${shop_id}`);
        }

        res.status(201).json({ message: 'Order created successfully', order });

    } catch (err) {
        await client.query('ROLLBACK');
        console.error(err);
        res.status(500).json({ error: 'Failed to create order', details: err.message });
    } finally {
        client.release();
    }
};

const getOrdersByCustomer = async (req, res) => {
    const { customerId } = req.params;
    try {
        const query = `
            SELECT o.*, 
                   COALESCE(json_agg(
                       json_build_object(
                           'item_id', oi.item_id, 
                           'product_id', oi.product_id, 
                           'quantity', oi.quantity, 
                           'price', oi.price_per_item, 
                           'name', oi.product_name
                       )
                   ) FILTER (WHERE oi.item_id IS NOT NULL), '[]') as items
            FROM orders o
            LEFT JOIN order_items oi ON o.order_id = oi.order_id
            WHERE o.customer_id = $1
            GROUP BY o.order_id
            ORDER BY o.created_at DESC
        `;
        const result = await pool.query(query, [customerId]);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch orders' });
    }
};

const getOrdersByShop = async (req, res) => {
    const { shopId } = req.params;
    try {
        const query = `
            SELECT o.*, 
                   COALESCE(json_agg(
                       json_build_object(
                           'item_id', oi.item_id, 
                           'product_id', oi.product_id, 
                           'quantity', oi.quantity, 
                           'price', oi.price_per_item, 
                           'name', oi.product_name
                       )
                   ) FILTER (WHERE oi.item_id IS NOT NULL), '[]') as items
            FROM orders o
            LEFT JOIN order_items oi ON o.order_id = oi.order_id
            WHERE o.shop_id = $1
            GROUP BY o.order_id
            ORDER BY o.created_at DESC
        `;
        const result = await pool.query(query, [shopId]);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch orders' });
    }
};

const updateOrderStatus = async (req, res) => {
    const { id } = req.params; 
    const { status } = req.body;
    try {
        const result = await pool.query('UPDATE orders SET status = $1 WHERE order_id = $2 RETURNING *', [status, id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Order not found' });
        }
        res.json(result.rows[0]);

        const updatedOrder = result.rows[0];

        
        if (req.io) {
            req.io.to(`user_${updatedOrder.customer_id}`).emit('order_status_updated', updatedOrder);
            console.log(`Emitted order_status_updated to user_${updatedOrder.customer_id}`);
        }

        
        if (req.messaging) {
            try {
                console.log(`[FCM] Attempting to notify customer ${updatedOrder.customer_id} for order ${updatedOrder.order_id}`);

                
                const customerResult = await pool.query('SELECT fcm_token FROM customers WHERE customer_id = $1', [updatedOrder.customer_id]);

                if (customerResult.rows.length > 0 && customerResult.rows[0].fcm_token) {
                    const fcmToken = customerResult.rows[0].fcm_token;
                    console.log(`[FCM] Found token for customer ${updatedOrder.customer_id}: ${fcmToken.substring(0, 10)}...`);

                    const message = {
                        notification: {
                            title: 'Order Update',
                            body: `Your order #${updatedOrder.order_id} is now ${status}!`,
                        },
                        data: {
                            orderId: updatedOrder.order_id.toString(),
                            status: status,
                            click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        },
                        token: fcmToken,
                    };

                    const response = await req.messaging.send(message);
                    console.log(`[FCM] Notification sent successfully: ${response}`);
                } else {
                    console.log(`[FCM] No token found for customer ${updatedOrder.customer_id}`);
                }
            } catch (fcmError) {
                console.error('[FCM] Notification User Error:', fcmError);
            }
        }

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update order status' });
    }
};

const getShopStats = async (req, res) => {
    const { shopId } = req.params;
    try {
        const client = await pool.connect();
        try {
            const totalOrdersResult = await client.query('SELECT COUNT(*) FROM orders WHERE shop_id = $1', [shopId]);
            const totalOrders = parseInt(totalOrdersResult.rows[0].count);

            const revenueResult = await client.query(
                "SELECT SUM(total_amount) FROM orders WHERE shop_id = $1 AND status = 'delivered'",
                [shopId]
            );
            const revenue = parseFloat(revenueResult.rows[0].sum || 0);

            const pendingResult = await client.query(
                "SELECT COUNT(*) FROM orders WHERE shop_id = $1 AND status = 'pending'",
                [shopId]
            );
            const pendingOrders = parseInt(pendingResult.rows[0].count);

            const activeResult = await client.query(
                "SELECT COUNT(*) FROM orders WHERE shop_id = $1 AND status IN ('accepted', 'preparing', 'ready')",
                [shopId]
            );
            const activeOrders = parseInt(activeResult.rows[0].count);

            res.json({ totalOrders, revenue, pendingOrders, activeOrders });
        } finally {
            client.release();
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch shop stats' });
    }
};

const getOrderById = async (req, res) => {
    const { id } = req.params;
    try {
        const query = `
            SELECT o.*, 
                   COALESCE(json_agg(
                       json_build_object(
                           'item_id', oi.item_id, 
                           'product_id', oi.product_id, 
                           'quantity', oi.quantity, 
                           'price', oi.price_per_item, 
                           'name', oi.product_name
                       )
                   ) FILTER (WHERE oi.item_id IS NOT NULL), '[]') as items
            FROM orders o
            LEFT JOIN order_items oi ON o.order_id = oi.order_id
            WHERE o.order_id = $1
            GROUP BY o.order_id
        `;
        const result = await pool.query(query, [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Order not found' });
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch order' });
    }
};

module.exports = {
    createOrder,
    getOrdersByCustomer,
    getOrdersByShop,
    updateOrderStatus,
    getShopStats,
    getOrderById
};
