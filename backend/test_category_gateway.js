const http = require('http');

// Testing the full path as rewrite logic is applied on /categories
// With pathRewrite '^/' -> '/api/categories/', request to /categories/shop/1 should be rewriten to /api/categories/shop/1
// But I need to hit the Gateway which is localhost:3000
const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/categories/shop/1',
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
