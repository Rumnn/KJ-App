import express from 'express';
import QuizResult from '../models/QuizResult.js';
import User from '../models/User.js';
import { requireAuth } from '../middleware/authMiddleware.js';

const router = express.Router();

// Apply requireAuth middleware to all routes in this router
router.use(requireAuth);

router.get('/quizResults', async (req, res) => {
  try {
    const results = await QuizResult.find({ userId: req.user.userId }).sort({ date: -1 });
    res.status(200).json(results);
  } catch (error) {
    console.error('Error fetching quiz results:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.get('/profile', async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('-passwordHash');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.get('/leaderboard', async (req, res) => {
  try {
    const topUsers = await User.find().sort({ points: -1 }).limit(10).select('email points xp quizCount');
    res.status(200).json(topUsers);
  } catch (error) {
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.post('/quizResults', async (req, res) => {
  try {
    const { level, score, total, date } = req.body;

    if (!level || score === undefined || total === undefined || !date) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const newResult = new QuizResult({
      userId: req.user.userId,
      level,
      score,
      total,
      date,
    });

    await newResult.save();

    // Update User XP, Points, and QuizCount
    const xpGain = score * 10;
    const pointsGain = score * 5;

    await User.findByIdAndUpdate(req.user.userId, {
      $inc: { xp: xpGain, points: pointsGain, quizCount: 1 }
    });

    res.status(201).json({ 
      message: 'Quiz Result Saved!',
      xpGain,
      pointsGain
    });
  } catch (error) {
    console.error('Error saving quiz result:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

export default router;