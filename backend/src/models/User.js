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
