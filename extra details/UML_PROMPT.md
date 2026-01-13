# UML Diagram Generation Strategy

## 1. Selected Configuration
Based on your requirements, the diagrams will be generated with the following parameters:
*   **Level of Detail:** **Detailed method-level interactions** + **Database Schema Relationships**.
*   **Additional Aspects:** **Authentication Flows** (Firebase/JWT) and **Data Synchronization** (Socket.io).
*   **Business Rules:** Explicit modeling of the **Order Lifecycle** (Pending $\to$ Completed) and **Shop Availability** logic.

---

## 2. Detailed Prompts for UML Generation

**Copy and paste these advanced prompts into your UML tool.**

### Prompt Part 1: System Architecture (Component Diagram)

> **Instructions:** Create a comprehensive UML Component Diagram for the "360 Cafe" Microservices System.
> **Style:** Detailed, showing ports, protocols, and data flow direction.
>
> **Components to Include:**
> 1.  **Client Layer:**
>     *   `[Customer App]` (Flutter): Uses `http` for REST and `socket.io-client` for events.
>     *   `[Shop Owner App]` (Flutter/Web): Uses `http` and `socket.io-client`.
> 2.  **API Gateway (Port 3000):**
>     *   *Middlewares:* `cors`, `http-proxy-middleware`.
>     *   *Routes:* `/auth`, `/users`, `/shops`, `/orders`.
> 3.  **Microservices Container:**
>     *   `[Auth Service]`: Verifies `idToken` with Firebase Admin. Issues JWT.
>     *   `[User Service]`: CRUD for `users` table.
>     *   `[Shop Service]`: Manages `shops`, `products`, `categories` tables.
>     *   `[Order Service]`:
>         *   *Internal:* `Socket.io Server` instance.
>         *   *Internal:* `PG Pool` for database.
> 4.  **Persistence:**
>     *   `[PostgreSQL DB]`: Show relationship lines from all services to this single node.
> 5.  **External:**
>     *   `{Firebase Project}`: For Phone/Email Auth.
>
> **Connectors:**
> *   Annotate connections with protocols (e.g., "HTTP/1.1 REST", "WebSocket/WSS", "TCP/IP (DB Connection)").

---

### Prompt Part 2: "Place Order" Flow (Detailed Sequence Diagram)

> **Instructions:** Create a UML Sequence Diagram for the Order Placement flow, highlighting Authentication and Real-time Sync.
>
> **Participants:**
> *   `User (Student)`
> *   `Customer App`
> *   `API Gateway`
> *   `Order Service`
> *   `Auth Middleware` (Internal to Service)
> *   `PostgreSQL`
> *   `Shop Owner App`
>
> **Detailed Steps:**
> 1.  **Auth Check:** `Customer App` sends `POST /orders` (Header: `Authorization: Bearer <JWT>`).
> 2.  **Routing:** `API Gateway` proxies to `Order Service`.
> 3.  **Verification:** `Order Service` calls `Auth Middleware` to decode JWT.
>     *   *Alt:* If invalid, return 401 Unauthorized.
> 4.  **Validation:** `Order Service` checks payload (items, prices).
> 5.  **Transaction:**
>     *   `Order Service` begins DB Transaction (`BEGIN`).
>     *   Insert into `orders` table.
>     *   Insert into `order_items` table.
>     *   Commit Transaction (`COMMIT`).
> 6.  **Real-time Event:** `Order Service` fires `socket.to('shop_<id>').emit('new_order', orderData)`.
> 7.  **Notification:** `Shop Owner App` receives event, triggers `AudioPlayer.play()`.
> 8.  **Response:** `Order Service` returns `HTTP 201 Created` to `Customer App`.

---

### Prompt Part 3: Shop Owner Logic (State Machine Diagram)

> **Instructions:** Create a UML State Machine diagram for the **Order Entity** with strict adherence to business rules.
>
> **States:**
> *   `Pending` (Entry State)
> *   `Accepted`
> *   `Rejected` (Final State - Audit Required)
> *   `Preparing`
> *   `Ready`
> *   `Completed` (Final State - History Archived)
>
> **Transitions & Guards:**
> 1.  `Pending` $\rightarrow$ `Accepted`:
>     *   *Trigger:* Owner taps "Accept".
>     *   *Action:* Send push notification to Customer.
> 2.  `Pending` $\rightarrow$ `Rejected`:
>     *   *Trigger:* Owner taps "Reject".
>     *   *Guard:* Must provide `rejection_reason` (e.g., "Out of Stock").
> 3.  `Accepted` $\rightarrow$ `Preparing`:
>     *   *Trigger:* Manual update OR Automatic (Immediate).
> 4.  `Preparing` $\rightarrow$ `Ready`:
>     *   *Trigger:* Kitchen Staff marks "Cooking Done".
>     *   *Action:* Notify Customer "Your order is ready!".
> 5.  `Ready` $\rightarrow$ `Completed`:
>     *   *Trigger:* Owner verifies Order ID.
> 6.  `Pending` $\rightarrow$ `Cancelled`:
>     *   *Window:* Only allowed within 30 seconds of placement.
