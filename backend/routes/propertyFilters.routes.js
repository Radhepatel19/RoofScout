const express = require("express");
const router = express.Router();
const db = require('../config/database');
const { validatePropertyFilter } = require("../middleware/propertyFilter.middleware");
const { authMiddleware } = require("../middleware/auth.middleware");


// CREATE FILTER
router.post("/",
  authMiddleware,
  validatePropertyFilter,
  async (req, res) => {
    try {
      const user_id = req.user.id;
      const {
        city,
        available_for,
        min_budget,
        max_budget,
        bedrooms,
        bathrooms,
        property_type,
        furnishing_status,
        posted_by,
        min_area_sqft,
        available_from,
        amenities
      } = req.body;

      // Parse available_from date safely with relative UI chip offsets
      let parsedAvailableFrom = null;
      if (available_from) {
        const lowerVal = available_from.toString().toLowerCase().trim();
        const today = new Date();
        
        if (lowerVal === 'immediately' || lowerVal === 'anytime') {
          parsedAvailableFrom = today.toISOString().split('T')[0];
        } else if (lowerVal === 'within 5 days') {
          today.setDate(today.getDate() + 5);
          parsedAvailableFrom = today.toISOString().split('T')[0];
        } else if (lowerVal === 'next week') {
          today.setDate(today.getDate() + 7);
          parsedAvailableFrom = today.toISOString().split('T')[0];
        } else if (lowerVal === 'next month') {
          today.setMonth(today.getMonth() + 1);
          parsedAvailableFrom = today.toISOString().split('T')[0];
        } else if (!isNaN(Date.parse(available_from))) {
          parsedAvailableFrom = new Date(available_from).toISOString().split('T')[0];
        } else {
          parsedAvailableFrom = today.toISOString().split('T')[0];
        }
      }

      const result = await db.query(
        `INSERT INTO property_filters
        (user_id, city, available_for, min_budget, max_budget, bedrooms, bathrooms,
         property_type, furnishing_status, posted_by, min_area_sqft,
         available_from, amenities)
        VALUES
        ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
        RETURNING *`,
        [
          user_id,
          city,
          available_for,
          min_budget,
          max_budget,
          bedrooms,
          bathrooms,
          property_type,
          furnishing_status,
          posted_by,
          min_area_sqft,
          parsedAvailableFrom,
          amenities
        ]
      );

      res.status(201).json({
        success: true,
        data: result.rows[0]
      });

    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, message: "Server error" });
    }
  }
);


// GET USER FILTERS
router.get("/", authMiddleware, async (req, res) => {
  const user_id = req.user.id;

  const result = await db.query(
    "SELECT * FROM property_filters WHERE user_id = $1 ORDER BY created_at DESC",
    [user_id]
  );

  res.json({ success: true, data: result.rows });
});

module.exports = router;
