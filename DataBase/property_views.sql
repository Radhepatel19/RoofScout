CREATE TABLE property_views (
    property_id INT REFERENCES properties(property_id) ON DELETE CASCADE,
    user_id INT REFERENCES users(user_id),
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);