const jwt = require("jsonwebtoken");

module.exports.authMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: "Authorization token missing"
    });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Store user_id in req.user.id to match propertyFilters.routes.js expectations
    req.user = { id: decoded.user_id };

    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token"
    });
  }
};
