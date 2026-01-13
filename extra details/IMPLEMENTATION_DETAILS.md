# Implementation Details

## 4.1 Purpose

The **360 Cafe and Outlets** project is a strategic digital transformation initiative designed to modernize the campus dining experience at the University of Turbat. It addresses a critical void in local commerce by replacing manual, decentralized food ordering processes with a unified, technology-driven platform.

**Core Objectives:**
1.  **Operational Optimization:** To mitigate the "rush hour" bottleneck where cafeterias face unmanageable queues during breaks. The system distributes order flow digitally, allowing kitchens to batch process orders more efficiently.
2.  **Market Maximization:** To connect isolated brick-and-mortar shops with the university's digitally native student population, expanding their customer reach beyond physical foot traffic.
3.  **Financial Transparency:** To introduce a ledger-based approach to transaction management, providing shop owners with granular insights into revenue, peak hours, and popular items, transitioning them from intuition-based to data-driven decision making.
4.  **Scalable Infrastructure:** To build a foundation that is not just for today's volume but is architected to handle campus-wide scaling, supporting multiple outlets and concurrent users without performance degradation.

## 4.2 Scope

The system constitutes a multi-faceted software ecosystem encompassing Mobile, Web, and Cloud technologies.

### 4.2.1 Customer Application (Mobile)
A dedicated Flutter-based Android/iOS application tailored for students.
*   **Authentication:** Secure login via Phone Number (OTP) or Email, backed by Firebase Auth.
*   **Shop Discovery:**
    *   **Geospatial Listing:** Shops are ordered by proximity using GPS coordinates.
    *   **Live Status Indicators:** Visual cues (Green/Red dots) indicating if a shop is currently "Open" or "Closed".
    *   **Search & Filter:** Capability to search for specific cuisines (e.g., "Fast Food") or specific items associated with shops.
*   **Menu & Ordering:**
    *   **Categorized Browsing:** Menu items grouped by category (e.g., Beverages, Snacks) with high-res images and prices.
    *   **Cart Management:** Local storage-based cart allowing modification of quantities before checkout.
    *   **Checkout:** Validation of order totals and selection of "Dine-in" or "Takeaway".
*   **Order Lifecycle:**
    *   **Real-time Tracking:** visual timeline showing status changes (Pending -> Preparing -> Ready) powered by WebSockets.
    *   **Order History:** A persistent record of past meals for re-ordering.
*   **Profile Management:** Management of saved delivery addresses and personal details.

### 4.2.2 Shop Owner Application (Mobile/Tablet)
A business-centric dashboard designed for high-paced kitchen environments.
*   **Real-time Dashboard:** A "Live Orders" view that updates instantly when a new order arrives, accompanied by audible alerts.
*   **Order Action Center:** Controls to "Accept" (sending to preparation) or "Reject" (with reason) orders. A "Mark as Ready" action triggers customer notifications.
*   **Menu Engineering:** Full CRUD (Create, Read, Update, Delete) capabilities for Products and Categories. Includes image uploading and "Out of Stock" toggling.
*   **Business Profile:** Editable fields for Shop Name, Description, Location, and Operating Hours.
*   **Shop Controls:** A master "Emergency Toggle" to close the shop digitally during unexpected outages.

### 4.2.3 Backend Microservices
A distributed server-side architecture hosting distinct business domains.
*   **API Gateway (Port 3000):** The traffic controller that routes requests to appropriate services and handles CORS.
*   **Auth Service:** Manages user identity, issues JWT access tokens, and validates Firebase credentials.
*   **User Service:** CRUD operations for user profiles (`customers` and `shop_owners` tables).
*   **Shop Service:** Manages `shops`, `categories`, `products`, and `product_reviews`.
*   **Order Service:** The transaction engine managing `orders` and `order_items`. Integrates `Socket.io` for event broadcasting.

## 4.3 Overview

The **360 Cafe** platform is an event-driven system where actions in one interface propagate updates across the entire network.

### 4.3.1 Critical User Flows
*   **The "Hungry Student" Flow:**
    1.  **Launch:** User opens the app; Splash screen checks for cached JWT token.
    2.  **Discover:** Home screen solicits current location (or uses default "University" location) to load nearest open cafetarias.
    3.  **Selection:** User taps "Central Canteen", browses "Burgers" category, adds "Zinger Burger" to cart.
    4.  **Checkout:** User confirms "Takeaway". API creates an Order record with status `PENDING`.
    5.  **Wait:** User sees a "Waiting for confirmation" screen.

*   **The "Busy Shop Owner" Flow:**
    1.  **Notification:** Kitchen tablet chimes. "New Order #1234" appears at the top of the "Incoming" list.
    2.  **Decision:** Owner checks stock. Taps "Accept".
    3.  **Preparation:** Order moves to "Preparing" tab. Kitchen staff starts cooking.
    4.  **Completion:** Food is packed. Owner taps "Notify Customer".
    5.  **Handover:** Customer arrives. Owner verifies Order ID and hands over food. Taps "Complete".

### 4.3.2 Data Lifecycle
Data flows strictly from **Client** $\rightarrow$ **Gateway** $\rightarrow$ **Service** $\rightarrow$ **Database**.
*   **Reads:** Aggregated by the client (e.g., fetching a Shop includes fetching its Categories and Products via chained API calls or backend joins).
*   **Writes:** Transactional updates (e.g., Placing an Order) insert records into multiple tables (`orders`, `order_items`) within a transaction block to ensure data consistency.

## 4.4 System Overview

The project relies on a modern, open-source technology stack chosen for stability, community support, and performance.

### 4.4.1 Software Architecture
The system implements a **Service-Oriented Architecture (SOA)** using **Microservices**.
*   **Decoupling:** Each service (`Auth`, `User`, `Shop`, `Order`) possesses its own logical boundaries. While they currently share a physical PostgreSQL instance (for resource efficiency), they are logically separated and could be migrated to distinct databases without code refactoring.
*   **Communication:**
    *   **Synchronous:** RESTful HTTP/1.1 for standard request/response cycles (e.g., Login, Get Menu).
    *   **Asynchronous:** `Socket.io` (running on top of HTTP/1.1 layouts) for pushing state changes (Order Status updates) to connected clients.

### 4.4.2 Technology Stack Details
*   **Frontend (Mobile):** **Flutter 3.x**. Uses `provider` for State Management, efficiently separating business logic from UI code. Uses `go_router` for deep linking and navigation. Uses `http` and `dio` for network requests.
*   **Backend Runtime:** **Node.js**: Event-driven, non-blocking I/O model ideal for real-time applications.
*   **Web Framework:** **Express.js**: Minimalist web framework for routing and middleware management.
*   **Database:** **PostgreSQL**: An advanced object-relational database.
    *   *Key Schemas:* `customers`, `shop_owners`, `shops`, `products`, `orders`.
    *   *Indexing:* Indexes on foreign keys (`shop_id`, `customer_id`) and status fields to optimize query performance.
*   **Authentication:** **Firebase Auth**: Delegated identity provider for secure phone/email verification. **JWT (JSON Web Tokens)**: Used for session management between the Client and our Custom Backend.

### 4.4.3 Infrastructure & Deployment
*   **Containerization:** Full Docker support. `docker-compose.yml` orchestrates the spinning up of the Database service alongside the 5 Node.js application services.
*   **API Gateway:** A custom Node.js proxy (using `http-proxy-middleware`) that masks the internal port structure (3001-3005) from the outside world, exposing a unified API surface on port 3000.
*   **Security Measures:**
    *   **CORS:** Configured to allow requests strictly from known Client origins.
    *   **Environment Variables:** Sensitive credentials (DB passwords, Firebase Keys) are injected via `.env` files, never hardcoded.
