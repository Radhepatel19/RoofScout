CREATE TABLE property_images (
    image_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    image_order INT DEFAULT 0,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dummy Data for Property Images
INSERT INTO property_images (property_id, image_url, image_order) VALUES
(1, 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&auto=format&fit=crop', 1),
(1, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&auto=format&fit=crop', 2),
(2, 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&auto=format&fit=crop', 1),
(2, 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&auto=format&fit=crop', 2),
(3, 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&auto=format&fit=crop', 1),
(3, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&auto=format&fit=crop', 2),
(4, 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&auto=format&fit=crop', 1),
(4, 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&auto=format&fit=crop', 2),
(4, 'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800&auto=format&fit=crop', 3),
(5, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&auto=format&fit=crop', 1),
(5, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&auto=format&fit=crop', 2),
(6, 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=800&auto=format&fit=crop', 1),
(6, 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&auto=format&fit=crop', 2),
(7, 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&auto=format&fit=crop', 1),
(7, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&auto=format&fit=crop', 2),
(8, 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&auto=format&fit=crop', 1),
(8, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&auto=format&fit=crop', 2);