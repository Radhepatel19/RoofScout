CREATE TABLE properties (
    property_id SERIAL PRIMARY KEY,
    owner_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    property_type VARCHAR(50) NOT NULL,
    listing_type VARCHAR(20) NOT NULL,
    state VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    full_address TEXT NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    area DECIMAL(8,2) NOT NULL,
    bedrooms INT,
    bathrooms INT,
    furnishing VARCHAR(30),
    furniture TEXT,
    floor_number INT,
    total_floors INT,
    property_age VARCHAR(50),
    facing VARCHAR(20),
    available_from DATE,
    is_available BOOLEAN DEFAULT TRUE,
    status VARCHAR(20) DEFAULT 'active',
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dummy Data for Properties (All over India focus)
INSERT INTO properties (owner_id, title, description, property_type, listing_type, state, city, full_address, price, area, bedrooms, bathrooms, furnishing, furniture, floor_number, total_floors, property_age, facing, available_from, is_available, status) VALUES
(2, 'Skyline Luxury Apartments', 'Premium 2BHK flat with a breathtaking view of the Arabian Sea, located in the prestigious locality of Bandra West, Mumbai. Modern design, excellent ventilation, and round-the-clock water supply.', 'Apartment', 'rent', 'Maharashtra', 'Mumbai', 'A-402, Skyline Heights, Bandra West, Mumbai, Maharashtra 400050', 145000.00, 1280.00, 2, 2, 'Fully Furnished', 'Sofa Set, Dining Table, Double Beds, Wardrobes, Smart TV, Modular Kitchen, Refrigerator, AC', 4, 12, 2, 'East', '2026-06-01', TRUE, 'active'),
(3, 'Green Valley Villa', 'An independent, highly spacious 3BHK luxurious villa in the serene greens of Indiranagar, Bangalore. Private garden, modular kitchen, individual parking garage, and state-of-the-art security.', 'Villa', 'sale', 'Karnataka', 'Bangalore', 'Villa No. 12, Green Valley Enclave, Indiranagar, Bangalore, Karnataka 560038', 32000000.00, 2980.00, 3, 3, 'Semi-Furnished', 'Modular Kitchen Cabinets, Built-in Wardrobes, Lighting Fixtures, Geysers', 1, 2, 3, 'West', '2026-07-15', TRUE, 'active'),
(2, 'City Center Apartment', 'Cozy and compact 1BHK apartment, perfect for young professionals. Quiet neighborhood in Vasant Kunj, Delhi, with easy access to markets, metro, and schools.', 'Apartment', 'rent', 'Delhi', 'Delhi', 'C-105, Althan Residency, Vasant Kunj, Delhi 110070', 28000.00, 850.00, 1, 1, 'Fully Furnished', 'Sofa, Bed, Wardrobe, AC, Kitchen Utensils', 1, 5, 4, 'South', '2026-05-20', TRUE, 'active'),
(2, 'Lakeview Residency', 'Extravagant 4BHK penthouse near Koregaon Park, Pune. Premium Italian marble flooring, expansive terraces, dedicated home theater room, and automated domestic features.', 'Penthouse', 'sale', 'Maharashtra', 'Pune', 'Penthouse A, Lakeview Tower, Koregaon Park, Pune, Maharashtra 411001', 29500000.00, 3450.00, 4, 4, 'Fully Furnished', 'Luxury leather sofas, high-end wooden dining set, automated smart lighting, fully integrated home automation', 10, 10, 1, 'North', '2026-06-15', TRUE, 'active'),
(3, 'Shree Balaji Heights', 'Spacious 2BHK flat with balconies overlooking the community park. Strategically located near Bodakdev, Ahmedabad. 24x7 power backup and security guard.', 'Apartment', 'rent', 'Gujarat', 'Ahmedabad', 'B-702, Shree Balaji Heights, Bodakdev, Ahmedabad, Gujarat 380054', 32000.00, 1150.00, 2, 2, 'Semi-Furnished', 'Modular Kitchen, Wardrobes, Chimney', 7, 10, 3, 'East', '2026-06-05', TRUE, 'active'),
(2, 'Royal Palace Villa', 'Ultimate 5BHK ultra-luxury mansion with a private swimming pool, high ceilings, large lawn, servants quarters, and private home office located on Dumas Road, Surat.', 'Villa', 'sale', 'Gujarat', 'Surat', 'Mansion 1, Royal Palace Enclave, Dumas Road, Surat, Gujarat 395007', 45000000.00, 5200.00, 5, 6, 'Fully Furnished', 'Premium imported sofas, dining table for 10, complete home office suite, designer king-size beds, pool-side sun loungers', 1, 2, 1, 'West', '2026-08-01', TRUE, 'active'),
(3, 'Rajhans Elita Premium Flat', 'Luxurious 3BHK high-rise apartment in Gachibowli, Hyderabad, with panoramic views. Features private elevators, swimming pool access, and double-height lobbies.', 'Apartment', 'rent', 'Telangana', 'Hyderabad', 'D-903, Rajhans Elita, Gachibowli, Hyderabad, Telangana 500032', 75000.00, 1850.00, 3, 3, 'Fully Furnished', 'Premium wooden beds, Italian designer sofa, 6-seater dining table, dual-door refrigerator, washing machine, 3 ACs', 9, 15, 3, 'North', '2026-06-01', TRUE, 'active'),
(4, 'Sangini Solitaire', 'Beautifully designed 2BHK apartment in Adyar, Chennai. Gated security, children play area, solar power for common areas, and high-speed elevator.', 'Apartment', 'sale', 'Tamil Nadu', 'Chennai', 'A-304, Sangini Solitaire, Adyar, Chennai, Tamil Nadu 600020', 11000000.00, 1200.00, 2, 2, 'Unfurnished', NULL, 3, 7, 6, 'East', '2026-05-25', TRUE, 'active');