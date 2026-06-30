const express = require("express");
const router = express.Router();
const db = require('../config/database');

// POST - Save a property
router.post("/", async (req, res) => {
  try {
    const { user_id, property_id } = req.body;

    // Validate required fields
    if (!user_id || !property_id) {
      return res.status(400).json({
        success: false,
        message: "user_id and property_id are required"
      });
    }

    // Check if property is already saved
    const existingSave = await db.query(
      "SELECT * FROM saved_properties WHERE user_id = $1 AND property_id = $2",
      [user_id, property_id]
    );

    if (existingSave.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: "Property already saved by this user",
        data: existingSave.rows[0]
      });
    }

    const result = await db.query(
      `INSERT INTO saved_properties (user_id, property_id)
       VALUES ($1, $2)
       RETURNING *`,
      [user_id, property_id]
    );

    res.status(201).json({
      success: true,
      message: "Property saved successfully",
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to save property",
      error: err.message
    });
  }
});

// GET - Get all saved properties for a specific user
router.get("/user/:user_id", async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await db.query(
      `SELECT sp.*, p.* 
       FROM saved_properties sp
       INNER JOIN properties p ON sp.property_id = p.property_id
       WHERE sp.user_id = $1 
       ORDER BY sp.saved_at DESC`,
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
      message: "Failed to fetch saved properties",
      error: err.message
    });
  }
});

// GET - Get all saved properties for a user (without property details)
router.get("/user/:user_id/simple", async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await db.query(
      `SELECT * FROM saved_properties 
       WHERE user_id = $1 
       ORDER BY saved_at DESC`,
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
      message: "Failed to fetch saved properties",
      error: err.message
    });
  }
});

// GET - Check if a property is saved by a user
router.get("/check/:user_id/:property_id", async (req, res) => {
  try {
    const { user_id, property_id } = req.params;

    const result = await db.query(
      `SELECT * FROM saved_properties 
       WHERE user_id = $1 AND property_id = $2`,
      [user_id, property_id]
    );

    res.json({
      success: true,
      is_saved: result.rows.length > 0,
      data: result.rows.length > 0 ? result.rows[0] : null
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to check save status",
      error: err.message
    });
  }
});

// GET - Get all users who saved a specific property
router.get("/property/:property_id", async (req, res) => {
  try {
    const { property_id } = req.params;

    const result = await db.query(
      `SELECT * FROM saved_properties 
       WHERE property_id = $1 
       ORDER BY saved_at DESC`,
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
      message: "Failed to fetch property saves",
      error: err.message
    });
  }
});

// DELETE - Unsave a property (remove from saved_properties)
router.delete("/:user_id/:property_id", async (req, res) => {
  try {
    const { user_id, property_id } = req.params;

    const result = await db.query(
      `DELETE FROM saved_properties 
       WHERE user_id = $1 AND property_id = $2
       RETURNING *`,
      [user_id, property_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Saved property not found"
      });
    }

    res.json({
      success: true,
      message: "Property unsaved successfully",
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to unsave property",
      error: err.message
    });
  }
});

// GET - Get all saved properties (optional - for admin purposes)
router.get("/", async (req, res) => {
  try {
    const result = await db.query(
      "SELECT * FROM saved_properties ORDER BY saved_at DESC"
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
      message: "Failed to fetch saved properties",
      error: err.message
    });
  }
});

module.exports = router;
