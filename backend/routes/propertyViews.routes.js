const express = require("express");
const router = express.Router();
const db = require('../config/database');

// POST - Record a property view
router.post("/", async (req, res) => {
  try {
    const { property_id, user_id } = req.body;

    // Validate required fields
    if (!property_id) {
      return res.status(400).json({
        success: false,
        message: "property_id is required"
      });
    }

    // If user_id is not provided, it's an anonymous view
    const result = await db.query(
      `INSERT INTO property_views (property_id, user_id)
       VALUES ($1, $2)
       RETURNING *`,
      [property_id, user_id || null]
    );

    res.status(201).json({
      success: true,
      message: "Property view recorded successfully",
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to record property view",
      error: err.message
    });
  }
});

// GET - Get all views for a specific property
router.get("/property/:property_id", async (req, res) => {
  try {
    const { property_id } = req.params;
    const { limit = 100, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM property_views 
       WHERE property_id = $1 
       ORDER BY viewed_at DESC
       LIMIT $2 OFFSET $3`,
      [property_id, parseInt(limit), parseInt(offset)]
    );

    // Get total count
    const countResult = await db.query(
      "SELECT COUNT(*) as total FROM property_views WHERE property_id = $1",
      [property_id]
    );

    res.json({
      success: true,
      count: result.rows.length,
      total: parseInt(countResult.rows[0].total),
      data: result.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch property views",
      error: err.message
    });
  }
});

// GET - Get view count for a specific property
router.get("/property/:property_id/count", async (req, res) => {
  try {
    const { property_id } = req.params;

    const result = await db.query(
      `SELECT 
         COUNT(*) as total_views,
         COUNT(DISTINCT user_id) as unique_viewers,
         COUNT(*) FILTER (WHERE user_id IS NULL) as anonymous_views
       FROM property_views 
       WHERE property_id = $1`,
      [property_id]
    );

    res.json({
      success: true,
      data: {
        property_id: parseInt(property_id),
        total_views: parseInt(result.rows[0].total_views),
        unique_viewers: parseInt(result.rows[0].unique_viewers),
        anonymous_views: parseInt(result.rows[0].anonymous_views)
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch view count",
      error: err.message
    });
  }
});

// GET - Get all properties viewed by a specific user
router.get("/user/:user_id", async (req, res) => {
  try {
    const { user_id } = req.params;
    const { limit = 100, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT pv.*, p.* 
       FROM property_views pv
       INNER JOIN properties p ON pv.property_id = p.property_id
       WHERE pv.user_id = $1 
       ORDER BY pv.viewed_at DESC
       LIMIT $2 OFFSET $3`,
      [user_id, parseInt(limit), parseInt(offset)]
    );

    // Get total count
    const countResult = await db.query(
      "SELECT COUNT(*) as total FROM property_views WHERE user_id = $1",
      [user_id]
    );

    res.json({
      success: true,
      count: result.rows.length,
      total: parseInt(countResult.rows[0].total),
      data: result.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch user views",
      error: err.message
    });
  }
});

// GET - Get all properties viewed by a user (simple - without property details)
router.get("/user/:user_id/simple", async (req, res) => {
  try {
    const { user_id } = req.params;
    const { limit = 100, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM property_views 
       WHERE user_id = $1 
       ORDER BY viewed_at DESC
       LIMIT $2 OFFSET $3`,
      [user_id, parseInt(limit), parseInt(offset)]
    );

    // Get total count
    const countResult = await db.query(
      "SELECT COUNT(*) as total FROM property_views WHERE user_id = $1",
      [user_id]
    );

    res.json({
      success: true,
      count: result.rows.length,
      total: parseInt(countResult.rows[0].total),
      data: result.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch user views",
      error: err.message
    });
  }
});

// GET - Get most viewed properties
router.get("/popular", async (req, res) => {
  try {
    const { limit = 10 } = req.query;

    const result = await db.query(
      `SELECT 
         pv.property_id,
         COUNT(*) as view_count,
         COUNT(DISTINCT pv.user_id) as unique_viewers,
         MAX(pv.viewed_at) as last_viewed_at,
         p.*
       FROM property_views pv
       INNER JOIN properties p ON pv.property_id = p.property_id
       GROUP BY pv.property_id, p.property_id
       ORDER BY view_count DESC
       LIMIT $1`,
      [parseInt(limit)]
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
      message: "Failed to fetch popular properties",
      error: err.message
    });
  }
});

// GET - Get all views (optional - for admin purposes)
router.get("/", async (req, res) => {
  try {
    const { limit = 100, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM property_views 
       ORDER BY viewed_at DESC
       LIMIT $1 OFFSET $2`,
      [parseInt(limit), parseInt(offset)]
    );

    // Get total count
    const countResult = await db.query(
      "SELECT COUNT(*) as total FROM property_views"
    );

    res.json({
      success: true,
      count: result.rows.length,
      total: parseInt(countResult.rows[0].total),
      data: result.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch views",
      error: err.message
    });
  }
});

module.exports = router;
