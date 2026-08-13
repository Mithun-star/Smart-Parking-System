// Global Error Handler Middleware
const errorHandler = (err, req, res, next) => {
  console.error('SERVER ERROR:', err);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'An unexpected server error occurred';

  res.status(statusCode).json({
    success: false,
    message: message,
    // Avoid exposing stack trace in production environments
    error: process.env.NODE_ENV === 'production' ? {} : err.stack
  });
};

module.exports = errorHandler;
