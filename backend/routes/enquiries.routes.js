const express = require("express");
const router = express.Router();
const db = require('../config/database');

// POST - Create a new enquiry
router.post("/", async (req, res) => {
    try {
        const { property_id, user_id, message, contact_phone, contact_email } = req.body;

        if (!property_id || !user_id || !message) {
            return res.status(400).json({
                success: false,
                message: "property_id, user_id, and message are required"
            });
        }

        // In a real scenario, we might want to fetch the owner_id from properties table if needed for notifications
        // but the user specifically asked to delete owner_id in enquiries (implying the column/field).
        // Assuming the table column is removed or allows NULL, or we join properties table for GET.

        const result = await db.query(
            `INSERT INTO enquiries (property_id, user_id, message, contact_phone, contact_email)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
            [property_id, user_id, message, contact_phone, contact_email]
        );

        res.status(201).json({
            success: true,
            message: "Enquiry sent successfully",
            data: result.rows[0]
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({
            success: false,
            message: "Failed to send enquiry",
            error: err.message
        });
    }
});

// GET - Get enquiries for a specific owner
router.get("/owner/:owner_id", async (req, res) => {
    try {
        const { owner_id } = req.params;

        const result = await db.query(
            `SELECT e.*, p.title as property_title, u.full_name as user_name 
       FROM enquiries e
       JOIN properties p ON e.property_id = p.property_id
       JOIN users u ON e.user_id = u.user_id
       WHERE p.owner_id = $1 
       ORDER BY e.created_at DESC`,
            [owner_id]
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
            message: "Failed to fetch enquiries",
            error: err.message
        });
    }
});

// GET - Get enquiries for a specific user (the one who inquired)
router.get("/user/:user_id", async (req, res) => {
    try {
        const { user_id } = req.params;

        const result = await db.query(
            `SELECT e.*, p.title as property_title 
       FROM enquiries e
       JOIN properties p ON e.property_id = p.property_id
       WHERE e.user_id = $1 
       ORDER BY e.created_at DESC`,
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
            message: "Failed to fetch your enquiries",
            error: err.message
        });
    }
});

// PUT - Update enquiry status
router.put("/:id/status", async (req, res) => {
    try {
        const { id } = req.params;
        const { enquiry_status } = req.body;

        const validStatuses = ['unread', 'read', 'responded'];
        if (!validStatuses.includes(enquiry_status)) {
            return res.status(400).json({
                success: false,
                message: `Status must be one of: ${validStatuses.join(', ')}`
            });
        }

        const result = await db.query(
            `UPDATE enquiries 
       SET enquiry_status = $1
       WHERE enquiry_id = $2
       RETURNING *`,
            [enquiry_status, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: "Enquiry not found"
            });
        }

        res.json({
            success: true,
            message: "Enquiry status updated",
            data: result.rows[0]
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({
            success: false,
            message: "Failed to update enquiry status",
            error: err.message
        });
    }
});

module.exports = router;
