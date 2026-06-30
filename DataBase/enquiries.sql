CREATE TABLE enquiries (
    enquiry_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id) ON DELETE CASCADE,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    owner_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    enquiry_status VARCHAR(20) DEFAULT 'unread',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);