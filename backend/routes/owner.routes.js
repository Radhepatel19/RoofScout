const express = require("express");
const router = express.Router();
const db = require('../config/database');
const { authMiddleware } = require('../middleware/auth.middleware');

// POST - Register Owner
router.post('/register', async (req, res) => {
  try {
    const { full_name, email, phone } = req.body;

    // Basic validation
    if (!full_name || !email || !phone) {
      return res.status(400).json({
        success: false,
        message: 'full_name, email, and phone are required'
      });
    }

    // Upsert: Insert or Update if phone/email exists
    const result = await db.query(
      `INSERT INTO users (full_name, email, phone, is_owner, is_verified)
       VALUES ($1, $2, $3, true, false)
       ON CONFLICT (phone) 
       DO UPDATE SET
         full_name = EXCLUDED.full_name,
         email = EXCLUDED.email,
         is_owner = true
       RETURNING *`,
      [full_name, email, phone]
    );

    res.status(200).json({
      success: true,
      message: "Owner registered successfully",
      data: result.rows[0]
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Failed to register owner',
      error: error.message
    });
  }
});

// GET - Get all owners
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT * FROM users 
       WHERE is_owner = true 
       ORDER BY created_at DESC`
    );

    res.json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch owners',
      error: error.message
    });
  }
});

// GET - Get logged-in owner's profile
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await db.query(
      `SELECT * FROM users 
       WHERE user_id = $1 AND is_owner = true`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Owner not found'
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
      message: 'Failed to fetch owner profile',
      error: error.message
    });
  }
});

// GET - Get owner by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT * FROM users 
       WHERE user_id = $1 AND is_owner = true`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Owner not found'
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
      message: 'Failed to fetch owner',
      error: error.message
    });
  }
});

module.exports = router;
