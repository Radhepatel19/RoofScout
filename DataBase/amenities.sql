CREATE TABLE amenities (
    property_id INT REFERENCES properties(property_id) ON DELETE CASCADE,
    amenity_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (property_id, amenity_name)
);

-- Dummy Data for Amenities
INSERT INTO amenities (property_id, amenity_name) VALUES
(1, 'Swimming Pool'), (1, 'Gym'), (1, '24x7 Security'), (1, 'Parking'), (1, 'Garden'),
(2, 'Garden'), (2, 'Parking'), (2, 'Power Backup'), (2, 'Kids Play Area'),
(3, 'Gym'), (3, 'Lift'), (3, 'WiFi'), (3, 'Maintenance'),
(4, 'Club House'), (4, 'Kids Play Area'), (4, 'Lift'), (4, 'Swimming Pool'), (4, 'Gym'), (4, 'Garden'),
(5, 'Parking'), (5, 'Power Backup'), (5, '24x7 Security'),
(6, 'Swimming Pool'), (6, 'Gym'), (6, 'Garden'), (6, 'Club House'), (6, 'Kids Play Area'), (6, 'WiFi'), (6, 'Maintenance'),
(7, 'Lift'), (7, 'Gym'), (7, 'Parking'), (7, '24x7 Security'), (7, 'Power Backup'),
(8, 'Lift'), (8, 'Parking'), (8, 'Kids Play Area');