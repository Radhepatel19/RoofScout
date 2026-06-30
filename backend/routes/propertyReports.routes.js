const express = require("express");
const router = express.Router();
const db = require('../config/database');

// POST - Create a new property report
router.post("/", async (req, res) => {
  try {
    const { property_id, user_id, report_type, description, status } = req.body;

    // Validate required fields
    if (!property_id || !user_id || !report_type || !description) {
      return res.status(400).json({
        success: false,
        message: "property_id, user_id, report_type, and description are required"
      });
    }

    // Validate report_type
    const validReportTypes = [
      'fake_listing',
      'already_sold_rented',
      'wrong_info',
      'spam',
      'inappropriate',
      'duplicate',
      'scam',
      'other'
    ];
    if (!validReportTypes.includes(report_type)) {
      return res.status(400).json({
        success: false,
        message: `report_type must be one of: ${validReportTypes.join(', ')}`
      });
    }

    // Validate status if provided
    if (status) {
      const validStatuses = ['pending', 'reviewing', 'resolved', 'dismissed'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: `status must be one of: ${validStatuses.join(', ')}`
        });
      }
    }

    const result = await db.query(
      `INSERT INTO property_reports (property_id, user_id, report_type, description, status)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [property_id, user_id, report_type, description, status || 'pending']
    );

    res.status(201).json({
      success: true,
      message: "Report submitted successfully",
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to submit report",
      error: err.message
    });
  }
});

// GET - Get all reports for a specific property
router.get("/property/:property_id", async (req, res) => {
  try {
    const { property_id } = req.params;

    const result = await db.query(
      `SELECT * FROM property_reports 
       WHERE property_id = $1 
       ORDER BY created_at DESC`,
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
      message: "Failed to fetch property reports",
      error: err.message
    });
  }
});

// GET - Get all reports by a specific user
router.get("/user/:user_id", async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await db.query(
      `SELECT * FROM property_reports 
       WHERE user_id = $1 
       ORDER BY created_at DESC`,
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
      message: "Failed to fetch user reports",
      error: err.message
    });
  }
});

// GET - Get reports by status
router.get("/status/:status", async (req, res) => {
  try {
    const { status } = req.params;

    const validStatuses = ['pending', 'reviewing', 'resolved', 'dismissed'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `status must be one of: ${validStatuses.join(', ')}`
      });
    }

    const result = await db.query(
      `SELECT * FROM property_reports 
       WHERE status = $1 
       ORDER BY created_at DESC`,
      [status]
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
      message: "Failed to fetch reports by status",
      error: err.message
    });
  }
});

// GET - Get reports by type
router.get("/type/:report_type", async (req, res) => {
  try {
    const { report_type } = req.params;

    const validReportTypes = [
      'fake_listing',
      'already_sold_rented',
      'wrong_info',
      'spam',
      'inappropriate',
      'duplicate',
      'scam',
      'other'
    ];
    if (!validReportTypes.includes(report_type)) {
      return res.status(400).json({
        success: false,
        message: `report_type must be one of: ${validReportTypes.join(', ')}`
      });
    }

    const result = await db.query(
      `SELECT * FROM property_reports 
       WHERE report_type = $1 
       ORDER BY created_at DESC`,
      [report_type]
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
      message: "Failed to fetch reports by type",
      error: err.message
    });
  }
});

// GET - Get a specific report by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      "SELECT * FROM property_reports WHERE report_id = $1",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Report not found"
      });
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch report",
      error: err.message
    });
  }
});

// PUT - Update report status
router.put("/:id/status", async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({
        success: false,
        message: "status is required"
      });
    }

    const validStatuses = ['pending', 'reviewing', 'resolved', 'dismissed'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `status must be one of: ${validStatuses.join(', ')}`
      });
    }

    const result = await db.query(
      `UPDATE property_reports 
       SET status = $1, updated_at = CURRENT_TIMESTAMP
       WHERE report_id = $2
       RETURNING *`,
      [status, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Report not found"
      });
    }

    res.json({
      success: true,
      message: "Report status updated successfully",
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to update report status",
      error: err.message
    });
  }
});

// PUT - Update report (description or other fields)
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { description, report_type } = req.body;

    if (!description && !report_type) {
      return res.status(400).json({
        success: false,
        message: "At least one field (description or report_type) is required to update"
      });
    }

    let updateQuery = "UPDATE property_reports SET ";
    const updateFields = [];
    const values = [];
    let paramCount = 1;

    if (description) {
      updateFields.push(`description = $${paramCount}`);
      values.push(description);
      paramCount++;
    }

    if (report_type) {
      const validReportTypes = [
        'fake_listing',
        'already_sold_rented',
        'wrong_info',
        'spam',
        'inappropriate',
        'duplicate',
        'scam',
        'other'
      ];
      if (!validReportTypes.includes(report_type)) {
        return res.status(400).json({
          success: false,
          message: `report_type must be one of: ${validReportTypes.join(', ')}`
        });
      }
      updateFields.push(`report_type = $${paramCount}`);
      values.push(report_type);
      paramCount++;
    }

    updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
    updateQuery += updateFields.join(", ");
    updateQuery += ` WHERE report_id = $${paramCount} RETURNING *`;
    values.push(id);

    const result = await db.query(updateQuery, values);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Report not found"
      });
    }

    res.json({
      success: true,
      message: "Report updated successfully",
      data: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to update report",
      error: err.message
    });
  }
});

// GET - Get all reports (optional - for admin purposes)
router.get("/", async (req, res) => {
  try {
    const result = await db.query(
      "SELECT * FROM property_reports ORDER BY created_at DESC"
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
      message: "Failed to fetch reports",
      error: err.message
    });
  }
});

module.exports = router;
