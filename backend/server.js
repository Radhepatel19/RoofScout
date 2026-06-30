const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const userRoutes = require('./routes/userRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Routes :-
app.use('/api/users', userRoutes);

// Phone Users Data: Post and Get
const phoneRoutes = require('./routes/phone.routes');
app.use('/api/phone', phoneRoutes);

const otpRoutes = require("./routes/otp.routes");
app.use("/api/otp", otpRoutes);

//Owner Data: Post and Get
const ownerRoutes = require('./routes/owner.routes');
app.use('/api/owners', ownerRoutes);

//City Data: Post and Get
const cityRoutes = require('./routes/city.routes');
app.use('/api/city', cityRoutes);

//PropertyFilter Data : Post and Get
const propertyFilterRoutes = require('./routes/propertyFilters.routes');
app.use('/api/property-filters', propertyFilterRoutes);

//Property Data: Post and Get
const propertyRoutes = require("./routes/property.routes");
app.use("/api/properties", propertyRoutes);

//Property Images Data: Post and Get
const propertyImagesRoutes = require("./routes/propertyImages.routes");
app.use("/api/property-images", propertyImagesRoutes);

//Property Likes Data: Post, Get and Delete
const propertyLikesRoutes = require("./routes/propertyLikes.routes");
app.use("/api/property-likes", propertyLikesRoutes);

//User Documents Data: Post, Get and Put
const userDocumentsRoutes = require("./routes/ownerDocuments.routes");
app.use("/api/owner-documents", userDocumentsRoutes);

//Saved Properties Data: Post, Get and Delete
const savedPropertiesRoutes = require("./routes/savedProperties.routes");
app.use("/api/saved-properties", savedPropertiesRoutes);

//Recent Activities Data: Post and Get
const recentActivitiesRoutes = require("./routes/recentActivities.routes");
app.use("/api/recent-activities", recentActivitiesRoutes);

//Property Reports Data: Post, Get and Put
const propertyReportsRoutes = require("./routes/propertyReports.routes");
app.use("/api/property-reports", propertyReportsRoutes);

//Property Views Data: Post and Get
const propertyViewsRoutes = require("./routes/propertyViews.routes");
app.use("/api/property-views", propertyViewsRoutes);

//Notifications Data: Post, Get and Put
const notificationsRoutes = require("./routes/notifications.routes");
app.use("/api/notifications", notificationsRoutes);

//Amenities Data: Post, Get and Delete
const amenitiesRoutes = require("./routes/amenities.routes");
app.use("/api/amenities", amenitiesRoutes);

//Enquiries Data: Post, Get and Put
const enquiriesRoutes = require("./routes/enquiries.routes");
app.use("/api/enquiries", enquiriesRoutes);




// Health check route
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'RoofScout API',
    version: '1.0.0'
  });
});

// Database health check
app.get('/health/db', async (req, res) => {
  try {
    const db = require('./config/database');
    const result = await db.query('SELECT NOW() as current_time, version() as db_version');

    res.status(200).json({
      status: 'OK',
      database: {
        connected: true,
        current_time: result.rows[0].current_time,
        version: result.rows[0].db_version
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'ERROR',
      database: {
        connected: false,
        error: error.message
      }
    });
  }
});

// Welcome route
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'Welcome to RoofScout API',
    version: '1.0.0',
    endpoints: {
      users: '/api/users',
      health: '/health',
      database_health: '/health/db'
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Start server
const server = app.listen(PORT, async () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🔗 Database check: http://localhost:${PORT}/health/db`);

  // Test database connection immediately on startup
  try {
    const db = require('./config/database');
    await db.query('SELECT NOW()');
    console.log(`✅ Successfully connected to PostgreSQL database: "${process.env.DB_NAME || 'RoofScout'}"`);
  } catch (error) {
    console.error(`❌ Database connection failed on startup: ${error.message}`);
  }
});

// Handle server errors (e.g., Port in use)
server.on('error', (error) => {
  console.error('❌ Server encountered an error:', error.message);
  if (error.code === 'EADDRINUSE') {
    console.error(`💡 PORT ${PORT} is already in use by another running process (likely a previous instance of server.js).`);
    console.error(`👉 You can free the port by running: taskkill /F /IM node.exe (on Windows) or changing PORT in your .env file.`);
    process.exit(1);
  }
});