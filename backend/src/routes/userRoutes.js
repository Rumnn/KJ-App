import express from 'express';
import bcrypt from 'bcryptjs';
import mongoose from 'mongoose';
import QuizResult from '../models/QuizResult.js';
import User from '../models/User.js';
import { requireAuth } from '../middleware/authMiddleware.js';

const router = express.Router();

router.use(requireAuth);

function toPlainUser(user) {
  return user?.toObject ? user.toObject() : user;
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

router.get('/profile', async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('-passwordHash');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json(user);
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.put('/profile', async (req, res) => {
  try {
    const { email, password } = req.body;
    const updates = {};

    if (email !== undefined) {
      const normalizedEmail = String(email).trim().toLowerCase();

      if (!normalizedEmail) {
        return res.status(400).json({ message: 'Email cannot be empty' });
      }

      const existingUser = await User.findOne({
        email: normalizedEmail,
        _id: { $ne: req.user.userId },
      });

      if (existingUser) {
        return res.status(409).json({ message: 'Email Already Registered!' });
      }

      updates.email = normalizedEmail;
    }

    if (password !== undefined) {
      if (String(password).length < 6) {
        return res.status(400).json({ message: 'Password must be at least 6 characters long' });
      }

      updates.passwordHash = await bcrypt.hash(String(password), 12);
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ message: 'No fields to update' });
    }

    const updatedUser = await User.findByIdAndUpdate(req.user.userId, updates, {
      new: true,
      runValidators: true,
    }).select('-passwordHash');

    if (!updatedUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json(updatedUser);
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.delete('/profile', async (req, res) => {
  try {
    const userToDelete = await User.findById(req.user.userId).select('-passwordHash');

    if (!userToDelete) {
      return res.status(404).json({ message: 'User not found' });
    }

    await User.findByIdAndDelete(req.user.userId);
    await QuizResult.deleteMany({ userId: req.user.userId });

    res.status(200).json({
      message: 'User deleted successfully',
      user: toPlainUser(userToDelete),
    });
  } catch (error) {
    console.error('Error deleting profile:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.get('/leaderboard', async (req, res) => {
  try {
    const topUsers = await User.find()
      .sort({ points: -1 })
      .limit(10)
      .select('email points xp quizCount');

    res.status(200).json(topUsers);
  } catch (error) {
    console.error('Error fetching leaderboard:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.get('/quizResults', async (req, res) => {
  try {
    const results = await QuizResult.find({ userId: req.user.userId }).sort({ date: -1 });
    res.status(200).json(results);
  } catch (error) {
    console.error('Error fetching quiz results:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.get('/quizResults/:id', async (req, res) => {
  try {
    const result = await QuizResult.findOne({
      _id: req.params.id,
      userId: req.user.userId,
    });

    if (!result) {
      return res.status(404).json({ message: 'Quiz result not found' });
    }

    res.status(200).json(result);
  } catch (error) {
    console.error('Error fetching quiz result:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.post('/quizResults', async (req, res) => {
  try {
    const { level, score, total, date } = req.body;

    if (!level || score === undefined || total === undefined) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const parsedScore = Number(score);
    const parsedTotal = Number(total);

    if (!Number.isFinite(parsedScore) || !Number.isFinite(parsedTotal)) {
      return res.status(400).json({ message: 'Score and total must be numbers' });
    }

    const newResult = new QuizResult({
      userId: req.user.userId,
      level,
      score: parsedScore,
      total: parsedTotal,
      date: date || new Date().toISOString(),
    });

    await newResult.save();
    await recalculateUserStats(req.user.userId);

    res.status(201).json({
      message: 'Quiz Result Saved!',
      result: newResult,
    });
  } catch (error) {
    console.error('Error saving quiz result:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.put('/quizResults/:id', async (req, res) => {
  try {
    const existingResult = await QuizResult.findOne({
      _id: req.params.id,
      userId: req.user.userId,
    });

    if (!existingResult) {
      return res.status(404).json({ message: 'Quiz result not found' });
    }

    const { level, score, total, date } = req.body;

    if (level !== undefined) {
      existingResult.level = level;
    }

    if (score !== undefined) {
      const parsedScore = Number(score);
      if (!Number.isFinite(parsedScore)) {
        return res.status(400).json({ message: 'Score must be a number' });
      }
      existingResult.score = parsedScore;
    }

    if (total !== undefined) {
      const parsedTotal = Number(total);
      if (!Number.isFinite(parsedTotal)) {
        return res.status(400).json({ message: 'Total must be a number' });
      }
      existingResult.total = parsedTotal;
    }

    if (date !== undefined) {
      existingResult.date = date;
    }

    await existingResult.save();
    await recalculateUserStats(req.user.userId);

    res.status(200).json({
      message: 'Quiz Result Updated!',
      result: existingResult,
    });
  } catch (error) {
    console.error('Error updating quiz result:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.delete('/quizResults/:id', async (req, res) => {
  try {
    const deletedResult = await QuizResult.findOneAndDelete({
      _id: req.params.id,
      userId: req.user.userId,
    });

    if (!deletedResult) {
      return res.status(404).json({ message: 'Quiz result not found' });
    }

    await recalculateUserStats(req.user.userId);

    res.status(200).json({
      message: 'Quiz Result Deleted!',
      result: deletedResult,
    });
  } catch (error) {
    console.error('Error deleting quiz result:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

export default router;