# Cafe 360 - Project Documentation

## 1. Project Abstract
**Cafe 360** is a comprehensive digital platform designed to digitize the university cafeteria experience. It bridges the gap between students (Customers) and cafeteria owners (Shop Owners) through a seamless ecosystem consisting of two mobile/web applications and a robust microservices-based backend.

**Key Goals:**
- Eliminate long queues and wait times.
- Provide real-time order tracking.
- Enable efficient digital menu and order management for shop owners.
- Digitize payments and sales tracking.

---

## 2. System Architecture
The project follows a **Microservices Architecture** to ensure scalability, maintainability, and loose coupling between components.

### 2.1 Services Breakdown
1.  **API Gateway (Port 3000):** The single entry point for all client requests. It handles routing, rate limiting, and request aggregation.
2.  **Auth Service (Port 3001):** Manages user authentication (Login, Register) using Firebase Auth and syncs basic user profiles to PostgreSQL.
3.  **User Service (Port 3002):** Handles user profile management (Names, Roles, Contact Info).
4.  **Shop Service (Port 3003):** Manages Shop creation, Menus, Products, and Categories.
5.  **Order Service (Port 3004):** Handles Order placement, Status updates (Pending -> Ready -> Completed), and Real-time notifications.

### 2.2 Data Flow
`Client App` -> `API Gateway` -> `Specific Microservice` -> `PostgreSQL Database`

---

## 3. Technology Stack

### 3.1 Backend
-   **Runtime:** Node.js
-   **Framework:** Express.js
-   **Database:** PostgreSQL (Relational DB)
-   **Containerization:** Docker & Docker Compose
-   **Authentication:** Firebase Admin SDK

### 3.2 Frontend
-   **Framework:** Flutter (Dart)
-   **Platforms:**
    -   **Shop Owner App:** Web (Admin Dashboard) & Mobile (On-the-go management).
    -   **Customer App:** Mobile (Android/iOS) for ordering.
-   **State Management:** Provider
-   **Routing:** GoRouter

---

## 4. Database Schema
The system uses a relational PostgreSQL database with the following key entities:

### 4.1 Users Table
-   `id` (PK): Firebase UID
-   `email`: User email
-   `role`: 'customer' | 'shop_owner' | 'admin'

### 4.2 Shops Table
-   `shop_id` (PK): UUID
-   `owner_id` (FK -> Users)
-   `shop_name`: Name of the cafeteria
-   `status`: 'active' | 'closed'

### 4.3 Products Table
-   `item_id` (PK): UUID
-   `shop_id` (FK -> Shops)
-   `name`: Item name (e.g., "Chicken Wrap")
-   `price`: Decimal
-   `category`: String
-   `is_available`: Boolean

### 4.4 Orders Table
-   `order_id` (PK): Serial Integer
-   `customer_id` (FK -> Users)
-   `shop_id` (FK -> Shops)
-   `total_amount`: Decimal
-   `status`: 'Pending', 'Preparing', 'Ready', 'Completed', 'Cancelled'
-   `created_at`: Timestamp

---

## 5. Key Features

### 5.1 Shop Owner Application
-   **Dashboard Overview:** View daily sales, total orders, and active order counts.
-   **Order Notifications:** Instant audible and visual alerts for new orders via Web Sockets and Local Notifications.
-   **Order Management:** Accept/Reject incoming orders and update their status (e.g., Mark as Ready).
-   **Menu Management:** Add, Edit, or Delete products. Toggle availability (Out of Stock).
-   **Shop Profile:** Manage shop details, opening hours, and images.

### 5.2 Customer Application
-   **Shop Discovery:** View list of available university cafeterias.
-   **Digital Menu:** Browse items by category with prices and descriptions.
-   **Cart & Checkout:** Add items to cart and place orders.
-   **Live Tracking:** See real-time status updates of the order via Push Notifications (FCM).
-   **Order History:** View past orders and re-order favorites.

---

## 6. API Design (Key Endpoints)

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| **POST** | `/auth/register` | Register a new user |
| **POST** | `/auth/login` | Login and retrieve Token |
| **GET** | `/shops` | Get list of all shops |
| **POST** | `/shops` | Create a new shop (Owner only) |
| **GET** | `/shops/:id/products` | Get menu for a specific shop |
| **POST** | `/orders` | Place a new order |
| **GET** | `/orders/shop/:shopId` | Get incoming orders for a shop |
| **PATCH** | `/orders/:id/status` | Update order status |

---

## 7. Future Enhancements
-   **Payment Gateway Integration:** Stripe/Easypaisa for cashless payments.
-   **Rating System:** Students can rate shops and items.
