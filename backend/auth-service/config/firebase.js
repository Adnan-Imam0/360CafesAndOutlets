const admin = require('firebase-admin');
require('dotenv').config();

// const serviceAccount = require('./serviceAccountKey.json');

// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });

// Mock initialization for now if no service account
if (!admin.apps.length) {
    // admin.initializeApp(); // This will fail without creds usually
    console.log("Firebase Admin mock initialized (uncomment real init in config/firebase.js)");
}

module.exports = admin;
