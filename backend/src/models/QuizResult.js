import mongoose from 'mongoose';

const quizResultSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  level: {
    type: String,
    required: true,
  },
  score: {
    type: Number,
    required: true,
  },
  total: {
    type: Number,
    required: true,
  },
  date: {
    type: String, // Storing as string to match existing SQLite implementation structure
    required: true,
  },
});

const QuizResult = mongoose.model('QuizResult', quizResultSchema);
export default QuizResult;
