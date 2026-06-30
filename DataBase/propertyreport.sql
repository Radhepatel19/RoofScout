CREATE TABLE property_reports (
    report_id SERIAL PRIMARY KEY,
    property_id INT NOT NULL,
    user_id INT NOT NULL,
    
    -- Report details
    report_type VARCHAR(50) NOT NULL 
        CHECK (report_type IN (
            'fake_listing', 
            'already_sold_rented', 
            'wrong_info',
            'spam', 
            'inappropriate', 
            'duplicate', 
            'scam', 
            'other'
        )),
    description TEXT NOT NULL,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' 
        CHECK (status IN ('pending', 'reviewing', 'resolved', 'dismissed')),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    
);