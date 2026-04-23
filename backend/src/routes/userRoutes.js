import express from 'express';
import QuizResult from '../models/QuizResult.js';
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
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/quizResults', async (req, res) => {
  try {
    const { level, score, total, date } = req.body;

    if (!level || score === undefined || total === undefined || !date) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const newResult = new QuizResult({
      userId: req.user.userId,
      level,
      score,
      total,
      date,
    });

    await newResult.save();
    res.status(201).json({ message: 'Quiz Result Saved!' });
  } catch (error) {
    console.error('Error saving quiz result:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

export default router;