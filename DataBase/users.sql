-- database Name :- RoofScout
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    
    -- Personal Details
    gender VARCHAR(20) CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    occupation VARCHAR(100),
    looking_for VARCHAR(50) CHECK (looking_for IN ('buy', 'rent', 'both')),
    about_me TEXT,
    
    -- Status
    is_owner BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    
    -- Profile
    profile_picture TEXT,
    city VARCHAR(100),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dummy Data for Users
INSERT INTO users (email, phone, full_name, gender, occupation, looking_for, about_me, is_owner, is_verified, city) VALUES
('john.doe@example.com', '1234567890', 'John Doe', 'male', 'Software Engineer', 'buy', 'Looking for a nice apartment in the city center.', FALSE, TRUE, 'New York'),
('jane.smith@example.com', '0987654321', 'Jane Smith', 'female', 'Doctor', 'rent', 'Need a quiet place near the hospital.', TRUE, TRUE, 'Los Angeles'),
('michael.johnson@example.com', '5551234567', 'Michael Johnson', 'male', 'Teacher', 'both', 'Searching for a family home with a backyard.', TRUE, FALSE, 'Chicago'),
('sarah.williams@example.com', '1112223333', 'Sarah Williams', 'female', 'Designer', 'rent', 'Looking for a well-lit studio.', FALSE, TRUE, 'San Francisco'),
('david.brown@example.com', '4445556666', 'David Brown', 'male', 'Business Owner', 'buy', 'Searching for a large commercial space.', TRUE, TRUE, 'Houston');