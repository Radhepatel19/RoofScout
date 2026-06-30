CREATE TABLE owner_documents (
    document_id SERIAL PRIMARY KEY,
    owner_id INT UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    aadhar_image_front TEXT NOT NULL,
    aadhar_image_back TEXT,
    pan_image TEXT NOT NULL,
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verified_at TIMESTAMP,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
