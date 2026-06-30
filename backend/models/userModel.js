const db = require('../config/database');

const User = {
  // Create a new user
  async create(userData) {
    const query = `
      INSERT INTO users (
        email,
        phone,
        full_name,
        gender,
        occupation,
        looking_for,
        about_me,
        profile_picture,
        city
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *;
    `;

    const values = [
      userData.email,
      userData.phone,
      userData.full_name,
      userData.gender || null,
      userData.occupation || null,
      userData.looking_for || null,
      userData.about_me || null,
      userData.profile_picture || null,
      userData.city || null
    ];

    const result = await db.query(query, values);
    return result.rows[0];
  },

  // Find user by ID
  async findById(userId) {
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
        created_at,
        updated_at
      FROM users
      WHERE user_id = $1;
    `;

    const result = await db.query(query, [userId]);
    return result.rows[0];
  },

  // Find user by email
  async findByEmail(email) {
    const query = `
      SELECT * FROM users
      WHERE email = $1;
    `;

    const result = await db.query(query, [email]);
    return result.rows[0];
  },

  // Find user by phone
  async findByPhone(phone) {
    const query = `
      SELECT * FROM users
      WHERE phone = $1;
    `;

    const result = await db.query(query, [phone]);
    return result.rows[0];
  },

  // Update user
  async update(userId, updateData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    // Build dynamic query based on provided fields
    Object.keys(updateData).forEach(key => {
      if (key !== 'user_id' && updateData[key] !== undefined) {
        fields.push(`${key} = $${paramCount}`);
        values.push(updateData[key]);
        paramCount++;
      }
    });

    // Add updated_at timestamp
    fields.push('updated_at = CURRENT_TIMESTAMP');

    // Add user_id to values
    values.push(userId);

    const query = `
      UPDATE users
      SET ${fields.join(', ')}
      WHERE user_id = $${paramCount}
      RETURNING *;
    `;

    const result = await db.query(query, values);
    return result.rows[0];
  },

  // Delete user
  async delete(userId) {
    const query = `
      DELETE FROM users
      WHERE user_id = $1
      RETURNING user_id, email, full_name;
    `;

    const result = await db.query(query, [userId]);
    return result.rows[0];
  },

  // Get all users (with pagination)
  async findAll(limit = 10, offset = 0) {
    const query = `
      SELECT
        user_id,
        email,
        phone,
        full_name,
        gender,
        occupation,
        looking_for,
        city,
        created_at
      FROM users
      ORDER BY created_at DESC
      LIMIT $1 OFFSET $2;
    `;

    const result = await db.query(query, [limit, offset]);
    return result.rows;
  },

  // Count total users
  async count() {
    const query = 'SELECT COUNT(*) FROM users;';
    const result = await db.query(query);
    return parseInt(result.rows[0].count);
  },

  // Check if user exists by email or phone
  async exists(email, phone) {
    const query = `
      SELECT user_id FROM users
      WHERE email = $1 OR phone = $2;
    `;

    const result = await db.query(query, [email, phone]);
    return result.rows;
  },

  // Get users by city
  async findByCity(city, limit = 10, offset = 0) {
    const query = `
      SELECT
        user_id,
        email,
        phone,
        full_name,
        gender,
        occupation,
        looking_for,
        profile_picture,
        city,
        created_at
      FROM users
      WHERE city ILIKE $1
      ORDER BY created_at DESC
      LIMIT $2 OFFSET $3;
    `;

    const result = await db.query(query, [`%${city}%`, limit, offset]);
    return result.rows;
  }
};

module.exports = User;