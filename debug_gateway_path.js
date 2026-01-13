const http = require('http');

const server = http.createServer((req, res) => {
    console.log(`[MOCK 3007] Received: ${req.method} ${req.url}`);
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'OK', path: req.url }));
});

server.listen(3007, () => {
    console.log('Mock Shop Service listening on 3007...');
});
