module.exports.validatePropertyFilter = (req, res, next) => {
  const { city, available_for, min_budget, max_budget, min_area_sqft } = req.body;

  // Required checks
  if (!city) {
    return res.status(400).json({
      success: false,
      message: "City is required"
    });
  }

  if (!available_for) {
    return res.status(400).json({
      success: false,
      message: "Available for is required"
    });
  }

  // Optional validations
  if (min_budget && max_budget && min_budget > max_budget) {
    return res.status(400).json({
      success: false,
      message: "Min budget cannot be greater than max budget"
    });
  }

  if (min_area_sqft && min_area_sqft < 0) {
    return res.status(400).json({
      success: false,
      message: "Area must be positive"
    });
  }

  next();
};
