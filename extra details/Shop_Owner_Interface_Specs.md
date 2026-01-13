# 3.6 Shop Owner Application Interfaces

This section presents the mapped final interfaces for the **Shop Owner App**, reflecting the actual implementation of the system. The application uses a responsive dashboard layout with a sidebar (desktop) or drawer (mobile) for navigation.

### 3.6.1 Authentication (Login & Registration)
**Description:** The entry point for shop owners to access their management panel.
*   **Elements:**
    *   **Login:** Email and Password fields, "Login" button, "Forgot Password?" link.
    *   **Registration:** Multi-step form collecting Shop Name, Owner Name, Contact Number, and Shop Category.
*   **Function:** Authenticates the user against the backend. Upon success, redirects to the Dashboard Overview.

### 3.6.2 Vendor Dashboard (Overview)
**Description:** The landing screen (`/`) acting as the command center for the business.
*   **Elements:**
    *   **Header:** Displays Shop Name, Profile Picture, and a global "OPEN/CLOSED" Toggle Switch to instantly manage shop availability.
    *   **KPI Cards:** A responsive grid displaying key metrics: "Total Revenue" (Green), "Active Orders" (Orange), "Total Orders" (Blue), and "Pending" (Red).
    *   **Quick Actions:** Shortcut buttons for "Manage Menu" and "Shop Details".
    *   **Recent Orders:** A concise list of the 5 most recent orders showing Order ID, Customer Name, and Total Amount.
*   **Function:** Provides a high-level snapshot of business health and quick access to critical actions.

### 3.6.3 Order Management (Kitchen View)
**Description:** The core operational screen (`/orders`) for processing customer orders.
*   **Elements:**
    *   **Tabs:** Three distinct tabs for workflow management:
        1.  **Pending:** New incoming orders requiring acceptance.
        2.  **Active:** Orders in "Accepted", "Preparing", or "Ready" states.
        3.  **Past:** History of "Delivered", "Cancelled", or "Rejected" orders.
    *   **Order Card:** detailed view for each order containing:
        *   **Header:** Order ID and Customer Name.
        *   **Details:** List of items with quantities and prices.
        *   **Contact:** Customer Phone and Delivery Address (if applicable).
    *   **Action Controls:**
        *   *Pending Tab:* "Accept" and "Reject" buttons.
        *   *Active Tab:* Status Dropdown to transition orders between "Accepted" -> "Preparing" -> "Ready" -> "Delivered".
*   **Function:** Allows kitchen staff to manage the entire lifecycle of an order from receipt to handover, triggering real-time updates to the customer.

### 3.6.4 Menu Management
**Description:** The inventory control interface (`/menu`).
*   **Elements:**
    *   **Search & Filter:** A text search bar and a "Category" dropdown filter (e.g., Fast Food, Desi) to quickly locate items.
    *   **Product Grid:** A grid layout of product cards, each showing:
        *   **Image:** Large cover image of the food item.
        *   **Info:** Name, Price (Rs.), and a truncated Description.
    *   **Floating Action Button:** A "+" button to navigate to the "Add Product" screen.
*   **Function:** Enables quick editing of product details, prices, and availability. Tapping a product card opens the "Edit Product" form.

### 3.6.5 My Shop (Storefront Management)
**Description:** The profile management screen (`/my-shop`) allowing owners to view their shop as customers see it.
*   **Elements:**
    *   **Visuals:** Cover Image and Profile Picture (Avatar).
    *   **Shop Info:** Shop Name, Type (Category), and Address.
    *   **Status Badge:** "Active" indicator.
    *   **Stats Bar:** A horizontal row summarizing total Orders, Revenue, and Active count.
    *   **Quick Links List:** Navigation items for "Manage Menu", "Order History", and "Settings".
*   **Function:** Serves as a "Review" page for the shop owner to ensure their branding and details are correct.
