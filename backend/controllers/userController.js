const User = require('../models/userModel');

const UserController = {
  // Register a new user
  async register(req, res) {
    try {
      let {
        email,
        phone,
        full_name,
        gender,
        occupation,
        looking_for,
        about_me,
        profile_picture,
        city
      } = req.body;

      // Lowercase enum-like fields for DB check constraints
      if (gender) gender = gender.toLowerCase();
      if (looking_for) looking_for = looking_for.toLowerCase();

      // Check if user already exists with email or phone
      const existingEmail = email ? await User.findByEmail(email) : null;
      const existingPhone = await User.findByPhone(phone);

      if (existingEmail && (!existingPhone || existingPhone.user_id !== existingEmail.user_id)) {
        return res.status(409).json({
          success: false,
          message: 'User with this email already exists'
        });
      }

      if (existingPhone) {
        // If user exists with this phone but no email, we treat it as completing registration (UPSERT)
        if (!existingPhone.email || existingPhone.email === "") {
          const userData = {
            email,
            full_name,
            gender,
            occupation,
            looking_for,
            about_me,
            profile_picture,
            city
          };
          const updatedUser = await User.update(existingPhone.user_id, userData);
          return res.status(200).json({
            success: true,
            message: 'User profile updated successfully',
            data: updatedUser
          });
        }

        return res.status(409).json({
          success: false,
          message: 'User with this phone number already exists'
        });
      }

      // Create user
      const userData = {
        email,
        phone,
        full_name,
        gender,
        occupation,
        looking_for,
        about_me,
        profile_picture,
        city
      };

      const newUser = await User.create(userData);

      res.status(201).json({
        success: true,
        message: 'User registered successfully',
        data: newUser
      });
    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Get user by ID
  async getUserById(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findById(parseInt(id));

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      res.status(200).json({
        success: true,
        data: user
      });
    } catch (error) {
      console.error('Get user error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Update user
  async updateUser(req, res) {
    try {
      const { id } = req.params;
      const updateData = { ...req.body };
      const { uploadToCloudinary } = require('../middleware/cloudinaryUpload');

      // Handle profile picture upload if file exists
      if (req.file) {
        const cloudinaryResult = await uploadToCloudinary(req.file.buffer, 'user_profiles');
        updateData.profile_picture = cloudinaryResult.secure_url;
      }

      // Lowercase enum-like fields for DB check constraints
      if (updateData.gender) updateData.gender = updateData.gender.toLowerCase();
      if (updateData.looking_for) updateData.looking_for = updateData.looking_for.toLowerCase();

      // Check if user exists
      const existingUser = await User.findById(parseInt(id));
      if (!existingUser) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      // Check if email is being updated and if it's already taken
      if (updateData.email && updateData.email !== existingUser.email) {
        const emailExists = await User.findByEmail(updateData.email);
        if (emailExists && emailExists.user_id !== parseInt(id)) {
          return res.status(409).json({
            success: false,
            message: 'Email already in use by another user'
          });
        }
      }

      // Check if phone is being updated and if it's already taken
      if (updateData.phone && updateData.phone !== existingUser.phone) {
        const phoneExists = await User.findByPhone(updateData.phone);
        if (phoneExists && phoneExists.user_id !== parseInt(id)) {
          return res.status(409).json({
            success: false,
            message: 'Phone number already in use by another user'
          });
        }
      }

      // Update user
      const updatedUser = await User.update(parseInt(id), updateData);

      res.status(200).json({
        success: true,
        message: 'User updated successfully',
        data: updatedUser
      });
    } catch (error) {
      console.error('Update user error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Delete user
  async deleteUser(req, res) {
    try {
      const { id } = req.params;

      // Check if user exists
      const existingUser = await User.findById(parseInt(id));
      if (!existingUser) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      // Delete user
      const deletedUser = await User.delete(parseInt(id));

      res.status(200).json({
        success: true,
        message: 'User deleted successfully',
        data: deletedUser
      });
    } catch (error) {
      console.error('Delete user error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Get all users
  async getAllUsers(req, res) {
    try {
      const { page = 1, limit = 10 } = req.query;
      const offset = (page - 1) * limit;

      const users = await User.findAll(parseInt(limit), parseInt(offset));
      const totalUsers = await User.count();
      const totalPages = Math.ceil(totalUsers / limit);

      res.status(200).json({
        success: true,
        data: {
          users,
          pagination: {
            currentPage: parseInt(page),
            totalPages,
            totalUsers,
            hasNextPage: page < totalPages,
            hasPrevPage: page > 1
          }
        }
      });
    } catch (error) {
      console.error('Get all users error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Search users
  async searchUsers(req, res) {
    try {
      const {
        city,
        looking_for,
        occupation,
        gender,
        page = 1,
        limit = 10
      } = req.query;

      const db = require('../config/database');
      const offset = (page - 1) * limit;
      const conditions = [];
      const values = [];
      let paramCount = 1;

      // Build dynamic query based on search parameters
      if (city) {
        conditions.push(`city ILIKE $${paramCount}`);
        values.push(`%${city}%`);
        paramCount++;
      }

      if (looking_for) {
        conditions.push(`looking_for = $${paramCount}`);
        values.push(looking_for);
        paramCount++;
      }

      if (occupation) {
        conditions.push(`occupation ILIKE $${paramCount}`);
        values.push(`%${occupation}%`);
        paramCount++;
      }

      if (gender) {
        conditions.push(`gender = $${paramCount}`);
        values.push(gender);
        paramCount++;
      }

      // Construct WHERE clause
      let whereClause = '';
      if (conditions.length > 0) {
        whereClause = `WHERE ${conditions.join(' AND ')}`;
      }

      // Query for users
      const query = `
        SELECT
          user_id,
          email,
          phone,
          full_name,
          gender,
          occupation,
          looking_for,
          about_me,
          profile_picture,
          city,
          created_at
        FROM users
        ${whereClause}
        ORDER BY created_at DESC
        LIMIT $${paramCount} OFFSET $${paramCount + 1};
      `;

      values.push(parseInt(limit), parseInt(offset));

      const result = await db.query(query, values);
      const users = result.rows;

      // Count total matching users
      const countQuery = `
        SELECT COUNT(*) FROM users ${whereClause};
      `;
      const countValues = values.slice(0, values.length - 2);
      const countResult = await db.query(countQuery, countValues);
      const totalUsers = parseInt(countResult.rows[0].count);
      const totalPages = Math.ceil(totalUsers / limit);

      res.status(200).json({
        success: true,
        data: {
          users,
          pagination: {
            currentPage: parseInt(page),
            totalPages,
            totalUsers,
            hasNextPage: page < totalPages,
            hasPrevPage: page > 1
          }
        }
      });
    } catch (error) {
      console.error('Search users error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Get users by city
  async getUsersByCity(req, res) {
    try {
      const { city } = req.params;
      const { page = 1, limit = 10 } = req.query;
      const offset = (page - 1) * limit;

      const users = await User.findByCity(city, parseInt(limit), parseInt(offset));

      // Count total users in this city
      const db = require('../config/database');
      const countQuery = 'SELECT COUNT(*) FROM users WHERE city ILIKE $1';
      const countResult = await db.query(countQuery, [`%${city}%`]);
      const totalUsers = parseInt(countResult.rows[0].count);
      const totalPages = Math.ceil(totalUsers / limit);

      res.status(200).json({
        success: true,
        data: {
          users,
          pagination: {
            currentPage: parseInt(page),
            totalPages,
            totalUsers,
            hasNextPage: page < totalPages,
            hasPrevPage: page > 1
          }
        }
      });
    } catch (error) {
      console.error('Get users by city error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
};

module.exports = UserController;