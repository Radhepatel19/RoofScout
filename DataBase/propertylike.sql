CREATE TABLE property_likes (
    like_id SERIAL PRIMARY KEY,
    property_id INT NOT NULL,
    user_id INT NOT NULL,
    liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(property_id, user_id)
);