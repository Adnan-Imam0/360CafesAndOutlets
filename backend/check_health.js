const http = require('http');

const ports = [3006, 3007, 3008];

ports.forEach(port => {
    http.get(`http://127.0.0.1:${port}/health`, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
            console.log(`Port ${port} is UP: ${data}`);
        });
    }).on('error', (err) => {
        console.log(`Port ${port} is DOWN: ${err.message}`);
    });
});
