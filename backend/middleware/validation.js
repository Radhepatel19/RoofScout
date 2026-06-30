const { body, validationResult } = require('express-validator');

// User registration validation
const validateUserRegistration = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),

  body('phone')
    .isMobilePhone()
    .withMessage('Please provide a valid phone number'),

  body('full_name')
    .trim()
    .notEmpty()
    .withMessage('Full name is required')
    .isLength({ min: 2, max: 100 })
    .withMessage('Full name must be between 2 and 100 characters'),

  body('gender')
    .optional()
    .isIn(['Male', 'Female', 'Other', 'Prefer not to say'])
    .withMessage('Invalid gender value'),

  body('looking_for')
    .optional()
    .isIn(['Rent', 'Buy', 'Invest', 'Commercial'])
    .withMessage('Invalid looking_for value'),

  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    next();
  }
];

// User update validation
const validateUserUpdate = [
  body('email')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),

  body('phone')
    .optional()
    .isMobilePhone()
    .withMessage('Please provide a valid phone number'),

  body('full_name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Full name must be between 2 and 100 characters'),

  body('gender')
    .optional()
    .isIn(['Male', 'Female', 'Other', 'Prefer not to say'])
    .withMessage('Invalid gender value'),

  body('looking_for')
    .optional()
    .isIn(['Rent', 'Buy', 'Invest', 'Commercial'])
    .withMessage('Invalid looking_for value'),

  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    next();
  }
];

module.exports = {
  validateUserRegistration,
  validateUserUpdate
};