CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    related_entity_type VARCHAR(50),
    related_entity_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    is_seen BOOLEAN DEFAULT FALSE,
    data JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);