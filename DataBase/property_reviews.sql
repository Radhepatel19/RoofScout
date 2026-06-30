CREATE TABLE property_reviews (
    review_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id) ON DELETE CASCADE,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
