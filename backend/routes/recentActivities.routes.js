const express = require("express");
const router = express.Router();
const db = require('../config/database');

// POST - Create a new activity
router.post("/", async (req, res) => {
  try {
    const { user_id, activity_type, activity_data, ip_address, user_agent } = req.body;

    // Validate required fields
    if (!user_id || !activity_type) {
      return res.status(400).json({
        success: false,
        message: "user_id and activity_type are required"
      });
    }

    // Get IP address and user agent from request if not provided
    const clientIp = ip_address || req.ip || req.headers['x-forwarded-for'] || req.connection.remoteAddress;
    const clientUserAgent = user_agent || req.headers['user-agent'] || null;

    const result = await db.query(
      `INSERT INTO recent_activities (user_id, activity_type, activity_data, ip_address, user_agent)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [
        user_id,
        activity_type,
        activity_data ? JSON.stringify(activity_data) : '{}',
        clientIp,
        clientUserAgent
      ]
    );

    res.status(201).json({
      success: true,
      message: "Activity logged successfully",
      data: {
        ...result.rows[0],
        activity_data: typeof result.rows[0].activity_data === 'string' 
          ? JSON.parse(result.rows[0].activity_data) 
          : result.rows[0].activity_data
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to log activity",
      error: err.message
    });
  }
});

// GET - Get all activities for a specific user
router.get("/user/:user_id", async (req, res) => {
  try {
    const { user_id } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM recent_activities 
       WHERE user_id = $1 
       ORDER BY created_at DESC
       LIMIT $2 OFFSET $3`,
      [user_id, parseInt(limit), parseInt(offset)]
    );

    // Parse JSONB activity_data for each row
    const activities = result.rows.map(row => ({
      ...row,
      activity_data: typeof row.activity_data === 'string' 
        ? JSON.parse(row.activity_data) 
        : row.activity_data
    }));

    res.json({
      success: true,
      count: activities.length,
      data: activities
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch user activities",
      error: err.message
    });
  }
});

// GET - Get activities by type
router.get("/type/:activity_type", async (req, res) => {
  try {
    const { activity_type } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM recent_activities 
       WHERE activity_type = $1 
       ORDER BY created_at DESC
       LIMIT $2 OFFSET $3`,
      [activity_type, parseInt(limit), parseInt(offset)]
    );

    // Parse JSONB activity_data for each row
    const activities = result.rows.map(row => ({
      ...row,
      activity_data: typeof row.activity_data === 'string' 
        ? JSON.parse(row.activity_data) 
        : row.activity_data
    }));

    res.json({
      success: true,
      count: activities.length,
      data: activities
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch activities by type",
      error: err.message
    });
  }
});

// GET - Get activities by user and type
router.get("/user/:user_id/type/:activity_type", async (req, res) => {
  try {
    const { user_id, activity_type } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM recent_activities 
       WHERE user_id = $1 AND activity_type = $2 
       ORDER BY created_at DESC
       LIMIT $3 OFFSET $4`,
      [user_id, activity_type, parseInt(limit), parseInt(offset)]
    );

    // Parse JSONB activity_data for each row
    const activities = result.rows.map(row => ({
      ...row,
      activity_data: typeof row.activity_data === 'string' 
        ? JSON.parse(row.activity_data) 
        : row.activity_data
    }));

    res.json({
      success: true,
      count: activities.length,
      data: activities
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch activities",
      error: err.message
    });
  }
});

// GET - Get a specific activity by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      "SELECT * FROM recent_activities WHERE activity_id = $1",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Activity not found"
      });
    }

    // Parse JSONB activity_data
    const activity = {
      ...result.rows[0],
      activity_data: typeof result.rows[0].activity_data === 'string' 
        ? JSON.parse(result.rows[0].activity_data) 
        : result.rows[0].activity_data
    };

    res.json({
      success: true,
      data: activity
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch activity",
      error: err.message
    });
  }
});

// GET - Get all activities (optional - for admin purposes)
router.get("/", async (req, res) => {
  try {
    const { limit = 100, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM recent_activities 
       ORDER BY created_at DESC
       LIMIT $1 OFFSET $2`,
      [parseInt(limit), parseInt(offset)]
    );

    // Parse JSONB activity_data for each row
    const activities = result.rows.map(row => ({
      ...row,
      activity_data: typeof row.activity_data === 'string' 
        ? JSON.parse(row.activity_data) 
        : row.activity_data
    }));

    res.json({
      success: true,
      count: activities.length,
      data: activities
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch activities",
      error: err.message
    });
  }
});

module.exports = router;
