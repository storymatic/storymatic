-- StoryMatic E-commerce Database Schema
-- Created for complete e-commerce functionality

-- Create database
CREATE DATABASE storymatic_db;
USE storymatic_db;

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    newsletter_subscribed BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL
);

-- ============================================================================
-- USER ADDRESSES TABLE
-- ============================================================================
CREATE TABLE user_addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    address_type ENUM('billing', 'shipping') NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    company VARCHAR(100),
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================================
-- PRODUCT CATEGORIES TABLE
-- ============================================================================
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    image_url VARCHAR(500),
    icon VARCHAR(50),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- PRODUCTS TABLE
-- ============================================================================
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    category_id INT NOT NULL,
    short_description TEXT,
    long_description TEXT,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    sku VARCHAR(100) UNIQUE,
    status ENUM('active', 'inactive', 'draft') DEFAULT 'active',
    featured BOOLEAN DEFAULT FALSE,
    digital_product BOOLEAN DEFAULT TRUE,
    download_limit INT DEFAULT 5,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    download_count INT DEFAULT 0,
    view_count INT DEFAULT 0,
    meta_title VARCHAR(255),
    meta_description TEXT,
    tags TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_featured (featured),
    FULLTEXT(name, short_description, tags)
);

-- ============================================================================
-- PRODUCT IMAGES TABLE
-- ============================================================================
CREATE TABLE product_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    sort_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- ============================================================================
-- PRODUCT FILES TABLE (Digital Downloads)
-- ============================================================================
CREATE TABLE product_files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    download_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- ============================================================================
-- PRODUCT FEATURES TABLE
-- ============================================================================
CREATE TABLE product_features (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    feature_text VARCHAR(255) NOT NULL,
    sort_order INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- ============================================================================
-- ORDERS TABLE
-- ============================================================================
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id INT,
    guest_email VARCHAR(255),
    status ENUM('pending', 'processing', 'completed', 'cancelled', 'refunded') DEFAULT 'pending',
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    payment_method VARCHAR(50),
    payment_intent_id VARCHAR(255),
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    billing_first_name VARCHAR(100) NOT NULL,
    billing_last_name VARCHAR(100) NOT NULL,
    billing_email VARCHAR(255) NOT NULL,
    billing_company VARCHAR(100),
    billing_address_line_1 VARCHAR(255) NOT NULL,
    billing_address_line_2 VARCHAR(255),
    billing_city VARCHAR(100) NOT NULL,
    billing_state VARCHAR(100) NOT NULL,
    billing_postal_code VARCHAR(20) NOT NULL,
    billing_country VARCHAR(100) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    INDEX idx_payment_status (payment_status)
);

-- ============================================================================
-- ORDER ITEMS TABLE
-- ============================================================================
CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_sku VARCHAR(100),
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

-- ============================================================================
-- DOWNLOAD HISTORY TABLE
-- ============================================================================
CREATE TABLE download_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    user_id INT,
    product_id INT NOT NULL,
    file_id INT NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (file_id) REFERENCES product_files(id) ON DELETE CASCADE
);

-- ============================================================================
-- SHOPPING CART TABLE
-- ============================================================================
CREATE TABLE shopping_cart (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    session_id VARCHAR(255),
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_session (session_id)
);

-- ============================================================================
-- PRODUCT REVIEWS TABLE
-- ============================================================================
CREATE TABLE product_reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    user_id INT,
    order_id INT,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    review_text TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT TRUE,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL
);

-- ============================================================================
-- NEWSLETTER SUBSCRIBERS TABLE
-- ============================================================================
CREATE TABLE newsletter_subscribers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    status ENUM('subscribed', 'unsubscribed', 'bounced') DEFAULT 'subscribed',
    subscription_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unsubscription_date TIMESTAMP NULL,
    source VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT
);

-- ============================================================================
-- DISCOUNT CODES TABLE
-- ============================================================================
CREATE TABLE discount_codes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    type ENUM('percentage', 'fixed_amount') NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    minimum_order_amount DECIMAL(10,2) DEFAULT 0,
    maximum_discount_amount DECIMAL(10,2),
    usage_limit INT,
    usage_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- CONTACT MESSAGES TABLE
-- ============================================================================
CREATE TABLE contact_messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status ENUM('new', 'read', 'replied', 'closed') DEFAULT 'new',
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- SITE SETTINGS TABLE
-- ============================================================================
CREATE TABLE site_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type VARCHAR(50) DEFAULT 'text',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- ANALYTICS TABLE
-- ============================================================================
CREATE TABLE analytics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_type VARCHAR(100) NOT NULL,
    event_data JSON,
    user_id INT,
    session_id VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    referrer VARCHAR(500),
    page_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_event_type (event_type),
    INDEX idx_created_at (created_at)
);

-- ============================================================================
-- INSERT SAMPLE DATA
-- ============================================================================

-- Insert Categories
INSERT INTO categories (name, slug, description, icon, sort_order) VALUES
('Bundles', 'bundles', 'Complete packages with everything you need to succeed', 'package', 1),
('Templates', 'templates', 'Ready-to-use designs that save hours of work', 'file-text', 2),
('Checklists', 'checklists', 'Step-by-step guides that ensure you never miss important tasks', 'check-square', 3);

-- Insert Products
INSERT INTO products (name, slug, category_id, short_description, long_description, price, original_price, discount_percentage, sku, featured, rating, review_count, download_count, tags) VALUES
('Freelancer Starter Bundle', 'freelancer-starter-bundle', 1, 'Complete package to launch your freelancing career with contracts, proposals, and pricing guides.', 'This comprehensive bundle includes everything you need to start your freelancing journey successfully. Get professional contract templates, winning proposal formats, pricing calculators, client onboarding processes, and email templates that convert prospects into clients.', 49.00, 99.00, 51, 'FSB-001', TRUE, 4.9, 127, 2847, 'freelancer,contracts,proposals,templates,business'),

('Social Media Master Kit', 'social-media-master-kit', 2, 'Never run out of content ideas again with 365 days of social media templates.', 'Transform your social media presence with this ultimate content creation toolkit. Includes 365 unique post ideas, Instagram story templates, hashtag research guides, content calendar templates, and proven engagement scripts that boost your reach and conversions.', 29.00, 59.00, 51, 'SMK-001', TRUE, 4.8, 89, 4521, 'social media,content,templates,instagram,marketing'),

('E-commerce Launch Checklist', 'ecommerce-launch-checklist', 3, 'Step-by-step checklist to launch your online store without missing critical steps.', 'Launch your e-commerce store with confidence using this detailed checklist. Covers pre-launch preparation, technical setup, marketing strategies, legal requirements, analytics implementation, and post-launch optimization tasks.', 19.00, 39.00, 51, 'ELC-001', TRUE, 5.0, 45, 1834, 'ecommerce,checklist,launch,online store,business'),

('Email Marketing Automation Bundle', 'email-marketing-automation-bundle', 1, 'Automated email sequences that convert visitors into customers.', 'Master email marketing with proven automation sequences. Includes welcome series templates, abandoned cart recovery emails, re-engagement campaigns, upsell sequences, and newsletter templates designed for maximum conversion rates.', 39.00, 79.00, 51, 'EMA-001', TRUE, 4.7, 73, 3194, 'email marketing,automation,sequences,conversion,templates'),

('Brand Identity Worksheet', 'brand-identity-worksheet', 2, 'Define your brand identity with this comprehensive worksheet and guide.', 'Create a powerful brand identity with this step-by-step worksheet. Covers brand strategy development, color psychology, typography selection, voice and tone definition, and logo design guidelines for consistent brand messaging.', 15.00, 29.00, 48, 'BIW-001', FALSE, 4.6, 52, 2156, 'branding,identity,worksheet,design,strategy'),

('Content Creation Checklist', 'content-creation-checklist', 3, 'Streamline your content creation process with proven checklists.', 'Never miss a step in your content creation process. Includes checklists for blog posts, video content, podcast planning, SEO optimization, and publishing schedules to ensure consistent, high-quality content output.', 12.00, 25.00, 52, 'CCC-001', FALSE, 4.8, 34, 1745, 'content creation,blogging,video,podcast,SEO');

-- Insert Product Images
INSERT INTO product_images (product_id, image_url, alt_text, is_primary) VALUES
(1, 'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=600&h=400&fit=crop', 'Freelancer Starter Bundle', TRUE),
(2, 'https://images.unsplash.com/photo-1611926653458-09294b3142bf?w=600&h=400&fit=crop', 'Social Media Master Kit', TRUE),
(3, 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=600&h=400&fit=crop', 'E-commerce Launch Checklist', TRUE),
(4, 'https://images.unsplash.com/photo-1596526131083-e8c633c948d2?w=600&h=400&fit=crop', 'Email Marketing Automation Bundle', TRUE),
(5, 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=600&h=400&fit=crop', 'Brand Identity Worksheet', TRUE),
(6, 'https://images.unsplash.com/photo-1432888622747-4eb9a8efeb07?w=600&h=400&fit=crop', 'Content Creation Checklist', TRUE);

-- Insert Product Features
INSERT INTO product_features (product_id, feature_text, sort_order) VALUES
(1, '50+ Professional Templates', 1),
(1, 'Contract Templates & Legal Forms', 2),
(1, 'Pricing Calculator Spreadsheet', 3),
(1, 'Client Onboarding Process', 4),
(1, 'Email Templates That Convert', 5),

(2, '365 Unique Post Ideas', 1),
(2, 'Instagram Story Templates', 2),
(2, 'Hashtag Research Guide', 3),
(2, 'Content Calendar Templates', 4),
(2, 'Engagement Scripts & Strategies', 5),

(3, 'Complete Launch Timeline', 1),
(3, 'Pre-Launch Task Checklist', 2),
(3, 'Marketing Strategy Checklist', 3),
(3, 'Legal Requirements Guide', 4),
(3, 'Analytics Setup Instructions', 5),

(4, 'Welcome Email Series', 1),
(4, 'Abandoned Cart Recovery', 2),
(4, 'Re-engagement Campaigns', 3),
(4, 'Upsell Email Sequences', 4),
(4, 'Newsletter Templates', 5),

(5, 'Brand Strategy Framework', 1),
(5, 'Color Psychology Guide', 2),
(5, 'Typography Selection Guide', 3),
(5, 'Voice & Tone Worksheet', 4),
(5, 'Logo Design Guidelines', 5),

(6, 'Blog Post Creation Checklist', 1),
(6, 'Video Content Planning', 2),
(6, 'Podcast Episode Checklist', 3),
(6, 'SEO Optimization Guide', 4),
(6, 'Publishing Schedule Template', 5);

-- Insert Sample Product Files
INSERT INTO product_files (product_id, file_name, original_name, file_path, file_size, file_type) VALUES
(1, 'freelancer_bundle_main.zip', 'Freelancer Starter Bundle.zip', '/downloads/products/1/freelancer_bundle_main.zip', 15728640, 'application/zip'),
(1, 'contracts_templates.pdf', 'Contract Templates.pdf', '/downloads/products/1/contracts_templates.pdf', 2048576, 'application/pdf'),
(1, 'pricing_calculator.xlsx', 'Pricing Calculator.xlsx', '/downloads/products/1/pricing_calculator.xlsx', 512000, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),

(2, 'social_media_kit.zip', 'Social Media Master Kit.zip', '/downloads/products/2/social_media_kit.zip', 25165824, 'application/zip'),
(2, '365_post_ideas.pdf', '365 Post Ideas.pdf', '/downloads/products/2/365_post_ideas.pdf', 3145728, 'application/pdf'),
(2, 'story_templates.psd', 'Instagram Story Templates.psd', '/downloads/products/2/story_templates.psd', 52428800, 'image/vnd.adobe.photoshop'),

(3, 'ecommerce_checklist.pdf', 'E-commerce Launch Checklist.pdf', '/downloads/products/3/ecommerce_checklist.pdf', 1048576, 'application/pdf'),
(3, 'launch_timeline.xlsx', 'Launch Timeline.xlsx', '/downloads/products/3/launch_timeline.xlsx', 256000, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),

(4, 'email_automation_bundle.zip', 'Email Marketing Automation Bundle.zip', '/downloads/products/4/email_automation_bundle.zip', 10485760, 'application/zip'),
(4, 'email_templates.html', 'Email Templates.html', '/downloads/products/4/email_templates.html', 512000, 'text/html'),

(5, 'brand_identity_worksheet.pdf', 'Brand Identity Worksheet.pdf', '/downloads/products/5/brand_identity_worksheet.pdf', 2097152, 'application/pdf'),
(5, 'brand_guide_template.indd', 'Brand Guide Template.indd', '/downloads/products/5/brand_guide_template.indd', 15728640, 'application/x-indesign'),

(6, 'content_checklists.pdf', 'Content Creation Checklists.pdf', '/downloads/products/6/content_checklists.pdf', 1536000, 'application/pdf'),
(6, 'editorial_calendar.xlsx', 'Editorial Calendar Template.xlsx', '/downloads/products/6/editorial_calendar.xlsx', 384000, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

-- Insert Sample Users
INSERT INTO users (email, password_hash, first_name, last_name, newsletter_subscribed, email_verified) VALUES
('john.doe@example.com', '$2b$12$LQv3c1yqBTLvbPVc5NZPmu.qElNKlhEBhPw8R5Ks6E8JQYvKjbQOm', 'John', 'Doe', TRUE, TRUE),
('sarah.smith@example.com', '$2b$12$LQv3c1yqBTLvbPVc5NZPmu.qElNKlhEBhPw8R5Ks6E8JQYvKjbQOm', 'Sarah', 'Smith', TRUE, TRUE),
('mike.johnson@example.com', '$2b$12$LQv3c1yqBTLvbPVc5NZPmu.qElNKlhEBhPw8R5Ks6E8JQYvKjbQOm', 'Mike', 'Johnson', FALSE, TRUE),
('emily.brown@example.com', '$2b$12$LQv3c1yqBTLvbPVc5NZPmu.qElNKlhEBhPw8R5Ks6E8JQYvKjbQOm', 'Emily', 'Brown', TRUE, TRUE);

-- Insert Sample Orders
INSERT INTO orders (order_number, user_id, status, payment_status, payment_method, subtotal, total_amount, billing_first_name, billing_last_name, billing_email, billing_address_line_1, billing_city, billing_state, billing_postal_code, billing_country, completed_at) VALUES
('SM-2024-001', 1, 'completed', 'paid', 'stripe', 78.00, 78.00, 'John', 'Doe', 'john.doe@example.com', '123 Main St', 'New York', 'NY', '10001', 'USA', '2024-07-15 14:30:00'),
('SM-2024-002', 2, 'completed', 'paid', 'paypal', 29.00, 29.00, 'Sarah', 'Smith', 'sarah.smith@example.com', '456 Oak Ave', 'Los Angeles', 'CA', '90210', 'USA', '2024-07-16 09:15:00'),
('SM-2024-003', 3, 'processing', 'paid', 'stripe', 49.00, 49.00, 'Mike', 'Johnson', 'mike.johnson@example.com', '789 Pine St', 'Chicago', 'IL', '60601', 'USA', NULL);

-- Insert Sample Order Items
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, total_price) VALUES
(1, 1, 'Freelancer Starter Bundle', 1, 49.00, 49.00),
(1, 2, 'Social Media Master Kit', 1, 29.00, 29.00),
(2, 2, 'Social Media Master Kit', 1, 29.00, 29.00),
(3, 1, 'Freelancer Starter Bundle', 1, 49.00, 49.00);

-- Insert Sample Reviews
INSERT INTO product_reviews (product_id, user_id, order_id, rating, title, review_text, is_verified_purchase) VALUES
(1, 1, 1, 5, 'Amazing bundle for new freelancers!', 'This bundle saved me months of work. The contract templates are professional and the pricing calculator helped me set competitive rates. Highly recommended!', TRUE),
(2, 1, 1, 5, 'Content creation made easy', 'The 365 post ideas are gold! Never running out of content again. The templates are beautiful and easy to customize.', TRUE),
(2, 2, 2, 5, 'Perfect for busy entrepreneurs', 'As a busy business owner, this kit is a lifesaver. The content calendar alone is worth the price!', TRUE),
(1, 4, NULL, 4, 'Great value for money', 'Comprehensive bundle with lots of useful templates. The onboarding process template is particularly helpful.', FALSE);

-- Insert Newsletter Subscribers
INSERT INTO newsletter_subscribers (email, first_name, last_name, source) VALUES
('john.doe@example.com', 'John', 'Doe', 'website'),
('sarah.smith@example.com', 'Sarah', 'Smith', 'website'),
('emily.brown@example.com', 'Emily', 'Brown', 'website'),
('newsletter1@example.com', 'Alex', 'Wilson', 'popup'),
('newsletter2@example.com', 'Lisa', 'Garcia', 'popup'),
('newsletter3@example.com', 'David', 'Martinez', 'footer');

-- Insert Discount Codes
INSERT INTO discount_codes (code, description, type, value, minimum_order_amount, usage_limit, valid_until) VALUES
('WELCOME20', 'Welcome discount for new customers', 'percentage', 20.00, 25.00, 100, '2024-12-31 23:59:59'),
('BUNDLE50', 'Special bundle discount', 'fixed_amount', 10.00, 50.00, 50, '2024-11-30 23:59:59'),
('EARLY2024', 'Early bird special', 'percentage', 15.00, 0.00, NULL, '2024-09-30 23:59:59');

-- Insert Site Settings
INSERT INTO site_settings (setting_key, setting_value, setting_type, description) VALUES
('site_name', 'StoryMatic', 'text', 'Website name'),
('site_tagline', 'Your Success Story Starts Here', 'text', 'Website tagline'),
('contact_email', 'hello@storymatic.com', 'email', 'Contact email address'),
('support_email', 'support@storymatic.com', 'email', 'Support email address'),
('currency', 'USD', 'text', 'Default currency'),
('tax_rate', '0.00', 'number', 'Tax rate percentage'),
('enable_reviews', 'true', 'boolean', 'Enable product reviews'),
('enable_newsletter', 'true', 'boolean', 'Enable newsletter signup'),
('download_limit', '5', 'number', 'Default download limit per product'),
('order_number_prefix', 'SM-', 'text', 'Order number prefix');

-- Insert Sample Contact Messages
INSERT INTO contact_messages (name, email, subject, message, status) VALUES
('Jennifer Lee', 'jennifer@example.com', 'Product Question', 'Hi, I was wondering if the Freelancer Bundle includes invoice templates?', 'replied'),
('Robert Chen', 'robert@example.com', 'Technical Support', 'I am having trouble downloading my purchased files. Can you help?', 'new'),
('Amanda Taylor', 'amanda@example.com', 'Partnership Inquiry', 'I would like to discuss a potential collaboration opportunity.', 'read');

-- Create Indexes for Performance
CREATE INDEX idx_products_category_status ON products(category_id, status);
CREATE INDEX idx_products_featured ON products(featured, status);
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_order_items_order_product ON order_items(order_id, product_id);
CREATE INDEX idx_reviews_product_approved ON product_reviews(product_id, is_approved);
CREATE INDEX idx_downloads_user_product ON download_history(user_id, product_id);

-- Create Views for Common Queries
CREATE VIEW product_stats AS
SELECT 
    p.id,
    p.name,
    p.price,
    p.rating,
    p.review_count,
    p.download_count,
    c.name as category_name,
    COUNT(DISTINCT r.id) as total_reviews,
    AVG(r.rating) as avg_rating,
    SUM(oi.quantity) as total_sales
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN product_reviews r ON p.id = r.product_id AND r.is_approved = TRUE
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'completed'
WHERE p.status = 'active'
GROUP BY p.id;

CREATE VIEW order_summary AS
SELECT 
    o.id,
    o.order_number,
    o.status,
    o.total_amount,
    o.created_at,
    CONCAT(o.billing_first_name, ' ', o.billing_last_name) as customer_name,
    o.billing_email,
    COUNT(oi.id) as item_count
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id;

-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- Procedure to update product rating after new review
DELIMITER //
CREATE PROCEDURE UpdateProductRating(IN product_id INT)
BEGIN
    UPDATE products p
    SET 
        rating = (
            SELECT ROUND(AVG(rating), 2) 
            FROM product_reviews 
            WHERE product_id = p.id AND is_approved = TRUE
        ),
        review_count = (
            SELECT COUNT(*) 
            FROM product_reviews 
            WHERE product_id = p.id AND is_approved = TRUE
        )
    WHERE p.id = product_id;
END //
DELIMITER ;

-- Procedure to process order completion
DELIMITER //
CREATE PROCEDURE CompleteOrder(IN order_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE prod_id INT;
    DECLARE item_quantity INT;
    
    DECLARE item_cursor CURSOR FOR 
        SELECT product_id, quantity 
        FROM order_items 
        WHERE order_id = order_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Update order status
    UPDATE orders 
    SET status = 'completed', 
        payment_status = 'paid',
        completed_at = CURRENT_TIMESTAMP 
    WHERE id = order_id;
    
    -- Update product download counts
    OPEN item_cursor;
    read_loop: LOOP
        FETCH item_cursor INTO prod_id, item_quantity;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        UPDATE products 
        SET download_count = download_count + item_quantity 
        WHERE id = prod_id;
    END LOOP;
    CLOSE item_cursor;
END //
DELIMITER ;

-- Procedure to clean up old cart items
DELIMITER //
CREATE PROCEDURE CleanOldCartItems()
BEGIN
    DELETE FROM shopping_cart 
    WHERE updated_at < DATE_SUB(NOW(), INTERVAL 30 DAY);
END //
DELIMITER ;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger to update product rating after review insert
DELIMITER //
CREATE TRIGGER after_review_insert
    AFTER INSERT ON product_reviews
    FOR EACH ROW
BEGIN
    CALL UpdateProductRating(NEW.product_id);
END //
DELIMITER ;

-- Trigger to update product rating after review update
DELIMITER //
CREATE TRIGGER after_review_update
    AFTER UPDATE ON product_reviews
    FOR EACH ROW
BEGIN
    CALL UpdateProductRating(NEW.product_id);
END //
DELIMITER ;

-- Trigger to generate order number
DELIMITER //
CREATE TRIGGER before_order_insert
    BEFORE INSERT ON orders
    FOR EACH ROW
BEGIN
    IF NEW.order_number IS NULL THEN
        SET NEW.order_number = CONCAT('SM-', YEAR(NOW()), '-', LPAD(LAST_INSERT_ID() + 1, 6, '0'));
    END IF;
END //
DELIMITER ;

-- ============================================================================
-- ADDITIONAL SAMPLE DATA
-- ============================================================================

-- Insert more sample analytics data
INSERT INTO analytics (event_type, event_data, user_id, session_id, ip_address, page_url) VALUES
('page_view', '{"page": "home", "referrer": "google.com"}', NULL, 'sess_123456', '192.168.1.1', '/'),
('page_view', '{"page": "shop", "category": "bundles"}', 1, 'sess_123457', '192.168.1.2', '/shop'),
('product_view', '{"product_id": 1, "product_name": "Freelancer Starter Bundle"}', 1, 'sess_123457', '192.168.1.2', '/product/freelancer-starter-bundle'),
('add_to_cart', '{"product_id": 1, "quantity": 1}', 1, 'sess_123457', '192.168.1.2', '/shop'),
('checkout_start', '{"cart_total": 49.00, "item_count": 1}', 1, 'sess_123457', '192.168.1.2', '/checkout'),
('purchase_complete', '{"order_id": 1, "total": 78.00}', 1, 'sess_123457', '192.168.1.2', '/success');

-- Insert more newsletter subscribers
INSERT INTO newsletter_subscribers (email, first_name, source) VALUES
('subscriber1@example.com', 'Jessica', 'homepage_banner'),
('subscriber2@example.com', 'Michael', 'exit_intent_popup'),
('subscriber3@example.com', 'Ashley', 'footer_signup'),
('subscriber4@example.com', 'Christopher', 'product_page'),
('subscriber5@example.com', 'Rachel', 'blog_post');

-- ============================================================================
-- USEFUL QUERIES FOR APPLICATION
-- ============================================================================

-- Get featured products with category and images
/*
SELECT 
    p.id, p.name, p.slug, p.short_description, p.price, p.original_price,
    p.rating, p.download_count, p.featured,
    c.name as category_name, c.slug as category_slug,
    pi.image_url, pi.alt_text
FROM products p
JOIN categories c ON p.category_id = c.id
LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = TRUE
WHERE p.status = 'active' AND p.featured = TRUE
ORDER BY p.created_at DESC;
*/

-- Get product with all details
/*
SELECT 
    p.*,
    c.name as category_name,
    GROUP_CONCAT(pf.feature_text ORDER BY pf.sort_order SEPARATOR '|') as features,
    pi.image_url as primary_image
FROM products p
JOIN categories c ON p.category_id = c.id
LEFT JOIN product_features pf ON p.id = pf.product_id
LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = TRUE
WHERE p.slug = 'product-slug'
GROUP BY p.id;
*/

-- Get user's order history
/*
SELECT 
    o.id, o.order_number, o.status, o.total_amount, o.created_at,
    COUNT(oi.id) as item_count,
    GROUP_CONCAT(oi.product_name SEPARATOR ', ') as products
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.user_id = 1
GROUP BY o.id
ORDER BY o.created_at DESC;
*/

-- Get bestselling products
/*
SELECT 
    p.id, p.name, p.price, p.rating,
    c.name as category_name,
    SUM(oi.quantity) as total_sold,
    pi.image_url
FROM products p
JOIN categories c ON p.category_id = c.id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'completed'
LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = TRUE
WHERE p.status = 'active'
GROUP BY p.id
ORDER BY total_sold DESC
LIMIT 10;
*/

-- Get monthly sales report
/*
SELECT 
    DATE_FORMAT(o.created_at, '%Y-%m') as month,
    COUNT(DISTINCT o.id) as total_orders,
    SUM(o.total_amount) as total_revenue,
    COUNT(DISTINCT o.user_id) as unique_customers
FROM orders o
WHERE o.status = 'completed'
GROUP BY DATE_FORMAT(o.created_at, '%Y-%m')
ORDER BY month DESC;
*/

-- ============================================================================
-- BACKUP AND MAINTENANCE PROCEDURES
-- ============================================================================

-- Procedure to archive old orders
DELIMITER //
CREATE PROCEDURE ArchiveOldOrders(IN months_old INT)
BEGIN
    -- Create archive table if it doesn't exist
    CREATE TABLE IF NOT EXISTS orders_archive LIKE orders;
    CREATE TABLE IF NOT EXISTS order_items_archive LIKE order_items;
    
    -- Insert old orders into archive
    INSERT INTO orders_archive 
    SELECT * FROM orders 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL months_old MONTH)
    AND status IN ('completed', 'cancelled', 'refunded');
    
    -- Insert corresponding order items
    INSERT INTO order_items_archive
    SELECT oi.* FROM order_items oi
    JOIN orders o ON oi.order_id = o.id
    WHERE o.created_at < DATE_SUB(NOW(), INTERVAL months_old MONTH)
    AND o.status IN ('completed', 'cancelled', 'refunded');
    
    -- Delete from main tables
    DELETE oi FROM order_items oi
    JOIN orders o ON oi.order_id = o.id
    WHERE o.created_at < DATE_SUB(NOW(), INTERVAL months_old MONTH)
    AND o.status IN ('completed', 'cancelled', 'refunded');
    
    DELETE FROM orders 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL months_old MONTH)
    AND status IN ('completed', 'cancelled', 'refunded');
END //
DELIMITER ;

-- ============================================================================
-- SECURITY CONSIDERATIONS
-- ============================================================================

-- Create application user with limited privileges
CREATE USER 'storymatic_app'@'localhost' IDENTIFIED BY 'secure_password_here';
GRANT SELECT, INSERT, UPDATE, DELETE ON storymatic_db.* TO 'storymatic_app'@'localhost';
GRANT EXECUTE ON storymatic_db.* TO 'storymatic_app'@'localhost';

-- Create read-only user for reporting
CREATE USER 'storymatic_reports'@'localhost' IDENTIFIED BY 'reports_password_here';
GRANT SELECT ON storymatic_db.* TO 'storymatic_reports'@'localhost';

-- Revoke dangerous privileges from application user
REVOKE DROP, ALTER, CREATE, INDEX ON storymatic_db.* FROM 'storymatic_app'@'localhost';

FLUSH PRIVILEGES;

-- ============================================================================
-- DATABASE OPTIMIZATION
-- ============================================================================

-- Additional indexes for common queries
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_rating ON products(rating DESC);
CREATE INDEX idx_products_downloads ON products(download_count DESC);
CREATE INDEX idx_orders_date_status ON orders(created_at, status);
CREATE INDEX idx_analytics_event_date ON analytics(event_type, created_at);
CREATE INDEX idx_newsletter_status ON newsletter_subscribers(status);

-- Full-text search index for products
CREATE FULLTEXT INDEX idx_products_search ON products(name, short_description, long_description, tags);

-- ============================================================================
-- DATA VALIDATION CONSTRAINTS
-- ============================================================================

-- Add check constraints
ALTER TABLE products ADD CONSTRAINT chk_price_positive CHECK (price > 0);
ALTER TABLE products ADD CONSTRAINT chk_rating_range CHECK (rating >= 0 AND rating <= 5);
ALTER TABLE order_items ADD CONSTRAINT chk_quantity_positive CHECK (quantity > 0);
ALTER TABLE discount_codes ADD CONSTRAINT chk_discount_value CHECK (value > 0);

-- ============================================================================
-- FINAL NOTES
-- ============================================================================

/*
This database schema provides:

1. Complete e-commerce functionality
2. User management and authentication
3. Product catalog with digital downloads
4. Order processing and payment tracking
5. Shopping cart functionality
6. Product reviews and ratings
7. Newsletter management
8. Analytics and reporting
9. Contact form handling
10. Discount codes system
11. File download tracking
12. Performance optimized with indexes
13. Security considerations
14. Data archiving procedures
15. Maintenance procedures

To implement:
1. Set up MySQL/PostgreSQL database
2. Run this SQL script to create schema
3. Configure application database connections
4. Set up file storage for digital products
5. Implement payment gateway integration
6. Set up email system for notifications
7. Configure backup procedures
8. Set up monitoring and logging

Remember to:
- Use environment variables for sensitive data
- Implement proper password hashing
- Set up SSL certificates
- Configure CORS properly
- Implement rate limiting
- Set up proper error logging
- Use prepared statements to prevent SQL injection
- Regularly backup database
- Monitor performance and optimize queries
*/
