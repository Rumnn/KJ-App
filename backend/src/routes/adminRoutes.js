import express from 'express';
import mongoose from 'mongoose';
import QuizResult from '../models/QuizResult.js';
import User from '../models/User.js';
import { requireAdmin, requireAuth } from '../middleware/authMiddleware.js';

const router = express.Router();

router.use(requireAuth, requireAdmin);

const userSelect = '-passwordHash';

function pagination(query) {
  const page = Math.max(Number.parseInt(query.page, 10) || 1, 1);
  const limit = Math.min(Math.max(Number.parseInt(query.limit, 10) || 20, 1), 100);
  return { page, limit, skip: (page - 1) * limit };
}

async function recalculateUserStats(userId) {
  const [summary] = await QuizResult.aggregate([
    { $match: { userId: new mongoose.Types.ObjectId(userId) } },
    {
      $group: {
        _id: null,
        totalScore: { $sum: '$score' },
        quizCount: { $sum: 1 },
      },
    },
  ]);

  const totalScore = summary?.totalScore ?? 0;
  const quizCount = summary?.quizCount ?? 0;
  await User.findByIdAndUpdate(userId, {
    xp: totalScore * 10,
    points: totalScore * 5,
    quizCount,
  });
}

router.get('/summary', async (_req, res) => {
  try {
    const [userStats] = await User.aggregate([
      {
        $group: {
          _id: null,
          totalUsers: { $sum: 1 },
          activeUsers: { $sum: { $cond: [{ $eq: ['$status', 'active'] }, 1, 0] } },
          blockedUsers: { $sum: { $cond: [{ $eq: ['$status', 'blocked'] }, 1, 0] } },
          totalXp: { $sum: '$xp' },
          totalPoints: { $sum: '$points' },
        },
      },
    ]);
    const totalQuizResults = await QuizResult.countDocuments();
    const topUsers = await User.find()
      .sort({ points: -1 })
      .limit(5)
      .select('email role status xp points quizCount lastLoginAt createdAt');

    res.status(200).json({
      totalUsers: userStats?.totalUsers ?? 0,
      activeUsers: userStats?.activeUsers ?? 0,
      blockedUsers: userStats?.blockedUsers ?? 0,
      totalXp: userStats?.totalXp ?? 0,
      totalPoints: userStats?.totalPoints ?? 0,
      totalQuizResults,
      topUsers,
    });
  } catch (error) {
    console.error('Admin summary error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.get('/users', async (req, res) => {
  try {
    const { page, limit, skip } = pagination(req.query);
    const filter = {};
    if (req.query.search) filter.email = { $regex: String(req.query.search), $options: 'i' };
    if (['user', 'admin'].includes(req.query.role)) filter.role = req.query.role;
    if (['active', 'blocked'].includes(req.query.status)) filter.status = req.query.status;

    const [items, total] = await Promise.all([
      User.find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .select(userSelect),
      User.countDocuments(filter),
    ]);

    res.status(200).json({ items, page, limit, total, pages: Math.ceil(total / limit) });
  } catch (error) {
    console.error('Admin users error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.get('/users/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select(userSelect);
    if (!user) return res.status(404).json({ message: 'User not found' });
    const quizResults = await QuizResult.find({ userId: user._id }).sort({ date: -1 }).limit(20);
    res.status(200).json({ user, quizResults });
  } catch (error) {
    console.error('Admin user detail error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.patch('/users/:id', async (req, res) => {
  try {
    const updates = {};
    const { email, role, status } = req.body;

    if (email !== undefined) {
      const normalizedEmail = String(email).trim().toLowerCase();
      if (!normalizedEmail) return res.status(400).json({ message: 'Email cannot be empty' });
      const existing = await User.findOne({ email: normalizedEmail, _id: { $ne: req.params.id } });
      if (existing) return res.status(409).json({ message: 'Email Already Registered!' });
      updates.email = normalizedEmail;
    }
    if (role !== undefined) {
      if (!['user', 'admin'].includes(role)) return res.status(400).json({ message: 'Invalid role' });
      updates.role = role;
    }
    if (status !== undefined) {
      if (!['active', 'blocked'].includes(status)) return res.status(400).json({ message: 'Invalid status' });
      updates.status = status;
    }

    const user = await User.findByIdAndUpdate(req.params.id, updates, {
      new: true,
      runValidators: true,
    }).select(userSelect);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.status(200).json(user);
  } catch (error) {
    console.error('Admin update user error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.delete('/users/:id', async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id).select(userSelect);
    if (!user) return res.status(404).json({ message: 'User not found' });
    await QuizResult.deleteMany({ userId: req.params.id });
    res.status(200).json({ message: 'User deleted successfully', user });
  } catch (error) {
    console.error('Admin delete user error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.get('/quiz-results', async (req, res) => {
  try {
    const { page, limit, skip } = pagination(req.query);
    const filter = {};
    if (req.query.userId) filter.userId = req.query.userId;
    if (req.query.level) filter.level = req.query.level;

    const [items, total] = await Promise.all([
      QuizResult.find(filter)
        .sort({ date: -1 })
        .skip(skip)
        .limit(limit)
        .populate('userId', 'email role status'),
      QuizResult.countDocuments(filter),
    ]);

    res.status(200).json({ items, page, limit, total, pages: Math.ceil(total / limit) });
  } catch (error) {
    console.error('Admin quiz results error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.delete('/quiz-results/:id', async (req, res) => {
  try {
    const result = await QuizResult.findByIdAndDelete(req.params.id);
    if (!result) return res.status(404).json({ message: 'Quiz result not found' });
    await recalculateUserStats(result.userId);
    res.status(200).json({ message: 'Quiz result deleted successfully', result });
  } catch (error) {
    console.error('Admin delete quiz result error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

export default router;
