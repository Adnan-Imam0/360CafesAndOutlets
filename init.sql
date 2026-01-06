-- =========================================
-- FINAL DATABASE SCHEMA FOR 360 CAFE PROJECT
-- =========================================

-- =========================================
-- 1. CUSTOMERS TABLE (Phone Authentication)
-- =========================================

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    firebase_uid TEXT UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,

    -- Customer-specific profile fields
    display_name TEXT,
    profile_picture_url TEXT,  -- Customer's personal photo
    default_address TEXT,
    date_of_birth DATE,
    gender VARCHAR(10),
    preferences JSONB,

    -- Common fields
    fcm_token TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- 2. SHOP OWNERS TABLE (Email Authentication)
-- =========================================

CREATE TABLE shop_owners (
    owner_id SERIAL PRIMARY KEY,
    firebase_uid TEXT UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,

    -- Shop owner-specific profile fields
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    cnic VARCHAR(15) UNIQUE NOT NULL,
    permanent_address TEXT NOT NULL,
    business_license_number VARCHAR(50),
    tax_id VARCHAR(50),

    -- Common fields
    fcm_token TEXT,
    is_email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- 3. CUSTOMER ADDRESSES TABLE
-- =========================================

CREATE TABLE customer_addresses (
    address_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    address_label VARCHAR(50) NOT NULL DEFAULT 'Home',
    full_address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL DEFAULT 'Turbat',
    postal_code VARCHAR(20),
    latitude NUMERIC(10,8),
    longitude NUMERIC(11,8),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Ensure only one default address per customer
    UNIQUE(customer_id, is_default) DEFERRABLE INITIALLY DEFERRED
);

-- =========================================
-- 4. BUSINESS TABLES (Shops, Categories, Products)
-- =========================================

CREATE TABLE shops (
    shop_id SERIAL PRIMARY KEY,
    owner_id INTEGER NOT NULL REFERENCES shop_owners(owner_id) ON DELETE CASCADE,
    shop_name VARCHAR(255) NOT NULL,
    shop_type VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    phone_number VARCHAR(20),
    profile_picture_url TEXT,  -- Shop logo/branding image
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    is_accepting_orders BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    shop_id INTEGER NOT NULL REFERENCES shops(shop_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    shop_id INTEGER NOT NULL REFERENCES shops(shop_id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- 5. ORDER MANAGEMENT TABLES
-- =========================================

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    shop_id INTEGER NOT NULL REFERENCES shops(shop_id) ON DELETE RESTRICT,
    delivery_address_id INTEGER REFERENCES customer_addresses(address_id),
    total_amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    delivery_address TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL,
    price_per_item NUMERIC(10, 2) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- 6. REVIEW SYSTEM
-- =========================================

CREATE TABLE product_reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, customer_id)
);

-- =========================================
-- INDEXES FOR PERFORMANCE
-- =========================================

-- Customer indexes
CREATE INDEX idx_customers_firebase_uid ON customers(firebase_uid);
CREATE INDEX idx_customers_phone ON customers(phone_number);

-- Shop owner indexes
CREATE INDEX idx_shop_owners_firebase_uid ON shop_owners(firebase_uid);
CREATE INDEX idx_shop_owners_email ON shop_owners(email);
CREATE INDEX idx_shop_owners_username ON shop_owners(username);
CREATE INDEX idx_shop_owners_cnic ON shop_owners(cnic);

-- Address indexes
CREATE INDEX idx_customer_addresses_customer_id ON customer_addresses(customer_id);
CREATE INDEX idx_customer_addresses_default ON customer_addresses(customer_id, is_default);

-- Shop indexes
CREATE INDEX idx_shops_owner_id ON shops(owner_id);
CREATE INDEX idx_shops_status ON shops(status);
CREATE INDEX idx_shops_type ON shops(shop_type);

-- Product indexes
CREATE INDEX idx_products_shop_id ON products(shop_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_available ON products(shop_id, is_available);

-- Order indexes
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_shop_id ON orders(shop_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Review indexes
CREATE INDEX idx_product_reviews_product_id ON product_reviews(product_id);
CREATE INDEX idx_product_reviews_customer_id ON product_reviews(customer_id);
