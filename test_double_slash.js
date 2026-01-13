const http = require('http');

function check(path) {
    http.get(`http://localhost:3007${path}`, (res) => {
        console.log(`${path} -> ${res.statusCode}`);
        res.resume();
    });
}

// Test normal
check('/api/reviews/shop/1');

// Test double slash (Hypothesis)
check('/api/reviews//shop/1');
