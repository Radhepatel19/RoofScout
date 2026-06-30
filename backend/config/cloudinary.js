const cloudinary = require('cloudinary').v2;
require('dotenv').config();

// Cloudinary SDK automatically looks for CLOUDINARY_URL in process.env
// But we can also set it explicitly if needed.
cloudinary.config({
    cloudinary_url: process.env.CLOUDINARY_URL,
});

module.exports = cloudinary;
