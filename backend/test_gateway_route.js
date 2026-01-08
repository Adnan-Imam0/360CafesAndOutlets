const http = require('http');

const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/shops/owner/1', // Testing the Gateway path
    method: 'GET',
};

console.log(`Testing GET ${options.hostname}:${options.port}${options.path}...`);

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

req.end();
