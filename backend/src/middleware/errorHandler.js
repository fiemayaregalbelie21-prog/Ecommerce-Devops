// Central error handler - catches anything thrown/passed via next(err) in routes
// so individual controllers don't need repetitive try/catch -> res.status boilerplate
// for unexpected failures.
function errorHandler(err, req, res, next) {
  console.error('Unhandled error:', err);
  const status = err.status || 500;
  res.status(status).json({
    error: err.message || 'Internal server error',
  });
}

function notFoundHandler(req, res) {
  res.status(404).json({ error: `Route not found: ${req.method} ${req.originalUrl}` });
}

module.exports = { errorHandler, notFoundHandler };
