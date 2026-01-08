const http = require('http');

const data = JSON.stringify({
    is_open: false
});

const options = {
    hostname: 'localhost',
    port: 3003,
    path: '/api/shops/1/status', // Testing valid path
    method: 'PATCH',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

console.log(`Connecting to ${options.hostname}:${options.port}${options.path}...`);

const req = http.request(options, (res) => {
    console.log(`STATUS: ${res.statusCode}`);
    res.setEncoding('utf8');
    res.on('data', (chunk) => {
        console.log(`BODY: ${chunk}`);
    });
});

req.on('error', (e) => {
    console.error(`REQUEST_ERROR: ${e.message}`);
});

req.write(data);
req.end();
