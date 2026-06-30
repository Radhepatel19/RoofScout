const express = require("express");
const router = express.Router();
const db = require('../config/database');
const { upload, uploadToCloudinary } = require("../middleware/cloudinaryUpload");

// POST - Add multiple images for a property
// Use upload.array('images') to handle multiple files from the field 'images'
router.post("/batch", upload.array('images'), async (req, res) => {
  try {
    const { property_id } = req.body;
    const files = req.files;

    if (!property_id || !files || files.length === 0) {
      return res.status(400).json({
        success: false,
        message: "property_id and images are required"
      });
    }

    // Get current max image_order for this property
    const maxOrderResult = await db.query(
      "SELECT MAX(image_order) as max_order FROM property_images WHERE property_id = $1",
      [property_id]
    );
    let currentOrder = maxOrderResult.rows[0].max_order || 0;

    const insertedImages = [];

    // Upload each file to Cloudinary and then save to DB
    for (let file of files) {
      currentOrder += 1;

      // Upload to Cloudinary
      const cloudinaryResult = await uploadToCloudinary(file.buffer, 'property_images');
      const imageUrl = cloudinaryResult.secure_url;

      const result = await db.query(
        `INSERT INTO property_images (property_id, image_url, image_order)
         VALUES ($1, $2, $3)
         RETURNING *`,
        [property_id, imageUrl, currentOrder]
      );
      insertedImages.push(result.rows[0]);
    }

    res.status(201).json({
      success: true,
      count: insertedImages.length,
      data: insertedImages
    });

  } catch (err) {
    console.error("Property images upload error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to upload property images",
      error: err.message
    });
  }
});

// GET - Get all images for a specific property
router.get("/property/:property_id", async (req, res) => {
  try {
    const { property_id } = req.params;

    const result = await db.query(
      `SELECT * FROM property_images 
       WHERE property_id = $1 
       ORDER BY image_order ASC, uploaded_at ASC`,
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
      message: "Failed to fetch property images",
      error: err.message
    });
  }
});

// GET - Get a specific image by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      "SELECT * FROM property_images WHERE image_id = $1",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Image not found"
      });
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch image",
      error: err.message
    });
  }
});

module.exports = router;
