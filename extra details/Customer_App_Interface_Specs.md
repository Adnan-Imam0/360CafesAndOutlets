# 3.7 Customer Application Interfaces

This section presents the mapped final interfaces for the **Customer App** of the 360 Cafe and Outlets system, reflecting the actual implementation. The application uses a modern bottom-navigation architecture with a streamlined "Google Sign-In" first approach.

### 3.7.0 Onboarding Screen (Splash)
**Description:** The welcome screen shown only on the first launch (`/onboarding`).
*   **Elements:**
    *   **Branding:** Large Logo, App Name, and Welcome Message.
    *   **Action:** "Get Started" button.
*   **Function:** Marks the app as "seen" in local storage and navigates to Login.

### 3.7.1 Authentication (Sign In & Onboarding)
**Description:** The simplified entry point for users (`/login`).
*   **Elements:**
    *   **Branding:** 360 Cafe&Outlets Logo and Tagline ("Order fresh food instantly").
    *   **Action:** Single "Sign in with Google" button.
*   **Function:** Authenticates via Google. If the user is new or has missing details, they are redirected to the **Complete Profile** screen.

### 3.7.2 Complete Profile (Onboarding)
**Description:** Mandatory step for new users to finalize their account (`/complete-profile`).
*   **Elements:**
    *   **Fields:** Display Name and Phone Number input.
    *   **Action:** "Save & Continue" button.
*   **Function:** Ensures every user has a valid contact number for delivery before entering the main app.

### 3.7.3 Home Screen (Discovery)
**Description:** The primary dashboard (`/home`) accessible via the **Home** bottom tab.
*   **Elements:**
    *   **Search Bar:** Top pinned search field for finding cafes and outlets.
    *   **Filters:** "Cafes" and "Outlets" category chips.
    *   **Shop Grid:** Visual cards displaying shop cover images, ratings, and addresses.
*   **Function:** Navigation hub. Selecting a shop opens the full **Shop Details** view.

### 3.7.4 Shop Details (Menu & Ordering)
**Description:** The store-front interface (`/shop/:id`) for browsing a specific vendor's offerings.
*   **Elements:**
    *   **Header:** Shop visuals, Status (Open/Closed), and Rating.
    *   **Menu Tools:** In-shop search and category filters (e.g., Burgers, Drinks).
    *   **Product List:** Items with images, descriptions, and prices.
    *   **Cart Controls:** "+" Add buttons. Shows a bottom "View Cart" summary bar when items are added.
*   **Function:** Enforces single-shop ordering (warns user if adding items from a different shop).

### 3.7.5 Checkout Screen
**Description:** The order confirmation page (`/checkout`).
*   **Elements:**
    *   **Cart Review:** List of items, quantities, and prices.
    *   **Address Selection:** Quick-select chips (Home/Work) and a manual address text field.
    *   **Payment:** "Total Amount" display.
    *   **Action:** "Place Order" button.
*   **Function:** Submits the order to the backend and clears the cart upon success.

### 3.7.6 Orders Screen (Tracking)
**Description:** The activity hub (`/orders`) accessible via the **Orders** bottom tab.
*   **Elements:**
    *   **Tabs:** "Active" (Live orders) vs "History" (Past orders).
    *   **Status Indicators:** Real-time color-coded chips (Pending, Preparing, Ready, Delivered).
    *   **Review Option:** "Rate Order" button appears for delivered items.
*   **Function:** Listens for live updates from the kitchen so users know exactly when food is ready.

### 3.7.7 User Profile
**Description:** Account settings (`/profile`) accessible via the **Profile** bottom tab.
*   **Elements:**
    *   **Identity:** Profile picture (editable), Name, Email, and Phone.
    *   **Address Book:** Link to "My Addresses" to manage saved delivery locations.
    *   **Logout:** Secure session termination.
*   **Function:** Manages personal details and delivery preferences.
