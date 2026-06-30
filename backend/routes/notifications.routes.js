const express = require("express");
const router = express.Router();
const db = require('../config/database');

// POST - Create a new notification
router.post("/", async (req, res) => {
  try {
    const { user_id, title, message, notification_type, related_entity_type, related_entity_id, data } = req.body;

    // Validate required fields
    if (!user_id || !title || !message || !notification_type) {
      return res.status(400).json({
        success: false,
        message: "user_id, title, message, and notification_type are required"
      });
    }

    const result = await db.query(
      `INSERT INTO notifications (user_id, title, message, notification_type, related_entity_type, related_entity_id, data)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        user_id,
        title,
        message,
        notification_type,
        related_entity_type || null,
        related_entity_id || null,
        data ? JSON.stringify(data) : '{}'
      ]
    );

    // Parse JSONB data
    const notification = {
      ...result.rows[0],
      data: typeof result.rows[0].data === 'string' 
        ? JSON.parse(result.rows[0].data) 
        : result.rows[0].data
    };

    res.status(201).json({
      success: true,
      message: "Notification created successfully",
      data: notification
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to create notification",
      error: err.message
    });
  }
});

// GET - Get all notifications for a specific user
router.get("/user/:user_id", async (req, res) => {
  try {
    const { user_id } = req.params;
    const { limit = 50, offset = 0, is_read, is_seen, notification_type } = req.query;

    let query = `SELECT * FROM notifications WHERE user_id = $1`;
    const params = [user_id];
    let paramCount = 2;

    if (is_read !== undefined) {
      query += ` AND is_read = $${paramCount}`;
      params.push(is_read === 'true');
      paramCount++;
    }

    if (is_seen !== undefined) {
      query += ` AND is_seen = $${paramCount}`;
      params.push(is_seen === 'true');
      paramCount++;
    }

    if (notification_type) {
      query += ` AND notification_type = $${paramCount}`;
      params.push(notification_type);
      paramCount++;
    }

    query += ` ORDER BY created_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);

    // Parse JSONB data for each row
    const notifications = result.rows.map(row => ({
      ...row,
      data: typeof row.data === 'string' 
        ? JSON.parse(row.data) 
        : row.data
    }));

    // Get unread count
    const unreadResult = await db.query(
      "SELECT COUNT(*) as unread_count FROM notifications WHERE user_id = $1 AND is_read = false",
      [user_id]
    );

    // Get unseen count
    const unseenResult = await db.query(
      "SELECT COUNT(*) as unseen_count FROM notifications WHERE user_id = $1 AND is_seen = false",
      [user_id]
    );

    res.json({
      success: true,
      count: notifications.length,
      unread_count: parseInt(unreadResult.rows[0].unread_count),
      unseen_count: parseInt(unseenResult.rows[0].unseen_count),
      data: notifications
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch notifications",
      error: err.message
    });
  }
});

// GET - Get unread notifications for a user
router.get("/user/:user_id/unread", async (req, res) => {
  try {
    const { user_id } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM notifications 
       WHERE user_id = $1 AND is_read = false 
       ORDER BY created_at DESC
       LIMIT $2 OFFSET $3`,
      [user_id, parseInt(limit), parseInt(offset)]
    );

    // Parse JSONB data for each row
    const notifications = result.rows.map(row => ({
      ...row,
      data: typeof row.data === 'string' 
        ? JSON.parse(row.data) 
        : row.data
    }));

    res.json({
      success: true,
      count: notifications.length,
      data: notifications
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch unread notifications",
      error: err.message
    });
  }
});

// GET - Get unseen notifications for a user
router.get("/user/:user_id/unseen", async (req, res) => {
  try {
    const { user_id } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM notifications 
       WHERE user_id = $1 AND is_seen = false 
       ORDER BY created_at DESC
       LIMIT $2 OFFSET $3`,
      [user_id, parseInt(limit), parseInt(offset)]
    );

    // Parse JSONB data for each row
    const notifications = result.rows.map(row => ({
      ...row,
      data: typeof row.data === 'string' 
        ? JSON.parse(row.data) 
        : row.data
    }));

    res.json({
      success: true,
      count: notifications.length,
      data: notifications
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch unseen notifications",
      error: err.message
    });
  }
});

// GET - Get notification counts for a user
router.get("/user/:user_id/counts", async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await db.query(
      `SELECT 
         COUNT(*) as total,
         COUNT(*) FILTER (WHERE is_read = false) as unread,
         COUNT(*) FILTER (WHERE is_seen = false) as unseen
       FROM notifications 
       WHERE user_id = $1`,
      [user_id]
    );

    res.json({
      success: true,
      data: {
        user_id: parseInt(user_id),
        total: parseInt(result.rows[0].total),
        unread: parseInt(result.rows[0].unread),
        unseen: parseInt(result.rows[0].unseen)
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch notification counts",
      error: err.message
    });
  }
});

// GET - Get a specific notification by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      "SELECT * FROM notifications WHERE notification_id = $1",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Notification not found"
      });
    }

    // Parse JSONB data
    const notification = {
      ...result.rows[0],
      data: typeof result.rows[0].data === 'string' 
        ? JSON.parse(result.rows[0].data) 
        : result.rows[0].data
    };

    res.json({
      success: true,
      data: notification
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch notification",
      error: err.message
    });
  }
});

// PUT - Mark notification as read
router.put("/:id/read", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `UPDATE notifications 
       SET is_read = true, read_at = CURRENT_TIMESTAMP
       WHERE notification_id = $1
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Notification not found"
      });
    }

    // Parse JSONB data
    const notification = {
      ...result.rows[0],
      data: typeof result.rows[0].data === 'string' 
        ? JSON.parse(result.rows[0].data) 
        : result.rows[0].data
    };

    res.json({
      success: true,
      message: "Notification marked as read",
      data: notification
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to mark notification as read",
      error: err.message
    });
  }
});

// PUT - Mark notification as seen
router.put("/:id/seen", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `UPDATE notifications 
       SET is_seen = true
       WHERE notification_id = $1
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Notification not found"
      });
    }

    // Parse JSONB data
    const notification = {
      ...result.rows[0],
      data: typeof result.rows[0].data === 'string' 
        ? JSON.parse(result.rows[0].data) 
        : result.rows[0].data
    };

    res.json({
      success: true,
      message: "Notification marked as seen",
      data: notification
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to mark notification as seen",
      error: err.message
    });
  }
});

// PUT - Mark all notifications as read for a user
router.put("/user/:user_id/read-all", async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await db.query(
      `UPDATE notifications 
       SET is_read = true, read_at = CURRENT_TIMESTAMP
       WHERE user_id = $1 AND is_read = false
       RETURNING *`,
      [user_id]
    );

    res.json({
      success: true,
      message: `${result.rows.length} notifications marked as read`,
      count: result.rows.length
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to mark notifications as read",
      error: err.message
    });
  }
});

// PUT - Mark all notifications as seen for a user
router.put("/user/:user_id/seen-all", async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await db.query(
      `UPDATE notifications 
       SET is_seen = true
       WHERE user_id = $1 AND is_seen = false
       RETURNING *`,
      [user_id]
    );

    res.json({
      success: true,
      message: `${result.rows.length} notifications marked as seen`,
      count: result.rows.length
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to mark notifications as seen",
      error: err.message
    });
  }
});

// GET - Get all notifications (optional - for admin purposes)
router.get("/", async (req, res) => {
  try {
    const { limit = 100, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM notifications 
       ORDER BY created_at DESC
       LIMIT $1 OFFSET $2`,
      [parseInt(limit), parseInt(offset)]
    );

    // Parse JSONB data for each row
    const notifications = result.rows.map(row => ({
      ...row,
      data: typeof row.data === 'string' 
        ? JSON.parse(row.data) 
        : row.data
    }));

    res.json({
      success: true,
      count: notifications.length,
      data: notifications
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch notifications",
      error: err.message
    });
  }
});

module.exports = router;
