const cloudinary = require('../config/cloudinary');
const multer = require('multer');

// Basic Multer storage (Memory Storage) - we will upload manually to Cloudinary for more control
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

/**
 * Upload buffer to Cloudinary
 * @param {Buffer} buffer 
 * @param {String} folder 
 * @returns {Promise}
 */
const uploadToCloudinary = (buffer, folder) => {
    return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
            { folder: folder },
            (error, result) => {
                if (error) return reject(error);
                resolve(result);
            }
        );
        stream.end(buffer);
    });
};

module.exports = {
    upload,
    uploadToCloudinary
};
