@echo off
echo Starting Cafe 360 Backend Services...

start "API Gateway" cmd /k "cd backend\api-gateway && npm install && node index.js"
start "Auth Service" cmd /k "cd backend\auth-service && npm install && node index.js"
start "User Service" cmd /k "cd backend\user-service && npm install && node index.js"
start "Shop Service" cmd /k "cd backend\shop-service && npm install && node index.js"
start "Order Service" cmd /k "cd backend\order-service && npm install && node index.js"

echo All services launched in separate windows.
