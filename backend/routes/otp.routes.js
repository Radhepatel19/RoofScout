const express = require("express");
const router = express.Router();
const db = require("../config/database");
const jwt = require("jsonwebtoken");

// Helper: generate OTP
const generateOtp = () =>
  Math.floor(100000 + Math.random() * 900000).toString();

router.post("/send", async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone || phone.length !== 10) {
      return res.status(400).json({ success: false, message: "Invalid phone (must be 10 digits)" });
    }

    const otp = generateOtp();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 min

    await db.query("DELETE FROM otps WHERE phone = $1", [phone]);

    await db.query(
      "INSERT INTO otps (phone, otp, expires_at) VALUES ($1,$2,$3)",
      [phone, otp, expiresAt]
    );

    console.log("OTP for", phone, "is:", otp);

    res.json({ success: true, message: "OTP sent successfully" });
  } catch (error) {
    console.error("OTP Send Error:", error);
    res.status(500).json({ success: false, message: "Failed to send OTP", error: error.message });
  }
});

/**
 * VERIFY OTP + JWT
 */
router.post("/verify", async (req, res) => {
  const { phone, otp } = req.body;

  const result = await db.query(
    "SELECT * FROM otps WHERE phone=$1 AND otp=$2",
    [phone, otp]
  );

  if (result.rows.length === 0) {
    return res.status(400).json({ success: false, message: "Invalid OTP" });
  }

  if (new Date(result.rows[0].expires_at) < new Date()) {
    return res.status(400).json({ success: false, message: "OTP expired" });
  }

  await db.query("DELETE FROM otps WHERE phone=$1", [phone]);

  // Find or create user
  let userResult = await db.query(
    "SELECT user_id FROM users WHERE phone=$1",
    [phone]
  );

  let userId;
  if (userResult.rows.length === 0) {
    const insert = await db.query(
      "INSERT INTO users (phone, is_verified) VALUES ($1,true) RETURNING user_id",
      [phone]
    );
    userId = insert.rows[0].user_id;
  } else {
    userId = userResult.rows[0].user_id;
    // Ensure existing user is marked as verified
    await db.query(
      "UPDATE users SET is_verified = true WHERE user_id = $1",
      [userId]
    );
  }

  const token = jwt.sign(
    { user_id: userId },
    process.env.JWT_SECRET,
    { expiresIn: "30d" }
  );

  res.json({ success: true, token, user_id: userId });
});

module.exports = router;
