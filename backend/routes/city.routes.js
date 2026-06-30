const express = require("express");
const router = express.Router();
const db = require('../config/database');
const jwt = require('jsonwebtoken');

// Middleware to extract user_id from JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).json({ success: false, message: 'No token provided' });

  const token = authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ success: false, message: 'Invalid token format' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user_id = decoded.user_id; // Attach user_id to request
    next();
  } catch (err) {
    return res.status(403).json({ success: false, message: 'Invalid or expired token' });
  }
};

// POST - Update city for logged-in user
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { city } = req.body;

    if (!city) {
      return res.status(400).json({
        success: false,
        message: 'City is required'
      });
    }

    const result = await db.query(
      'UPDATE users SET city = $1 WHERE user_id = $2 RETURNING *',
      [city, req.user_id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: "City updated successfully",
      data: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Failed to update city',
      error: error.message
    });
  }
});

// GET - Get user details for logged-in user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const result = await db.query(
      'SELECT * FROM users WHERE user_id = $1',
      [req.user_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user',
      error: error.message
    });
  }
});

// GET - Get all cities (same as before)
router.get('/cities', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT DISTINCT city FROM users WHERE city IS NOT NULL ORDER BY city ASC'
    );

    res.json({
      success: true,
      count: result.rows.length,
      data: result.rows.map(row => row.city)
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch cities',
      error: error.message
    });
  }
});

module.exports = router;
