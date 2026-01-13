const http = require('http');
const fs = require('fs');

function get(url) {
    return new Promise((resolve, reject) => {
        http.get(url, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                try {
                    resolve(JSON.parse(data));
                } catch (e) {
                    console.error('Error parsing JSON:', data);
                    resolve([]); // Handle non-JSON response
                }
            });
        }).on('error', (err) => reject(err));
    });
}

async function debugShops() {
    const baseUrl = 'http://localhost:3006';
    const logFile = 'shops_debug.json';

    try {
        const shops = await get(`${baseUrl}/shops`);
        // Just write the JSON to file
        fs.writeFileSync(logFile, JSON.stringify(shops.slice(0, 5), null, 2));
        console.log('Written to ' + logFile);
    } catch (e) {
        console.error(e);
    }
}

debugShops();
