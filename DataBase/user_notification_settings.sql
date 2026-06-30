CREATE TABLE user_notification_settings (
    user_id INT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    email_property_alerts BOOLEAN DEFAULT TRUE,
    email_new_messages BOOLEAN DEFAULT TRUE,
    push_property_alerts BOOLEAN DEFAULT TRUE,
    push_new_messages BOOLEAN DEFAULT TRUE,
    quiet_hours_start TIME DEFAULT '22:00',
    quiet_hours_end TIME DEFAULT '08:00',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);