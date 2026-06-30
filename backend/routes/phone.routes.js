const express = require("express");
const router = express.Router();
const db = require('../config/database');
const jwt = require('jsonwebtoken');

// POST - Register OR Login user with phone
router.post('/', async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required'
      });
    }

    // 1. Check if user exists
    let result = await db.query(
      'SELECT user_id, phone FROM users WHERE phone = $1',
      [phone]
    );

    let user;

    // 2. If not exists → create user
    if (result.rows.length === 0) {
      const placeholderEmail = `${phone}@roofscout.com`;
      const placeholderName = `User ${phone}`;
      const insert = await db.query(
        'INSERT INTO users (phone, email, full_name, is_verified) VALUES ($1, $2, $3, false) RETURNING user_id, phone',
        [phone, placeholderEmail, placeholderName]
      );
      user = insert.rows[0];
    } else {
      user = result.rows[0];
    }

    // 3. Generate JWT using auto-generated user_id
    const token = jwt.sign(
      { user_id: user.user_id },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(200).json({
      success: true,
      message: 'Login successful',
      token   // 👈 Flutter stores this
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Failed to login/register',
      error: error.message
    });
  }
});

module.exports = router;
