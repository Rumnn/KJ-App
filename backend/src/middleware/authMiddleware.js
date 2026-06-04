import jwt from 'jsonwebtoken';
import User from '../models/User.js';

const JWT_SECRET = process.env.JWT_SECRET || 'KJ';

export const requireAuth = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Invalid Or Expired Token!' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // Contains userId and email
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid Or Expired Token!' });
  }
};

export const requireAdmin = async (req, res, next) => {
  try {
    const user = await User.findById(req.user?.userId).select('role status');
    if (!user || user.status === 'blocked' || user.role !== 'admin') {
      return res.status(403).json({ message: 'Admin access required' });
    }
    next();
  } catch (error) {
    console.error('Admin auth error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
