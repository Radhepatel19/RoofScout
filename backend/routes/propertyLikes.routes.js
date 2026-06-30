const express = require("express");
const router = express.Router();
const db = require('../config/database');

// POST - Like a property (create a like)
router.post("/", async (req, res) => {
  try {
    const { property_id, user_id } = req.body;

    // Validate required fields
    if (!property_id || !user_id) {
      return res.status(400).json({
        success: false,
        message: "property_id and user_id are required"
      });
    }

    // Check if like already exists
    const existingLike = await db.query(
      "SELECT * FROM property_likes WHERE property_id = $1 AND user_id = $2",
      [property_id, user_id]
    );

    if (existingLike.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: "Property already liked by this user",
        data: existingLike.rows[0]
      });
    }

    const result = await db.query(
      `INSERT INTO property_likes (property_id, user_id)
       VALUES ($1, $2)
       RETURNING *`,
      [property_id, user_id]
    );

    res.status(201).json({
      success: true,
      message: "Property liked successfully",
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to like property",
      error: err.message
    });
  }
});

// GET - Get all likes for a specific property
router.get("/property/:property_id", async (req, res) => {
  try {
    const { property_id } = req.params;

    const result = await db.query(
      `SELECT * FROM property_likes 
       WHERE property_id = $1 
       ORDER BY liked_at DESC`,
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
      message: "Failed to fetch property likes",
      error: err.message
    });
  }
});

// GET - Get all properties liked by a specific user
router.get("/user/:user_id", async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await db.query(
      `SELECT * FROM property_likes 
       WHERE user_id = $1 
       ORDER BY liked_at DESC`,
      [user_id]
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
      message: "Failed to fetch user likes",
      error: err.message
    });
  }
});

// GET - Check if a user liked a specific property
router.get("/check/:property_id/:user_id", async (req, res) => {
  try {
    const { property_id, user_id } = req.params;

    const result = await db.query(
      `SELECT * FROM property_likes 
       WHERE property_id = $1 AND user_id = $2`,
      [property_id, user_id]
    );

    res.json({
      success: true,
      is_liked: result.rows.length > 0,
      data: result.rows.length > 0 ? result.rows[0] : null
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to check like status",
      error: err.message
    });
  }
});

// DELETE - Unlike a property (remove a like)
router.delete("/:property_id/:user_id", async (req, res) => {
  try {
    const { property_id, user_id } = req.params;

    const result = await db.query(
      `DELETE FROM property_likes 
       WHERE property_id = $1 AND user_id = $2
       RETURNING *`,
      [property_id, user_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Like not found"
      });
    }

    res.json({
      success: true,
      message: "Property unliked successfully",
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to unlike property",
      error: err.message
    });
  }
});

// GET - Get all likes (optional - for admin purposes)
router.get("/", async (req, res) => {
  try {
    const result = await db.query(
      "SELECT * FROM property_likes ORDER BY liked_at DESC"
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
      message: "Failed to fetch likes",
      error: err.message
    });
  }
});

module.exports = router;
