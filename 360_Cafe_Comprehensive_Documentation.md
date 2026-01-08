# Chapter 1: Introductory Chapter

## 1.1 Introduction
The rapid evolution of mobile technology has fundamentally transformed the service industry, reshaping how consumers interact with businesses. The food and beverage sector, in particular, has seen a paradigm shift towards digital ordering systems that prioritize convenience, speed, and efficiency. However, in many developing regions and semi-closed environments like universities and corporate hubs in **Turbat**, the adoption of such technologies has been slow.

**360 Cafe and Outlets** is a robust, multi-vendor e-commerce solution specifically engineered to modernize the traditional cafeteria experience within the **Turbat** region. By replacing the archaic manual ordering processes with a sophisticated mobile-first ecosystem, the system bridges the operational gap between hungry customers and cafeteria vendors. Leveraging a microservices architecture underpinned by Node.js and Flutter, the platform offers a seamless, cashless, and highly efficient ordering experience. This document serves as a comprehensive guide to the development, architecture, and deployment of the "360 Cafe and Outlets" system, detailing how it addresses specific local challenges while adhering to global software engineering standards.

### 1.1.1 Purpose
The primary purpose of **360 Cafe and Outlets** is to digitize the entire lifecycle of food ordering and management within food courts, university campuses, and corporate cafeterias in **Turbat**. The system is designed to serve multiple stakeholders with distinct benefits:

*   **For Customers (Information & Convenience):** To provide a unified platform where users can browse menus from multiple outlets, view real-time item availability, place orders without standing in line, and track their order status from "Pending" to "Ready" instantly.
*   **For Shop Owners (Operational Efficiency):** To empower local vendors with digital tools that streamline inventory management, automate order taking, reduce human error in kitchen communication, and provide actionable insights into daily sales performance.
*   **For Administration (Modernization):** To introduce a scalable, cashless transaction model that reduces congestion in food courts and enhances the modern image of the institution or facility.

### 1.1.2 Description
**360 Cafe and Outlets** is a cohesive ecosystem comprising three distinct but interconnected components, tailored for closed-loop or semi-public food environments:

1.  **Customer Application (Flutter):** A cross-platform mobile application that serves as the customer's digital interface. It features:
    *   **Smart Discovery:** Server-side search and categorization to easily find shops and products.
    *   **Live Menu:** Real-time synchronization of prices and availability.
    *   **Order Management:** A comprehensive cart and checkout system with real-time status tracking via socket-based notifications.
    
2.  **Shop Owner Application (Flutter):** An administrative dashboard for vendors, accessible via mobile or tablet. It allows vendors to:
    *   **Manage Digital Storefronts:** Toggle shop status (Open/Closed) and update profiles.
    *   **Menu Engineering:** Dynamically add, edit, or remove products and categories.
    *   **Order Fulfillment:** A dedicated "Kitchen View" to manage the lifecycle of incoming orders.
    
3.  **Backend Infrastructure (Node.js & PostgreSQL):** The backbone of the system, built on a modular microservices architecture. It includes:
    *   **Auth Service:** secure JWT-based authentication.
    *   **Shop & Product Services:** Handling catalog data with advanced search capabilities.
    *   **Order Service:** Managing high-concurrency transactions and state transitions.
    *   **Database:** A relational PostgreSQL database ensuring ACID compliance for reliability.

### 1.1.3 Product Scope
The scope of the **360 Cafe and Outlets** project is defined by the following boundaries:

*   **In-Scope:**
    *   **User Authentication:** Secure signup/login for Customers and Shop Owners, including profile management.
    *   **Multi-Vendor Support:** The system supports an unlimited number of distinct shops on a single platform.
    *   **Catalog Management:** Complete CRUD (Create, Read, Update, Delete) operations for categories and products.
    *   **Ordering Workflow:** End-to-end handling of orders including cart management, placement, validation, and status updates.
    *   **Notification System:** Real-time alerts for order confirmations, preparation updates, and pickup readiness.
    *   **Search Engine:** Optimized server-side search for detecting shops and products across the platform.

*   **Out-of-Scope:**
    *   **Third-Party Logistics:** The system is designed for "Pick-Up" and "Dine-In" models typical of food courts. Integration with external delivery riders (like UberEats) is outside the current scope.
    *   **Payment Gateway Integration:** While the system calculates totals, the actual payment processing (Credit Card/Bank APIs) is simulated for this iteration, focusing on the order workflow itself.

### 1.1.4 Gantt chart
The following timeline illustrates the phased development lifecycle of the project:

| Phase | Task | Description | Duration | Status |
| :--- | :--- | :--- | :--- | :--- |
| **1** | **Requirement Analysis** | Gathering Functional & Non-Functional Requirements | Week 1-2 | Completed |
| **2** | **System Architecture** | Microservices Design & Database Schema Modeling | Week 3 | Completed |
| **3** | **Database Setup** | PostgreSQL Initialization & Cloud Migration | Week 4 | Completed |
| **4** | **Backend Dev** | API Implementation (Express.js), Auth & Logic | Week 5-8 | Completed |
| **5** | **Customer App UI/UX** | Flutter Development (Screens, State Management) | Week 9-12 | Completed |
| **6** | **Shop Owner App** | Admin Dashboard & Order Management Features | Week 13-15 | Completed |
| **7** | **Integration** | Connecting Frontend to Backend & Debugging | Week 16-17 | Completed |
| **8** | **Optimization** | Performance Tuning (Search, Caching, Images) | Week 18 | In Progress |

### 1.1.5 Objective
The development of **360 Cafe and Outlets** is driven by specific, measurable objectives:

1.  **Reduce Wait Times:** To decrease the average customer wait time (queue + ordering) by at least 40% through remote pre-ordering.
2.  **Scalability:** To engineer a backend capable of handling sudden spikes in traffic (e.g., lunch hours) without service degradation.
3.  **Accuracy:** To eliminate order discrepancies caused by verbal miscommunication in noisy food court environments.
4.  **Adoption:** To achieve a user-friendly design that allows non-technical shop owners to master the system within one day of training.
5.  **Reliability:** To ensure high availability (99.9% uptime) during critical business hours.

### 1.1.6 Problem Statement
In the traditional setup of food courts in **Turbat**, several operational bottlenecks hinder growth and customer satisfaction:
*   **Physical Congestion:** During peak hours, long queues obstruct pathways and discourage customers from purchasing, leading to lost revenue.
*   **Inefficient Order Taking:** Manual processes are slow and prone to human error, resulting in incorrect orders and food waste.
*   **Lack of Inventory Visibility:** Customers often wait in line only to discover their desired item is sold out, creating frustration.
*   **Data Invisibility:** Shop owners operate on intuition rather than data, lacking visibility into which items are top sellers or what times are busiest.
*   **Cash Hygiene:** The heavy reliance on physical cash exchanges slows down transaction velocity and poses hygiene risks in food handling environments.

### 1.1.7 Functional Requirements
The system is built to strictly adhere to the following functional requirements:

**A. Customer Module**
*   **Secure Access:** Multi-factor authentication or secure password hashing for user accounts.
*   **Smart Search:** A robust search engine allowing users to filter by "Shop Name", "Product Name", or "Category" (e.g., Fast Food, Desi).
*   **Cart Persistence:** The ability to add items from different categories, update quantities, and clear the cart.
*   **Order Lifecycle:** Users must receive transparent updates as their order moves from "Pending" -> "Preparing" -> "Ready".

**B. Shop Owner Module**
*   **Operational Control:** A master switch to instantly toggle the shop's visibility (Open/Closed) based on real-time kitchen capacity.
*   **Catalog Control:** Instant updates to the menu (adding specials, hiding out-of-stock items) that reflect immediately on the customer app.
*   **Order Dashboard:** A live feed of incoming orders with action buttons to "Accept", "Mark Ready", or "Complete".

**C. System Module**
*   **Real-time Synchronization:** Changes in the database must propagate instantly to connected clients (e.g., using WebSockets or Polling).
*   **Data Validation:** The backend must sanitizing all inputs to prevent SQL injection and ensure data integrity.

### 1.1.8 Non-Functional Requirements
To ensure a high-quality user experience and system longevity, the following non-functional requirements are prioritized:

1.  **User Friendly:** The interface is designed with a "zero-learning curve" philosophy. Icons are intuitive (e.g., a Trash can for delete), and flows are linear, ensuring that even non-technical students or shop staff can operate the app without a manual.
2.  **Simple and Minimalistic Design:** The UI utilizes ample whitespace, consistent typography (Poppins), and a clutter-free layout. Information overload is avoided by categorizing food items and using card-based designs for orders.
3.  **Portability:** The system acts as a Progressive Web App (PWA) for shop owners, accessible on any device with a browser. The customer app is built on Flutter, allowing deployment to both Android and iOS from a single codebase.
4.  **Responsive and Fast:** The application is optimized to load screens in under 2 seconds. API responses are compressed to ensure smoothness even on slower 3G networks common in parts of Turbat.
5.  **Accuracy:** The system guarantees data integrity. For example, if a user adds an item to the cart, the price refects the real-time backend value, and inventory is reserved to prevent double-ordering.
6.  **Performance:** The backend is built on Node.js, known for its non-blocking I/O, allowing the server to handle hundreds of concurrent requests (e.g., during lunch rush) with minimal latency.
7.  **Reusability:** The code follows modular architecture. Components like `ShopCard`, `ProductTile`, and `OrderSummary` are reusable widgets, making future feature additions (like a "Favorites" screen) faster to implement.
8.  **Completeness:** The system covers the entire "Order-to-Fulfillment" cycle without requiring external tools. From product discovery to cooking status and final pickup, every step is digitalized.
9.  **Security:** User data is protected using industry standards. Passwords are hashed with **Bcrypt**, API access is secured via **JWT (JSON Web Tokens)**, and all communications occur over **HTTPS**.
10. **Documentation:** Comprehensive documentation (this document) and inline code comments are maintained to assist future developers in understanding the system architecture and logic.
11. **Maintainability:** The codebase supports Separation of Concerns (MVC Pattern). Business logic (Controllers) is separate from Data Access (Models) and Presentation (Routes), making debugging and updates straightforward.
12. **Disaster Recovery:** The database is hosted on a managed cloud service (Supabase/Render) with automated daily backups. In case of a crash, the system can be restored to the latest snapshot within minutes.
13. **Reliability:** The system monitors for failures. If the Internet connection drops, the mobile app alerts the user immediately ("No Connection") rather than crashing, and retries requests automatically when connectivity is restored.

### 1.1.9 Intended Audience and Reading Suggestions
This document is designed for a diverse audience involved in the deployment, usage, and maintenance of the system.

#### 1.1.9.1 Customers (Students, Faculty, and Public)
**Usage:** This group represents the primary end-users of the **Customer App**. They include university students, faculty members, and visitors in Turbat who wish to order food digitally.
**Suggestion:** They should focus on **Section 1.2.2 (Product Features)** to understand how to use the "Smart Search", "Cart", and "Order Tracking" features to save time during breaks.

#### 1.1.9.2 Shop Owners and Kitchen Staff
**Usage:** This group comprises the cafeteria vendors and their staff who will use the **Shop Owner App**. They are responsible for fulfilling orders and managing their digital menus.
**Suggestion:** They should review **Section 1.2.4 (Operational Environment)** to understand the device requirements (tablets/laptops) and the **Vendor Dashboard** documentation to learn how to toggle their shop's "Open/Closed" status.

#### 1.1.9.3 Official Documentation
**Usage:** For developers and IT staff responsible for maintaining the system or extending its functionality.
**Suggestion:** This document serves as the primary reference. Developers should pay close attention to **Chapter 3 (System Architecture)** and **Chapter 4 (Database Design)**.

#### 1.1.9.4 Online forums or communities
**Usage:** For obtaining support on the underlying technologies (Flutter, Node.js).
**Suggestion:** While not part of this internal document, developers are encouraged to consult official Flutter and Node.js documentation for framework-specific queries.

## 1.2 Overall Description
### 1.2.1 Product Perspective
**360 Cafe and Outlets** is a self-contained software system but operates within the broader context of the internet ecosystem. It relies on:
1.  **Google Maps API (Future Scope):** For location services.
2.  **Firebase Cloud Messaging (FCM):** For delivering push notifications to mobile devices.
3.  **Cloudinary:** For optimizing and hosting media assets.
The system replaces manual ledgers and verbal ordering, acting as the central nervous system for cafeteria operations in the Turbat region.

### 1.2.2 Product Features
The major features of the software are:
1.  **Digital Catalog:** A browsable, searchable list of all shops and products.
2.  **Smart Cart:** Persistent shopping cart allowing multiple items.
3.  **Real-Time Status:** Live updates on order progress (e.g., "Preparing").
4.  **Vendor Dashboard:** A comprehensive suite for shop owners to manage menus and orders.
5.  **Multi-Platform Support:** Native mobile app for customers and responsive web app for shop owners.

### 1.2.3 User Classes and Characteristics
| User Class | Description | Technical Skill Level |
| :--- | :--- | :--- |
| **Customer** | University students, faculty, and corporate employees in Turbat. | Low to Medium (Familiar with smartphones). |
| **Shop Owner** | Local vendors and cafeteria staff. | Low (interface designed for minimal friction). |
| **Administrator** | System maintainers with full access to the backend. | High. |

### 1.2.4 Operational Environment
The software is designed to operate in the following environments:
*   **Customer Side:** Android devices (API Level 21+) and iOS devices (iOS 11+).
*   **Vendor Side:** any modern web browser (Chrome, Safari, Edge) on tablets or laptops.
*   **Server Side:** Hosted on a Node.js runtime environment (e.g., Render/AWS) with a PostgreSQL database connection.

### 1.2.5 Assumptions and Dependencies
*   **Internet Connectivity:** It is assumed that both customers and vendors have access to a stable 3G/4G or Wi-Fi connection.
*   **Smartphone Availability:** It is assumed that the majority of the target audience (Students) owns a smartphone.
*   **Vendor Compliance:** It is assumed that shop owners will diligently update their stock status to prevent order discrepancies.

## 1.3 External Interface Requirement
### 1.3.1 User interface
The user interface follows **Google's Material Design 3** guidelines to ensure familiarity and ease of use.
*   **Consistency:** Buttons, fonts (Poppins/Inter), and colors are uniform across the app.
*   **Feedback:** Interactive elements provide visual feedback (ripples, loaders) to acknowledge user actions.
*   **Accessibility:** High contrast ratios and scalable text sizes are prioritized.

### 1.3.2 Internet Connectivity
The system requires a persistent internet connection to function:
*   **REST API:** For standard data fetching (GET /shops, POST /orders).
*   **WebSockets (Socket.io):** For real-time bi-directional communication (Order Alerts).
*   **Offline Handling:** The mobile app caches basic data (e.g., Shop Lists) to provide a degraded but functional experience during intermittent connectivity.

# Chapter 2: Literature Review

## 2.1 Introduction
The literature review provides a comprehensive analysis of existing food ordering systems and methodologies currently prevalent in the market. By studying established platforms, we can identify gaps in service, particularly within the specific context of **Turbat** and semi-closed environments like universities. This chapter evaluates the strengths and weaknesses of global giants and local informal methods to justify the need for the **360 Cafe and Outlets** system.

## 2.2 Existing Solutions
Currently, the food delivery and ordering landscape in Pakistan is dominated by a few large players, alongside informal manual methods. Below are the most relevant existing solutions:

### 2.2.1 Foodpanda
**Description:** Foodpanda is the market leader in Pakistan's food delivery sector. It connects customers with thousands of restaurants via a mobile app, handling logistics through a fleet of riders.
*   **Strengths:** Massive variety of restaurants, robust real-time tracking, and established payment integration.
*   **Weaknesses in Context:**
    *   **Geographical Limitation:** Foodpanda's coverage in developing non-urban centers like Turbat is often limited or non-existent.
    *   **Model Mismatch:** It focuses primarily on *delivery* (adding delivery fees), whereas 360 Cafe focuses on *pick-up/dine-in* for students already on campus.
    *   **Commission Fees:** High commissions (25-30%) make it unviable for small cafeteria vendors selling low-margin student meals.

### 2.2.2 Cheetay
**Description:** A local logistics and food delivery service that competes with Foodpanda in major cities.
*   **Strengths:** tailored for the Pakistani market with a focus on "desi" logistics.
*   **Weaknesses in Context:** Similar to Foodpanda, it lacks presence in smaller regions and does not cater to the specific workflow of a high-volume, fast-turnaround university cafeteria.

### 2.2.3 WhatsApp / Phone Ordering
**Description:** Many small vendors in Turbat rely on informal ordering via WhatsApp messages or phone calls.
*   **Strengths:** Zero cost, high familiarity, and direct communication with the shop owner.
*   **Weaknesses in Context:**
    *   **Unstructured Data:** Orders are free-text, leading to misunderstandings (e.g., "One burger" without specifying type).
    *   **Scalability:** A vendor cannot handle 50 concurrent WhatsApp messages during a lunch rush.
    *   **No Inventory Sync:** A customer ordering via message doesn't know if the item is out of stock until the vendor replies.

### 2.2.4 Manual Queuing (Traditional Method)
**Description:** The baseline method where customers walk to the counter, stand in line, place an order, pay cash, and wait for food.
*   **Strengths:** No technology barrier; anyone can do it.
*   **Weaknesses in Context:**
    *   **Inefficiency:** Significant time is wasted queuing.
    *   **Crowding:** Causes physical congestion in food courts.
    *   **Cash Risks:** Hygiene issues and lack of sales records for the shop owner.

**Conclusion:** None of the existing solutions adequately address the niche need for a **commission-free, pick-up focused, campus-centric** ordering system in Turbat. **360 Cafe and Outlets** fills this gap by digitizing the process without the overhead of delivery logistics.

# Chapter 3: Methodology

## 3.1 Methodology for Development
### 3.1.1 Introduction
To ensure a structured and efficient development process, this project adopts the **Agile Methodology**. Agile was chosen for its iterative nature, allowing for continuous feedback and adaptability. The development lifecycle is broken down into distinct sprints, focusing on delivering functional increments of the software (e.g., Auth first, then Product Listing, then Ordering).

### 3.1.2 Design Phase
In the design phase, the foundational blueprint of the system was established.
*   **Architecture Design:** A Microservices approach was selected to decouple the "Order Processing" logic from the "Product Catalog" to ensure scalability.
*   **Database Schema:** An Entity-Relationship (ER) model was designed in PostgreSQL to map the complex relationships between Shops, Categories, Products, and Orders.
*   **UI/UX Prototyping:** Wireframes for the mobile app (Material Design) and web dashboard were created to visualize user flows before coding.

### 3.1.3 Implementation Phase
This phase involved the actual coding of the system components:
*   **Backend:** Developed RESTful APIs using **Node.js** and **Express.js**, integrated with **PostgreSQL**.
*   **Customer App:** Built using **Flutter** for cross-platform compatibility (Android/iOS).
*   **Shop Owner App:** Developed as a responsive Flutter Web application.
*   **Integration:** The frontend was connected to backend endpoints using `http` client and `Socket.io` for real-time features.

### 3.1.4 Testing Phase
A rigorous testing strategy was employed to ensure reliability:
*   **Unit Testing:** Individual components (e.g., date formatters, cart calculation logic) were tested in isolation.
*   **Integration Testing:** Verified that the "Place Order" button correctly triggers a database entry and sends a notification to the Shop Owner app.
*   **User Acceptance Testing (UAT):** A pilot runner (simulated) checked if the flow from "Login" to "Order Complete" was intuitive.

### 3.1.5 Evaluation Phase
The final system was evaluated against the functional requirements found in Chapter 1. Performance metrics like "App Load Time" and "Search Latency" were measured to ensure they met the < 2-second benchmark.

## 3.2 System Architecture
The system follows a **Three-Tier Architecture**:
1.  **Presentation Tier (Frontend):**
    *   **Customer App:** Flutter mobile interface.
    *   **Shop Owner App:** Flutter web dashboard.
2.  **Application Tier (Backend):**
    *   **API Gateway:** Routes requests to appropriate services.
    *   **Microservices:** Auth Service, Shop Service, Product Service, Order Service.
3.  **Data Tier (Database):**
    *   **PostgreSQL:** Relational database storing user data, catalogs, and transaction logs.
    *   **Cloudinary:** Cloud storage for optimizing and serving images.

## 3.3 Hardware and Software Requirements
### 3.3.1 Hardware Requirements
*   **Development:** Laptop with minimum 8GB RAM, Core i5 Processor.
*   **Server:** Standard Cloud Instance (e.g., 512MB - 1GB RAM for Node.js process).
*   **Client (Customer):** Smartphone with at least 2GB RAM and Android 5.0+.
*   **Client (Shop Owner):** Tablet or Laptop with internet access.

### 3.3.2 Software Requirements
*   **Operating System:** Windows/macOS/Linux for development; Android/iOS for deployment.
*   **Languages:** Dart (Flutter), JavaScript (Node.js), SQL.
*   **Frameworks:** Express.js, Flutter SDK.
*   **Database:** PostgreSQL 14+.
*   **Tools:** VS Code, Postman (API Testing), Git (Version Control).

## 3.4 Software Design
### 3.4.1 Style Guide
The application adheres strictly to **Material Design 3** principles to ensure a modern and accessible interface.
*   **Color Palette:**
    *   *Primary:* Deep Orange (evoking appetite and energy).
    *   *Background:* Off-white/Light Grey (cleanliness).
*   **Typography:** **Poppins** is used for headings for a friendly, modern feel, while **Inter** is used for body text to maximize readability.
*   **Components:** Rounded corners (Border Radius 12px) are used on cards and buttons to create a softer, more approachable aesthetic.

### 3.4.2 Color Palette
The color scheme is chosen to stimulate appetite and ensure accessibility.
*   **Primary Color (Deep Orange #FF5722):** Used for primary buttons ("Add to Cart"), active states, and key highlights. It represents energy and enthusiasm.
*   **Secondary Color (Teal #009688):** Used for success states (e.g., "Order Completed") and secondary actions.
*   **Surface Color (White #FFFFFF):** The background for cards and dialogs to ensure content legibility.
*   **Error Color (Red #D32F2F):** Used for critical alerts (e.g., "Shop Closed", "Payment Failed").

### 3.4.3 Icons
The application utilizes the **Material Icons** library for consistency and recognition.
*   **Navigation:** Home (House), Cart (Shopping Cart), Profile (Person), Orders (Receipt).
*   **Actions:** Add (+), Remove (-), Delete (Trash Can), Edit (Pencil).
*   **Status:** Pending (Hourglass), Cooking (Outdoor Grill/Chef), Ready (Check Circle).

## 3.5 Use Cases Description
This section describes how different actors interact with the system to achieve specific goals.

### 3.5.1 Consumer (Customer)
**Actor:** A student, faculty member, or visitor.
**Goal:** To order food from a campus outlet.
**Preconditions:** The user must be logged in and valid shops must be available.
**Flow:**
1.  **Browse:** User opens the app and scrolls through the list of "Open" shops.
2.  **Search:** User types "Burger" into the search bar; the system filters results relevant to the query.
3.  **Select:** User taps on a product, selects quantity, and adds it to the cart.
4.  **Checkout:** User reviews the cart total and taps "Place Order".
5.  **Track:** User views the "Order Details" screen, watching the status change from "Pending" to "Ready".
6.  **Review:** After picking up the food, the user leaves a 5-star rating for the shop.

### 3.5.2 Shop Owner (Vendor)
**Actor:** A small business owner or cafeteria staff member.
**Goal:** To manage orders and store presence.
**Preconditions:** The user must be registered as a Vendor and have an active shop.
**Flow:**
1.  **Login:** Vendor logs into the Web Dashboard.
2.  **Toggle Status:** Vendor switches the shop to "Open" to start accepting orders.
3.  **Receive Order:** A notification chimes; a new "Pending" order appears in the Kitchen View.
4.  **Process:** Vendor taps "Accept" (status -> Preparing), then later "Mark Ready" (status -> Ready).
5.  **Handover:** When the student arrives, the Vendor taps "Complete Order".
6.  **Analyze:** At the end of the day, the Vendor checks the Dashboard to see total sales.

## 3.6 Final Interfaces
This section presents the mapped final interfaces of the **360 Cafe and Outlets** application, corresponding to the critical user flows.

### 3.6.1 Get Started Screen Interface
**Description:** The landing screen for users who have just installed the app.
*   **Elements:** App Logo, "Get Started" button, and a brief carousel illustrating the benefits (e.g., "Skip the Line").
*   **Function:** Directs the user to the Login or Registration flow.

### 3.6.2 Registration / Login
**Description:** The entry point for authentication.
*   **Elements:** Fields for Email, Password, and "Forgot Password?".
*   **Function:** Validates credentials against the backend Auth Service. For new students, a "Register" toggle collects Name, Phone, and University ID.

### 3.6.3 Create/Change PIN (Profile Security)
**Description:** While the app uses passwords, this corresponds to the "Change Password" section in settings.
*   **Elements:** "Current Password", "New Password", "Confirm Password".
*   **Function:** Updates the user's security credentials securely using Bcrypt hashing.

### 3.6.4 Home Screen Interface (Shop Discovery)
**Description:** The main dashboard for customers.
*   **Elements:** Search Bar (Top), Categories (Chips), and a List of Shop Cards showing Image, Name, and Status (Open/Closed).
*   **Function:** Allows users to find a specific outlet or browse what's available.

### 3.6.5 Product Details Screen Interface
**Description:** Detailed view of a specific food item.
*   **Elements:** Large food image, Price (Rs.), Description, Quantity selector (+/-), and "Add to Cart" button.
*   **Function:** The decision point for purchasing a specific item.

### 3.6.6 Cart Screen Interface
**Description:** A summary of selected items before purchase.
*   **Elements:** List of items, quantities, subtotal, and a "Place Order" button.
*   **Function:** Allows users to review their selection and finalize the transaction.

### 3.6.7 Order History Interface
**Description:** A log of past and current activities.
*   **Elements:** List of orders with IDs, Dates, Total Amount, and Status Chips (e.g., "Ready", "Completed").
*   **Function:** Provides a record of spending and allows tracking of active orders.

### 3.6.8 Notifications Screen Interface
**Description:** A center for updates.
*   **Elements:** List of alerts such as "Order #123 is Ready!" or "New Shop Opened!".
*   **Function:** Keeps the user informed without needing to constantly check the order screen.

### 3.6.9 User Profile Screen Interface
**Description:** Management of personal data.
*   **Elements:** User Avatar, Name, Email display, and links to "Edit Profile", "Change Password", and "Logout".
*   **Function:** Gives the user control over their account settings.

### 3.6.10 Vendor Dashboard (Shop Owner)
**Description:** The command center for shop owners (equivalent to "Send Money" or transaction management in finance apps).
*   **Elements:** KPI Cards (Total Revenue, Active Orders), Quick Action Grid (Manage Menu, Open/Close Shop).
*   **Function:** Provides a snapshot of the business's health.

### 3.6.11 Kitchen View (Order Fulfillment)
**Description:** The operational screen for kitchen staff.
*   **Elements:** a Kanban-style list of orders: "Pending", "Preparing", "Ready".
*   **Function:** Staff taps cards to move orders through stages, triggering specific notifications to the customer.

## 3.7 UML Diagram (Use Case Model)
The following Use Case Diagram illustrates the interactions between the primary actors (Customer, Shop Owner) and the system.

    Owner --> UC10
    Owner --> UC11
```

# Chapter 4: Implementation

## 4.1 Overview
This chapter details the technical realization of the **360 Cafe and Outlets** system. It describes how the theoretical design from Chapter 3 was translated into a functional software product. The implementation focuses on robust code quality, secure data handling, and a seamless user experience across the mobile and web platforms.

### 4.1.1 Key Features Implemented
*   **Secure Authentication:** Multi-role login for Customers and Shop Owners.
*   **Dynamic Catalog:** Real-time adding/editing of products by vendors.
*   **Smart Search:** Server-side filtering for shops and products.
*   **Digital Cart:** Persistent cart state management using Providers.
*   **Order Tracking:** Live status updates (Pending -> Preparing -> Ready).
*   **Push Notifications:** Alerts for critical updates on Android and Web.

## 4.2 System Overview
The system operates as a cohesive unit where the Frontend (Flutter) consumes APIs exposed by the Backend (Node.js).

### 4.2.1 User Interface
The User Interface (UI) is implemented using **Flutter** for the Customer App and **Flutter Web** for the Shop Owner Dashboard.
*   **Widgets:** Custom reusable widgets (e.g., `ShopCard`, `OrderTile`) ensures consistency.
*   **Responsiveness:** The layout adapts to different screen sizes using `LayoutBuilder` and `MediaQuery`.
*   **State Management:** The **Provider** package is used to manage application state (e.g., Cart contents, User Session) efficiently.

### 4.2.2 Authentication and Security
Security is paramount in the implementation:
*   **Passwords:** Stored as hashed strings using **Bcrypt** (12 salt rounds) to prevent leaks.
*   **Sessions:** Stateless authentication using **JSON Web Tokens (JWT)**. Every API request carries a token in the `Authorization` header.
*   **Validation:** Input validation (e.g., checking email format) occurs on both the client side and server side to prevent injection attacks.

### 4.2.3 Transaction Processing
The core function of the app is processing food orders:
1.  **Creation:** When a user places an order, a database transaction ensures that inventory is checked and the order record is created atomically.
2.  **Concurrency:** Database locking prevents two users from buying the last item simultaneously.
3.  **Integrity:** Orders are linked to specific users and shops via Foreign Keys, ensuring data consistency.

### 4.2.4 Financial Management (Sales Tracking)
While direct payment processing is simulated, the system includes robust financial tracking for vendors:
*   **Revenue Dashboard:** Shop owners see real-time calculation of "Today's Earnings" and "Total Revenue".
*   **Reporting:** The system aggregates data to show which products are best-sellers, aiding in financial decision-making.

### 4.2.5 Notification
The notification system is hybrid:
*   **Socket.io:** Used for instant, bi-directional updates while the app is open (e.g., "Order Accepted" toast).
*   **Firebase (FCM):** Used for pushing background notifications to Android devices when the app is closed.

### 4.2.6 Customer Support
*   **Feedback Loop:** A built-in "Rate & Review" system allows customers to provide feedback on orders.
*   **Help Center:** Static pages provide FAQs on how to use the app.

### 4.2.7 Compliance and Regulation
*   **Data Privacy:** The system stores only essential user data (Name, Email). No sensitive payment card information is stored on our servers.
*   **Transparency:** Users can view their entire order history, ensuring full transparency of their digital footprint.

## 4.3 Technologies and Tools Used
The following stack was utilized for implementation:

| Category | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend** | **Flutter (Dart)** | Building the Cross-Platform Mobile and Web Applications. |
| **Backend** | **Node.js, Express.js** | Creating the RESTful API and handling business logic. |
| **Database** | **PostgreSQL** | Relational Database Management System (RDBMS). |
| **Hosting** | **Supabase / Render** | Hosting the Database and Backend Services. |
| **Real-time** | **Socket.io** | Enabling live order updates. |
| **Notifications** | **Firebase (FCM)** | Sending push notifications to mobile devices. |
| **Version Control** | **Git & GitHub** | Source code management and CI/CD pipelines. |

# Chapter 5: Conclusion

## 5.1 Conclusion
The development of **360 Cafe and Outlets** represents a significant step forward in digitizing the food service industry within Turbat. By successfully creating a microservices-based architecture that bridges Customers and Shop Owners, the project has met its primary objectives of reducing wait times, improving order accuracy, and providing a modern, cashless-ready experience. The system is robust, scalable, and tailored effectively to the unique constraints of a university environment.

## 5.2 Problems Faced
During the development lifecycle, several technical and operational challenges were encountered and overcome:
*   **Real-Time Synchronization:** Ensuring that the "Kitchen View" updated instantly without refreshing the page was complex. This was solved by implementing a hybrid approach using **Socket.io** for active sessions.
*   **Cross-Platform Consistency:** Maintaining a consistent look and feel between the Mobile App (Flutter) and Web Dashboard (Flutter Web) required careful responsive design adjustments.
*   **State Management:** Managing the detailed state of a "Shopping Cart" across multiple screens and app restarts was challenging, solved by using the **Provider** pattern and local storage persistence.
*   **Image Optimization:** Initial tests showed slow loading speeds due to large food images. This was resolved by integrating **Cloudinary** for on-the-fly image compression and resizing.

## 5.3 Future Work of 360 Cafe and Outlets
While the current version is fully functional, several enhancements are planned for future iterations:
*   **Payment Gateway Integration:** Integrating real automated payments (Easypaisa/JazzCash API) to fully remove cash handling.
*   **AI Recommendations:** Implementing a machine learning model to suggest food items based on a user's order history (e.g., "You usually order Coffee at 10 AM").
*   **Delivery Logistics:** Expanding the scope to include a "Rider App" for delivery to hostels or off-campus locations.
*   **Loyalty Points:** Adding a gamification layer where students earn points for every order, redeemable for discounts.
*   **Google Maps Integration:** For precise location tracking of shops and delivery riders.

## Abbreviations
| Abbreviation | Full Form |
| :--- | :--- |
| **API** | Application Programming Interface |
| **JWT** | JSON Web Token |
| **FCM** | Firebase Cloud Messaging |
| **UI/UX** | User Interface / User Experience |
| **CRUD** | Create, Read, Update, Delete |
| **SQL** | Structured Query Language |
| **PWA** | Progressive Web App |
| **HTTP** | Hypertext Transfer Protocol |
| **JSON** | JavaScript Object Notation |
| **KPI** | Key Performance Indicator |



