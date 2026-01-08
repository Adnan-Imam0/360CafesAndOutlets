const http = require('http');

const testUrl = (port, path, method = 'GET', body = null) => {
    return new Promise((resolve) => {
        const options = {
            hostname: '127.0.0.1',
            port: port,
            path: path,
            method: method,
            headers: body ? {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(body)
            } : {}
        };

        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                console.log(`[${method}] Port ${port} ${path} -> ${res.statusCode}`);
                if (res.statusCode >= 200) {
                    console.log(`Body: ${data.substring(0, 200)}`);
                }
                resolve();
            });
        });

        req.on('error', (e) => {
            console.log(`[${method}] Port ${port} ${path} -> ERROR: ${e.message}`);
            resolve();
        });

        if (body) {
            req.write(body);
        }
        req.end();
    });
};

const runTests = async () => {
    console.log('\n--- System Health Check ---');
    await testUrl(3001, '/health'); // Auth
    await testUrl(3002, '/health'); // User
    await testUrl(3005, '/health'); // Order
    await testUrl(3003, '/health'); // Shop
    await testUrl(3000, '/health'); // Gateway

    console.log('\n--- Diagnosing Shop Routing ---');
    console.log('1. Direct to Shop Service (3003):');
    await testUrl(3003, '/shops/owner/1');

    console.log('2. Via API Gateway (3000):');
    await testUrl(3000, '/shops/owner/1');
};

runTests();
