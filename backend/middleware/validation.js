// Input Validation and Sanitization Middleware

const validateLogin = (req, res, next) => {
  const { username, password } = req.body;
  if (!username || typeof username !== 'string' || username.trim() === '') {
    return res.status(400).json({ success: false, message: 'Username is required' });
  }
  if (!password || typeof password !== 'string' || password.trim() === '') {
    return res.status(400).json({ success: false, message: 'Password is required' });
  }
  
  // Sanitize
  req.body.username = username.trim().toLowerCase();
  next();
};

const validateAttendant = (req, res, next) => {
  const { username, password, email, name, phone, address } = req.body;
  
  if (req.method === 'POST') {
    if (!username || username.trim().length < 3) {
      return res.status(400).json({ success: false, message: 'Username must be at least 3 characters' });
    }
    if (!password || password.length < 6) {
      return res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });
    }
  }

  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ success: false, message: 'Invalid email address' });
  }

  if (!name || name.trim() === '') {
    return res.status(400).json({ success: false, message: 'Name is required' });
  }

  if (!phone || !/^\+?[0-9\s-]{10,15}$/.test(phone.trim())) {
    return res.status(400).json({ success: false, message: 'Invalid phone number (must be 10-15 digits)' });
  }

  next();
};

const validateArea = (req, res, next) => {
  const { name, location, base_price } = req.body;
  
  if (!name || name.trim() === '') {
    return res.status(400).json({ success: false, message: 'Area name is required' });
  }
  if (!location || location.trim() === '') {
    return res.status(400).json({ success: false, message: 'Location is required' });
  }
  if (base_price !== undefined) {
    const price = parseFloat(base_price);
    if (isNaN(price) || price < 0) {
      return res.status(400).json({ success: false, message: 'Base price must be a non-negative number' });
    }
    req.body.base_price = price;
  }
  
  next();
};

const validateVehicle = (req, res, next) => {
  const { license_plate, type } = req.body;
  
  if (!license_plate || !/^[A-Z0-9\s-]{4,15}$/i.test(license_plate.trim())) {
    return res.status(400).json({ success: false, message: 'Invalid license plate format' });
  }
  
  const allowedTypes = ['Two-Wheeler', 'Four-Wheeler', 'Heavy-Vehicle'];
  if (!type || !allowedTypes.includes(type)) {
    return res.status(400).json({ success: false, message: `Type must be one of: ${allowedTypes.join(', ')}` });
  }

  req.body.license_plate = license_plate.trim().toUpperCase();
  next();
};

const validateSlot = (req, res, next) => {
  const { area_id, slot_number, type, status } = req.body;

  if (req.method === 'POST' && (!area_id || isNaN(parseInt(area_id)))) {
    return res.status(400).json({ success: false, message: 'Valid Area ID is required' });
  }

  if (slot_number && slot_number.trim() === '') {
    return res.status(400).json({ success: false, message: 'Slot number is required' });
  }

  if (type) {
    const allowedTypes = ['Two-Wheeler', 'Four-Wheeler', 'Heavy-Vehicle'];
    if (!allowedTypes.includes(type)) {
      return res.status(400).json({ success: false, message: 'Invalid slot vehicle type' });
    }
  }

  if (status) {
    const allowedStatuses = ['Available', 'Occupied', 'Maintenance'];
    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid slot status' });
    }
  }

  next();
};

const validateEntry = (req, res, next) => {
  const { license_plate, slot_id, type } = req.body;

  if (!license_plate || license_plate.trim() === '') {
    return res.status(400).json({ success: false, message: 'License plate is required' });
  }

  if (!slot_id || isNaN(parseInt(slot_id))) {
    return res.status(400).json({ success: false, message: 'Valid Slot ID is required' });
  }

  const allowedTypes = ['Two-Wheeler', 'Four-Wheeler', 'Heavy-Vehicle'];
  if (!type || !allowedTypes.includes(type)) {
    return res.status(400).json({ success: false, message: 'Invalid vehicle type' });
  }

  req.body.license_plate = license_plate.trim().toUpperCase();
  next();
};

const validatePayment = (req, res, next) => {
  const { record_id, amount, payment_method } = req.body;

  if (!record_id || isNaN(parseInt(record_id))) {
    return res.status(400).json({ success: false, message: 'Valid Record ID is required' });
  }

  if (amount === undefined || isNaN(parseFloat(amount)) || parseFloat(amount) < 0) {
    return res.status(400).json({ success: false, message: 'Valid payment amount is required' });
  }

  const allowedMethods = ['Cash', 'UPI', 'Card'];
  if (!payment_method || !allowedMethods.includes(payment_method)) {
    return res.status(400).json({ success: false, message: 'Invalid payment method' });
  }

  next();
};

module.exports = {
  validateLogin,
  validateAttendant,
  validateArea,
  validateVehicle,
  validateSlot,
  validateEntry,
  validatePayment
};
