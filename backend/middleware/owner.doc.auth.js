const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: "Token missing" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Store full decoded user object
    req.user = {
      user_id: decoded.user_id,
      email: decoded.email,   // optional (if present in token)
      role: decoded.role      // optional (admin/owner)
    };

    next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid token" });
  }
};
