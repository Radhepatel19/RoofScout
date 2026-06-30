CREATE TABLE saved_properties (
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    property_id INT REFERENCES properties(property_id) ON DELETE CASCADE,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, property_id)
);