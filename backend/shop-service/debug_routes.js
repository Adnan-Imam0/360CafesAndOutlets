const express = require('express');
const app = express();
const shopRoutes = require('./routes/shopRoutes');


app.use('/api/shops', shopRoutes);
app.use('/shops', shopRoutes);

const fs = require('fs');
const shopController = require('../controllers/shopController');

let output = "=== Controller Check ===\n";
output += `toggleShopStatus is type: ${typeof shopController.toggleShopStatus}\n`;

output += "\n=== Registered Routes in 'shopRoutes' ===\n";
shopRoutes.stack.forEach(layer => {
    if (layer.route) {
        output += `${Object.keys(layer.route.methods).join(',').toUpperCase()} ${layer.route.path}\n`;
    }
});

fs.writeFileSync('routes.txt', output);
console.log("Written to routes.txt");
