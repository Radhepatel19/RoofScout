CREATE TABLE user_documents (
    document_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    aadhar_image TEXT NOT NULL,
    pan_image TEXT,
    verification_status VARCHAR(20) DEFAULT 'pending',
    verified_at TIMESTAMP,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);