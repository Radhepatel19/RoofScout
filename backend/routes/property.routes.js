const express = require("express");
const router = express.Router();
const db = require('../config/database');
const auth = require("../middleware/owner.doc.auth"); // JWT middleware

// ✅ UPDATE PROPERTY DETAILS
router.put("/:id", auth, async (req, res) => {
  const client = await db.pool.connect();
  try {
    const { id } = req.params;
    const owner_id = req.user.user_id;
    const {
      title, description, property_type, listing_type,
      state, city, full_address, price, area,
      bedrooms, bathrooms, furnishing, furniture,
      floor_number, total_floors, property_age, facing,
      available_from, is_available,
      images, amenities
    } = req.body;

    await client.query('BEGIN');

    // 1. Verify Ownership
    const checkOwner = await client.query(
      "SELECT * FROM properties WHERE property_id = $1 AND owner_id = $2",
      [id, owner_id]
    );

    if (checkOwner.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(403).json({ success: false, message: "Unauthorized or Property not found" });
    }

    // 2. Update Property Fields
    let furnitureArray = furniture;
    if (typeof furniture === 'string') {
      furnitureArray = furniture.split(',').map(item => item.trim()).filter(i => i.length > 0);
    }

    // Parse available_from date safely with relative UI chip offsets
    let parsedAvailableFrom = null;
    if (available_from) {
      const lowerVal = available_from.toString().toLowerCase().trim();
      const today = new Date();
      
      if (lowerVal === 'immediately' || lowerVal === 'anytime') {
        parsedAvailableFrom = today.toISOString().split('T')[0];
      } else if (lowerVal === 'within 5 days') {
        today.setDate(today.getDate() + 5);
        parsedAvailableFrom = today.toISOString().split('T')[0];
      } else if (lowerVal === 'next week') {
        today.setDate(today.getDate() + 7);
        parsedAvailableFrom = today.toISOString().split('T')[0];
      } else if (lowerVal === 'next month') {
        today.setMonth(today.getMonth() + 1);
        parsedAvailableFrom = today.toISOString().split('T')[0];
      } else if (!isNaN(Date.parse(available_from))) {
        parsedAvailableFrom = new Date(available_from).toISOString().split('T')[0];
      } else {
        parsedAvailableFrom = today.toISOString().split('T')[0];
      }
    }

    const updateQuery = `
      UPDATE properties SET
        title = $1, description = $2, property_type = $3, listing_type = $4,
        state = $5, city = $6, full_address = $7, price = $8, area = $9,
        bedrooms = $10, bathrooms = $11, furnishing = $12, furniture = $13,
        floor_number = $14, total_floors = $15, property_age = $16, facing = $17,
        available_from = $18, is_available = $19
      WHERE property_id = $20 AND owner_id = $21
      RETURNING *
    `;

    const result = await client.query(updateQuery, [
      title, description, property_type, listing_type,
      state, city, full_address, price, area,
      bedrooms, bathrooms, furnishing, furnitureArray,
      floor_number, total_floors, property_age, facing,
      parsedAvailableFrom, is_available ?? true,
      id, owner_id
    ]);

    // 3. Update Images (Replace All)
    if (images && Array.isArray(images)) {
      await client.query("DELETE FROM property_images WHERE property_id = $1", [id]);
      let currentOrder = 0;
      for (let imgUrl of images) {
        currentOrder += 1;
        await client.query(
          "INSERT INTO property_images (property_id, image_url, image_order) VALUES ($1, $2, $3)",
          [id, imgUrl, currentOrder]
        );
      }
    }

    // 4. Update Amenities (Replace All)
    if (amenities && Array.isArray(amenities)) {
      await client.query("DELETE FROM amenities WHERE property_id = $1", [id]);
      for (const amenity_name of amenities) {
        await client.query(
          "INSERT INTO amenities (property_id, amenity_name) VALUES ($1, $2)",
          [id, amenity_name]
        );
      }
    }

    await client.query('COMMIT');
    res.json({ success: true, message: "Property updated successfully", data: result.rows[0] });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error("❌ Update FAILED", error);
    res.status(500).json({ success: false, message: "Failed to update property", error: error.message });
  } finally {
    client.release();
  }
});

router.post("/", auth, async (req, res) => {
  console.log("🚀 [POST] /api/properties request received");
  console.log("📝 Request Body:", JSON.stringify(req.body, null, 2));

  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    const owner_id = req.user.user_id; // 🔐 from token
    const {
      // Property Details
      title,
      description,
      property_type,
      listing_type,
      state,
      city,
      full_address,
      price,
      area,
      bedrooms,
      bathrooms,
      furnishing,
      furniture,
      floor_number,
      total_floors,
      property_age,
      facing,
      available_from,
      is_available,

      // Related Data
      images,          // Array of strings (urls)
      amenities,       // Array of strings (names)
      ownerDocuments   // Object: { aadhar_image_front, aadhar_image_back, pan_image }
    } = req.body;

    // Data Transformation
    // 1. Convert furniture CSV string to Array for PostgreSQL (if it's a string)
    let furnitureArray = furniture;
    if (typeof furniture === 'string') {
      furnitureArray = furniture.split(',').map(item => item.trim()).filter(i => i.length > 0);
    }

    // Parse available_from date safely with relative UI chip offsets
    let parsedAvailableFrom = null;
    if (available_from) {
      const lowerVal = available_from.toString().toLowerCase().trim();
      const today = new Date();
      
      if (lowerVal === 'immediately' || lowerVal === 'anytime') {
        parsedAvailableFrom = today.toISOString().split('T')[0];
      } else if (lowerVal === 'within 5 days') {
        today.setDate(today.getDate() + 5);
        parsedAvailableFrom = today.toISOString().split('T')[0];
      } else if (lowerVal === 'next week') {
        today.setDate(today.getDate() + 7);
        parsedAvailableFrom = today.toISOString().split('T')[0];
      } else if (lowerVal === 'next month') {
        today.setMonth(today.getMonth() + 1);
        parsedAvailableFrom = today.toISOString().split('T')[0];
      } else if (!isNaN(Date.parse(available_from))) {
        parsedAvailableFrom = new Date(available_from).toISOString().split('T')[0];
      } else {
        parsedAvailableFrom = today.toISOString().split('T')[0];
      }
    }

    // 1. Insert Property
    console.log("🏗️ Inserting Property with values:");
    const insertValues = [
      owner_id,
      title,
      description,
      property_type,
      listing_type,
      state,
      city,
      full_address,
      price,
      area,
      bedrooms,
      bathrooms,
      furnishing,
      furnitureArray,
      floor_number,
      total_floors,
      property_age,
      facing,
      parsedAvailableFrom,
      is_available ?? true
    ];
    console.log(insertValues);

    const propertyResult = await client.query(
      `INSERT INTO properties (
        owner_id, title, description, property_type, listing_type,
        state, city, full_address, price, area,
        bedrooms, bathrooms, furnishing, furniture,
        floor_number, total_floors, property_age, facing,
        available_from, is_available
      ) VALUES (
        $1,$2,$3,$4,$5,
        $6,$7,$8,$9,$10,
        $11,$12,$13,$14,
        $15,$16,$17,$18,
        $19,$20
      ) RETURNING *`,
      [
        owner_id,
        title,
        description,
        property_type,
        listing_type,
        state,
        city,
        full_address,
        price,
        area,
        bedrooms,
        bathrooms,
        furnishing,
        furnitureArray,
        floor_number,
        total_floors,
        property_age,
        facing,
        parsedAvailableFrom,
        is_available ?? true
      ]
    );

    const newProperty = propertyResult.rows[0];
    const property_id = newProperty.property_id;

    // 2. Insert Images (if any)
    if (images && Array.isArray(images) && images.length > 0) {
      let currentOrder = 0;
      for (let imgUrl of images) {
        currentOrder += 1;
        await client.query(
          `INSERT INTO property_images (property_id, image_url, image_order)
           VALUES ($1, $2, $3)`,
          [property_id, imgUrl, currentOrder]
        );
      }
    }

    // 3. Insert Amenities (if any)
    if (amenities && Array.isArray(amenities) && amenities.length > 0) {
      for (const amenity_name of amenities) {
        // Simple insert, ignoring duplicates if any (though UI should prevent duplicates)
        // Or specific logic: check if exists? For new property, it shouldn't exist.
        await client.query(
          `INSERT INTO amenities (property_id, amenity_name)
           VALUES ($1, $2)
           ON CONFLICT DO NOTHING`, // Safety
          [property_id, amenity_name]
        );
      }
    }

    // 4. Upsert Owner Documents (if provided)
    if (ownerDocuments) {
      const { aadhar_image_front, aadhar_image_back, pan_image } = ownerDocuments;

      // Only proceed if minimum requirements are met (UI should enforce this, but backend safety)
      if (aadhar_image_front && pan_image) {
        await client.query(
          `INSERT INTO owner_documents
           (owner_id, aadhar_image_front, aadhar_image_back, pan_image)
           VALUES ($1, $2, $3, $4)
           ON CONFLICT (owner_id)
           DO UPDATE SET
             aadhar_image_front = EXCLUDED.aadhar_image_front,
             aadhar_image_back  = EXCLUDED.aadhar_image_back,
             pan_image          = EXCLUDED.pan_image,
             uploaded_at        = CURRENT_TIMESTAMP`,
          [
            owner_id,
            aadhar_image_front,
            aadhar_image_back || null,
            pan_image
          ]
        );
      }
    }

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      data: newProperty,
      message: "Property created successfully with details"
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error("❌ Transaction FAILED & ROLLBACK executed");
    console.error("Error Details:", error);
    res.status(500).json({
      success: false,
      message: "Failed to create property",
      error: error.message
    });
  } finally {
    client.release();
  }
});




// get all Property form owner_id
router.get('/owner', auth, async (req, res) => {
  try {
    if (!req.user || !req.user.user_id) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const owner_id = req.user.user_id;

    const propertiesResult = await db.query(
      'SELECT * FROM properties WHERE owner_id = $1 ORDER BY property_id DESC',
      [owner_id]
    );

    const properties = propertiesResult.rows;
    if (!properties.length) {
      return res.json({ success: true, count: 0, data: [] });
    }

    const propertyIds = properties.map(p => p.property_id);

    const imagesResult = await db.query(
      `SELECT property_id, image_url FROM property_images
       WHERE property_id = ANY($1::int[])`,
      [propertyIds]
    );

    const amenitiesResult = await db.query(
      `SELECT property_id, amenity_name FROM amenities
       WHERE property_id = ANY($1::int[])`,
      [propertyIds]
    );

    const imagesMap = {};
    imagesResult.rows.forEach(i => {
      imagesMap[i.property_id] = imagesMap[i.property_id] || [];
      imagesMap[i.property_id].push(i.image_url);
    });

    const amenitiesMap = {};
    amenitiesResult.rows.forEach(a => {
      amenitiesMap[a.property_id] = amenitiesMap[a.property_id] || [];
      amenitiesMap[a.property_id].push(a.amenity_name);
    });

    const data = properties.map(p => ({
      ...p,
      images: imagesMap[p.property_id] || [],
      amenities: amenitiesMap[p.property_id] || []
    }));

    res.json({ success: true, count: data.length, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// ✅ UPDATE PROPERTY STATUS (Approve)
router.put("/:id/status", auth, async (req, res) => {
  try {
    const { id } = req.params;
    const { is_available } = req.body; // Expecting { is_available: true }
    const owner_id = req.user.user_id;

    // Verify ownership
    const checkOwner = await db.query(
      "SELECT * FROM properties WHERE property_id = $1 AND owner_id = $2",
      [id, owner_id]
    );

    if (checkOwner.rows.length === 0) {
      return res.status(403).json({ success: false, message: "Unauthorized or Property not found" });
    }

    const result = await db.query(
      "UPDATE properties SET is_available = $1 WHERE property_id = $2 RETURNING *",
      [is_available, id]
    );

    res.json({ success: true, message: "Property status updated", data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server Error" });
  }
});

// ✅ DELETE PROPERTY
router.delete("/:id", auth, async (req, res) => {
  try {
    const { id } = req.params;
    const owner_id = req.user.user_id;

    // Verify ownership
    const checkOwner = await db.query(
      "SELECT * FROM properties WHERE property_id = $1 AND owner_id = $2",
      [id, owner_id]
    );

    if (checkOwner.rows.length === 0) {
      return res.status(403).json({ success: false, message: "Unauthorized or Property not found" });
    }

    await db.query("DELETE FROM properties WHERE property_id = $1", [id]);

    res.json({ success: true, message: "Property deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server Error" });
  }
});

// ✅ GET ALL PROPERTIES (with filters)
router.get("/", async (req, res) => {
  try {
    const { city, property_type, listing_type, furnishing, bedrooms } = req.query;
    let query = `
      SELECT p.*, u.full_name as owner_name, u.phone as owner_phone, u.profile_picture as owner_pic
      FROM properties p
      LEFT JOIN users u ON p.owner_id = u.user_id
      WHERE p.is_available = TRUE AND p.status = 'active'
    `;
    const params = [];
    let paramIndex = 1;

    if (city) {
      query += ` AND p.city ILIKE $${paramIndex}`;
      params.push(`%${city}%`);
      paramIndex++;
    }
    if (property_type) {
      query += ` AND p.property_type ILIKE $${paramIndex}`;
      params.push(property_type);
      paramIndex++;
    }
    if (listing_type) {
      query += ` AND p.listing_type ILIKE $${paramIndex}`;
      params.push(listing_type);
      paramIndex++;
    }
    if (furnishing) {
      query += ` AND p.furnishing ILIKE $${paramIndex}`;
      params.push(furnishing);
      paramIndex++;
    }
    if (bedrooms) {
      query += ` AND p.bedrooms = $${paramIndex}`;
      params.push(parseInt(bedrooms));
      paramIndex++;
    }

    query += " ORDER BY p.property_id DESC";

    const result = await db.query(query, params);
    const properties = result.rows;

    if (!properties.length) {
      return res.json({ success: true, count: 0, data: [] });
    }

    const propertyIds = properties.map(p => p.property_id);

    // Fetch images
    const imagesResult = await db.query(
      `SELECT property_id, image_url FROM property_images WHERE property_id = ANY($1::int[]) ORDER BY image_order ASC`,
      [propertyIds]
    );

    // Fetch amenities
    const amenitiesResult = await db.query(
      `SELECT property_id, amenity_name FROM amenities WHERE property_id = ANY($1::int[])`,
      [propertyIds]
    );

    // Fetch average ratings from property_reviews
    const ratingsResult = await db.query(
      `SELECT property_id, ROUND(AVG(rating), 1) as avg_rating, COUNT(*) as review_count 
       FROM property_reviews 
       WHERE property_id = ANY($1::int[]) 
       GROUP BY property_id`,
      [propertyIds]
    );

    const imagesMap = {};
    imagesResult.rows.forEach(i => {
      imagesMap[i.property_id] = imagesMap[i.property_id] || [];
      imagesMap[i.property_id].push(i.image_url);
    });

    const amenitiesMap = {};
    amenitiesResult.rows.forEach(a => {
      amenitiesMap[a.property_id] = amenitiesMap[a.property_id] || [];
      amenitiesMap[a.property_id].push(a.amenity_name);
    });

    const ratingsMap = {};
    ratingsResult.rows.forEach(r => {
      ratingsMap[r.property_id] = {
        rating: parseFloat(r.avg_rating),
        count: parseInt(r.review_count)
      };
    });

    const data = properties.map(p => ({
      ...p,
      images: imagesMap[p.property_id] || [],
      amenities: amenitiesMap[p.property_id] || [],
      rating: ratingsMap[p.property_id] ? ratingsMap[p.property_id].rating : 4.5, // Default/fallback
      review_count: ratingsMap[p.property_id] ? ratingsMap[p.property_id].count : 0
    }));

    res.json({ success: true, count: data.length, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server Error", error: err.message });
  }
});

// ✅ GET PROPERTY BY ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const propertyResult = await db.query(
      `SELECT p.*, u.full_name as owner_name, u.phone as owner_phone, u.profile_picture as owner_pic, u.email as owner_email
       FROM properties p
       LEFT JOIN users u ON p.owner_id = u.user_id
       WHERE p.property_id = $1`,
      [id]
    );

    if (propertyResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Property not found" });
    }

    const property = propertyResult.rows[0];

    // Increment view count
    await db.query("UPDATE properties SET view_count = view_count + 1 WHERE property_id = $1", [id]);

    // Fetch images
    const imagesResult = await db.query(
      "SELECT image_url FROM property_images WHERE property_id = $1 ORDER BY image_order ASC",
      [id]
    );

    // Fetch amenities
    const amenitiesResult = await db.query(
      "SELECT amenity_name FROM amenities WHERE property_id = $1",
      [id]
    );

    // Fetch reviews
    const reviewsResult = await db.query(
      `SELECT r.*, u.full_name, u.profile_picture 
       FROM property_reviews r 
       JOIN users u ON r.user_id = u.user_id 
       WHERE r.property_id = $1 
       ORDER BY r.created_at DESC`,
      [id]
    );

    // Calculate rating
    let avgRating = 4.5;
    if (reviewsResult.rows.length > 0) {
      const sum = reviewsResult.rows.reduce((acc, r) => acc + r.rating, 0);
      avgRating = parseFloat((sum / reviewsResult.rows.length).toFixed(1));
    }

    const data = {
      ...property,
      images: imagesResult.rows.map(i => i.image_url),
      amenities: amenitiesResult.rows.map(a => a.amenity_name),
      reviews: reviewsResult.rows,
      rating: avgRating,
      review_count: reviewsResult.rows.length
    };

    res.json({ success: true, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server Error", error: err.message });
  }
});

// ✅ GET REVIEWS FOR A PROPERTY
router.get("/:id/reviews", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query(
      `SELECT r.*, u.full_name, u.profile_picture 
       FROM property_reviews r 
       JOIN users u ON r.user_id = u.user_id 
       WHERE r.property_id = $1 
       ORDER BY r.created_at DESC`,
      [id]
    );
    res.json({ success: true, count: result.rows.length, data: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server Error", error: err.message });
  }
});

// ✅ POST REVIEW FOR A PROPERTY
router.post("/:id/reviews", async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, review_text, user_id } = req.body;
    const jwt = require("jsonwebtoken");

    // Optional auth extraction
    let finalUserId = user_id || 1; // Default fallback to user 1 for demo
    const authHeader = req.headers.authorization;
    if (authHeader) {
      try {
        const token = authHeader.split(" ")[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        finalUserId = decoded.user_id;
      } catch (e) {
        // Continue with default/body user_id if token is invalid
      }
    }

    const result = await db.query(
      `INSERT INTO property_reviews (property_id, user_id, rating, review_text)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [id, finalUserId, rating, review_text]
    );

    res.status(201).json({ success: true, message: "Review posted successfully", data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server Error", error: err.message });
  }
});

module.exports = router;

