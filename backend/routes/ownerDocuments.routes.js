const express = require("express");
const router = express.Router();
const db = require("../config/database");
const auth = require("../middleware/owner.doc.auth"); // JWT middleware
const { upload, uploadToCloudinary } = require("../middleware/cloudinaryUpload");

/* ======================================================
   POST - Upload Owner Documents (Owner only)
   ====================================================== */
router.post("/", auth, upload.fields([
  { name: 'aadhar_image_front', maxCount: 1 },
  { name: 'aadhar_image_back', maxCount: 1 },
  { name: 'pan_image', maxCount: 1 }
]), async (req, res) => {
  try {
    const owner_id = req.user.user_id; // from JWT

    const files = req.files;

    if (!files || !files.aadhar_image_front || !files.pan_image) {
      return res.status(400).json({
        success: false,
        message: "Aadhaar front image and PAN image are required"
      });
    }

    // Upload to Cloudinary
    const uploadTasks = [
      uploadToCloudinary(files.aadhar_image_front[0].buffer, 'owner_documents').then(res => ({ key: 'aadhar_image_front', url: res.secure_url })),
      uploadToCloudinary(files.pan_image[0].buffer, 'owner_documents').then(res => ({ key: 'pan_image', url: res.secure_url }))
    ];

    if (files.aadhar_image_back) {
      uploadTasks.push(
        uploadToCloudinary(files.aadhar_image_back[0].buffer, 'owner_documents').then(res => ({ key: 'aadhar_image_back', url: res.secure_url }))
      );
    }

    const uploadResults = await Promise.all(uploadTasks);
    const urls = {};
    uploadResults.forEach(result => {
      urls[result.key] = result.url;
    });

    const result = await db.query(
      `INSERT INTO owner_documents
       (owner_id, aadhar_image_front, aadhar_image_back, pan_image)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (owner_id)
       DO UPDATE SET
         aadhar_image_front = EXCLUDED.aadhar_image_front,
         aadhar_image_back  = EXCLUDED.aadhar_image_back,
         pan_image          = EXCLUDED.pan_image,
         uploaded_at        = CURRENT_TIMESTAMP
       RETURNING *`,
      [
        owner_id,
        urls.aadhar_image_front,
        urls.aadhar_image_back || null,
        urls.pan_image
      ]
    );

    res.status(201).json({
      success: true,
      message: "Owner documents uploaded successfully",
      data: result.rows[0]
    });

  } catch (err) {
    console.error("Owner documents upload error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to upload owner documents",
      error: err.message
    });
  }
});


/* ======================================================
   GET - Get Logged-in Owner Documents
   ====================================================== */
router.get("/me", auth, async (req, res) => {
  try {
    const owner_id = req.user.user_id;

    const result = await db.query(
      `SELECT * FROM owner_documents WHERE owner_id = $1`,
      [owner_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No documents found"
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
      message: "Failed to fetch documents",
      error: err.message
    });
  }
});


/* ======================================================
   GET - Get Document by ID (Admin)
   ====================================================== */
router.get("/:document_id", auth, async (req, res) => {
  try {
    const { document_id } = req.params;

    const result = await db.query(
      `SELECT * FROM owner_documents WHERE document_id = $1`,
      [document_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Document not found"
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
      message: "Failed to fetch document",
      error: err.message
    });
  }
});


/* ======================================================
   PUT - Verify / Reject Owner Documents (Admin)
   ====================================================== */
router.put("/:document_id/verify", auth, async (req, res) => {
  try {
    const { document_id } = req.params;
    const { verification_status } = req.body;

    const validStatus = ["pending", "verified", "rejected"];
    if (!validStatus.includes(verification_status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid verification status"
      });
    }

    const verified_at =
      verification_status === "verified" ? new Date() : null;

    const result = await db.query(
      `UPDATE owner_documents
       SET verification_status = $1,
           verified_at = $2
       WHERE document_id = $3
       RETURNING *`,
      [verification_status, verified_at, document_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Document not found"
      });
    }

    res.json({
      success: true,
      message: "Verification status updated",
      data: result.rows[0]
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to verify documents",
      error: err.message
    });
  }
});


/* ======================================================
   GET - All Owner Documents (Admin)
   ====================================================== */
router.get("/", auth, async (req, res) => {
  try {
    const result = await db.query(
      `SELECT * FROM owner_documents ORDER BY uploaded_at DESC`
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
      message: "Failed to fetch owner documents",
      error: err.message
    });
  }
});

module.exports = router;
