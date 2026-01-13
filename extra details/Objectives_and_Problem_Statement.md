# OBJECTIVES AND PROBLEM STATEMENT

## 1. Problem Statement

The educational and corporate sectors in **Turbat** are undergoing a rapid digital transformation, yet the food service industry within these institutions remains tethered to archaic, manual operational models. The **University of Turbat**, being a hub of intellectual growth for hundreds of students and faculty, faces significant logistical challenges during peak dining hours. The absence of a streamlined, technology-driven ordering system creates a ripple effect of inefficiency that impacts every stakeholder in the ecosystem—from the hungry student to the stressed cafeteria vendor.

The core problems identified in the current manual setup are multifaceted:

### 1.1. Physical Congestion and Time Wastage
The most visible symptom of the current system is the chaotic "lunch rush." During short break intervals (typically 30-60 minutes), hundreds of students converge on a few cafeteria outlets.
*   **The Queue Effect:** Students are forced to stand in long physical lines just to place an order, often waiting 15-20 minutes before they can even speak to a cashier.
*   **The Waiting Game:** After ordering, they must wait again for the food to be prepared, often hovering around the counter in a disorganized crowd.
*   **Impact:** This physical congestion obstructs pathways, creates a noisy and stressful environment, and significantly eats into the students' limited relaxation time. Many students choose to skip meals entirely rather than endure the chaos, resulting in lost revenue for vendors.

### 1.2. Inefficient Order Taking and Processing
The reliance on verbal communication and handwritten slips is fundamentally flawed in a high-noise environment.
*   **Human Error:** In the din of a crowded cafeteria, orders are frequently misheard (e.g., "Chicken Burger" vs. "Beef Burger"), leading to food waste and customer dissatisfaction.
*   **Lack of Synchronization:** There is often a disconnect between the person taking the money and the kitchen staff preparing the food. Orders get lost, skipped, or prepared out of sequence, violating the First-In-First-Out (FIFO) principle and causing unfair delays for customers.

### 1.3. Inventory Visiblity and Disappointment
In the current analog setup, a menu board is static. It does not reflect the real-time reality of the kitchen.
*   **The "Out of Stock" Friction:** A customer might wait 10 minutes in line, deciding on a specific meal, only to reach the counter and be told, "Sorry, that's finished." This leads to immediate frustration and often results in the customer leaving the queue entirely.
*   **Waste Management:** Conversely, vendors may over-prepare unpopular items because they lack a way to signal "Specials" or push slow-moving inventory effectively to the students.

### 1.4. Operational Opacity (Data Invisibility)
Perhaps the most critical business failure is the lack of data. Shop owners operate on intuition rather than intelligence.
*   **No Analytics:** Vendors cannot answer basic questions with certainty: *What is my best-selling item? What is my busiest hour? How much revenue did I lose today due to slow service?*
*   **Blind Planning:** Without historical data, inventory purchasing is a guessing game, leading to either spoilage (waste) or shortages (lost sales).

### 1.5. Hygiene and Cash Dependencies
The exclusive reliance on physical cash is a bottleneck and a health risk.
*   **Transaction Velocity:** Fumbling for change slows down the line significantly. A 30-second cash exchange per customer adds up to hours of lost service time over a day.
*   **Hygiene:** In a food environment, the same hands handling dusty currency notes are often involved in serving food, posing cross-contamination risks.

---

## 2. Project Objectives

The **360 Cafe and Outlets** project aims to dismantle these inefficiencies through a comprehensive digital intervention. Our goal is not merely to build an "app," but to engineer a **Cyber-Physical System** that harmonizes the digital flow of information with the physical flow of food preparation.

### 2.1. Primary Objectives (Functionality & Impact)

**1. Drastic Reduction in Wait Times (The "Zero-Queue" Goal)**
The primary metric of success is time. We aim to reduce the total "Order-to-Eating" time by at least **40%**.
*   **Strategy:** By decoupling the *ordering* process from the *physical location*, students can place orders from their classrooms 10 minutes before the break starts.
*   **Outcome:** When the student arrives at the cafeteria, their food is already in the "Preparing" or "Ready" stage, turning a 20-minute ordeal into a 2-minute pickup.

**2. Operational Synchronization via Kanban Workflow**
We aim to professionalize the kitchen operations.
*   **Strategy:** Replacing verbal shouting with a digital **Kitchen Dashboard**. Orders appear as cards that move from *Pending* $\rightarrow$ *Preparing* $\rightarrow$ *Ready*.
*   **Outcome:** This enforces a disciplined, linear workflow, reducing errors to near zero and ensuring that the kitchen remains calm and organized even during peak loads.

**3. Real-Time Inventory Management**
We aim to eliminate the "Out of Stock" disappointment.
*   **Strategy:** Providing Shop Owners with an instant "Toggle Switch" for every menu item.
*   **Outcome:** If an item runs out, the owner flips a switch, and it instantly disappears or grays out on the  phones of 2,000 students. This creates a trust-based relationship where the digital menu is the single source of truth.

### 2.2. Secondary Objectives (Ecosystem & Growth)

**1. Data-Driven Business Intelligence**
To empower local vendors with enterprise-grade insights.
*   **Goal:** Provide automated daily reports showing Total Revenue, Order Counts, and Top 5 Products.
*   **Impact:** Enabling vendors to optimize their stock purchasing and staffing based on actual demand trends.

**2. Scalability and Reliability**
To build a system that grows with the university.
*   **Goal:** The backend architecture (Microservices) must support horizontal scaling, capable of handling 500+ concurrent users without crashing.
*   **Impact:** Ensuring the system remains reliable (99.9% uptime) even as new shops and students join the platform.

**3. Modernization of Campus Culture**
To serve as a flagship project for digitization at UoT.
*   **Goal:** Creating a "Cashless-Ready" environment that encourages digital literacy.
*   **Impact:** Setting a precedent for future student projects and improving the modern image of the institution.

### 2.3. Technical Objectives
*   **Latency:** Ensure API response times are under **200ms** to provide a "native" feel.
*   **Cross-Platform:** Deliver a consistent experience across Android (Customer) and Web (Shop Owner).
*   **Security:** Protect user PII (Personally Identifiable Information) with industry-standard encryption (Bcrypt, JWT, SSL).
