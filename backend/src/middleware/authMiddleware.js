import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'KJ';

export const requireAuth = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Invalid Or Expired Token!' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // Contains userId and email
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid Or Expired Token!' });
  }
};
