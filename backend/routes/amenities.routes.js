const express = require("express");
const router = express.Router();
const db = require('../config/database');

// POST - Add an amenity to a property
router.post("/", async (req, res) => {
  try {
    const { property_id, amenity_name } = req.body;

    // Validate required fields
    if (!property_id || !amenity_name) {
      return res.status(400).json({
        success: false,
        message: "property_id and amenity_name are required"
      });
    }

    // Check if amenity already exists for this property
    const existingAmenity = await db.query(
      "SELECT * FROM amenities WHERE property_id = $1 AND amenity_name = $2",
      [property_id, amenity_name]
    );

    if (existingAmenity.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: "Amenity already exists for this property",
        data: existingAmenity.rows[0]
      });
    }

    const result = await db.query(
      `INSERT INTO amenities (property_id, amenity_name)
       VALUES ($1, $2)
       RETURNING *`,
      [property_id, amenity_name]
    );

    res.status(201).json({
      success: true,
      message: "Amenity added successfully",
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to add amenity",
      error: err.message
    });
  }
});

// POST - Add multiple amenities to a property
router.post("/bulk", async (req, res) => {
  try {
    const { property_id, amenities } = req.body;

    // Validate required fields
    if (!property_id || !amenities || !Array.isArray(amenities)) {
      return res.status(400).json({
        success: false,
        message: "property_id and amenities (array) are required"
      });
    }

    if (amenities.length === 0) {
      return res.status(400).json({
        success: false,
        message: "amenities array cannot be empty"
      });
    }

    const insertedAmenities = [];
    const errors = [];

    for (const amenity_name of amenities) {
      try {
        // Check if amenity already exists
        const existing = await db.query(
          "SELECT * FROM amenities WHERE property_id = $1 AND amenity_name = $2",
          [property_id, amenity_name]
        );

        if (existing.rows.length === 0) {
          const result = await db.query(
            `INSERT INTO amenities (property_id, amenity_name)
             VALUES ($1, $2)
             RETURNING *`,
            [property_id, amenity_name]
          );
          insertedAmenities.push(result.rows[0]);
        } else {
          insertedAmenities.push(existing.rows[0]);
        }
      } catch (err) {
        errors.push({ amenity_name, error: err.message });
      }
    }

    res.status(201).json({
      success: true,
      message: `Added ${insertedAmenities.length} amenity/amenities`,
      count: insertedAmenities.length,
      data: insertedAmenities,
      errors: errors.length > 0 ? errors : undefined
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to add amenities",
      error: err.message
    });
  }
});

// GET - Get all amenities for a specific property
router.get("/property/:property_id", async (req, res) => {
  try {
    const { property_id } = req.params;

    const result = await db.query(
      `SELECT * FROM amenities 
       WHERE property_id = $1 
       ORDER BY amenity_name ASC`,
      [property_id]
    );

    res.json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch property amenities",
      error: err.message
    });
  }
});

// GET - Get all properties with a specific amenity
router.get("/amenity/:amenity_name", async (req, res) => {
  try {
    const { amenity_name } = req.params;

    const result = await db.query(
      `SELECT a.*, p.* 
       FROM amenities a
       INNER JOIN properties p ON a.property_id = p.property_id
       WHERE a.amenity_name = $1 
       ORDER BY p.created_at DESC`,
      [amenity_name]
    );

    res.json({
      success: true,
      count: result.rows.length,
      amenity_name: amenity_name,
      data: result.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch properties with amenity",
      error: err.message
    });
  }
});

// GET - Get all distinct amenity names
router.get("/list", async (req, res) => {
  try {
    const result = await db.query(
      `SELECT DISTINCT amenity_name, COUNT(*) as property_count
       FROM amenities 
       GROUP BY amenity_name 
       ORDER BY property_count DESC, amenity_name ASC`
    );

    res.json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch amenity list",
      error: err.message
    });
  }
});

// DELETE - Remove an amenity from a property
router.delete("/:property_id/:amenity_name", async (req, res) => {
  try {
    const { property_id, amenity_name } = req.params;

    const result = await db.query(
      `DELETE FROM amenities 
       WHERE property_id = $1 AND amenity_name = $2
       RETURNING *`,
      [property_id, amenity_name]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Amenity not found for this property"
      });
    }

    res.json({
      success: true,
      message: "Amenity removed successfully",
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to remove amenity",
      error: err.message
    });
  }
});

// DELETE - Remove all amenities from a property
router.delete("/property/:property_id", async (req, res) => {
  try {
    const { property_id } = req.params;

    const result = await db.query(
      `DELETE FROM amenities 
       WHERE property_id = $1
       RETURNING *`,
      [property_id]
    );

    res.json({
      success: true,
      message: `Removed ${result.rows.length} amenity/amenities from property`,
      count: result.rows.length,
      data: result.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to remove amenities",
      error: err.message
    });
  }
});

// GET - Get all amenities (optional - for admin purposes)
router.get("/", async (req, res) => {
  try {
    const result = await db.query(
      "SELECT * FROM amenities ORDER BY property_id ASC, amenity_name ASC"
    );

    res.json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch amenities",
      error: err.message
    });
  }
});

module.exports = router;
