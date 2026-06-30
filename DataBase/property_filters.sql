CREATE TABLE property_filters (
    id SERIAL PRIMARY KEY,

    -- User & Location
    user_id INT NOT NULL,
    city VARCHAR(100) NOT NULL,

    -- Budget
    min_budget NUMERIC(12,2),
    max_budget NUMERIC(12,2),

    -- Property Details
    bedrooms INT,
    bathrooms INT,
    property_type VARCHAR(50),
    furnishing_status VARCHAR(50),

    -- Posting Details
    posted_by VARCHAR(50),       -- Owner, Agent, Builder
    available_for VARCHAR(50),   -- Rent / Sale

    -- Area (UI based like 800+)
    min_area_sqft INT,           -- 800 means 800+

    -- Availability
    available_from DATE,

    -- Amenities
    amenities TEXT[],

    -- Meta
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
