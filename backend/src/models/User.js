import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
  },
  passwordHash: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user',
  },
  status: {
    type: String,
    enum: ['active', 'blocked'],
    default: 'active',
  },
  lastLoginAt: {
    type: Date,
  },
  xp: {
    type: Number,
    default: 0,
  },
  points: {
    type: Number,
    default: 0,
  },
  quizCount: {
    type: Number,
    default: 0,
  },
});

const User = mongoose.model('User', userSchema);
export default User;
