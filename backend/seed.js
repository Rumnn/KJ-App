import bcrypt from 'bcryptjs';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from './src/models/User.js';

dotenv.config();

async function seed() {
  const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/kj_db';
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;

  if (!email || !password) {
    console.log('Missing ADMIN_EMAIL or ADMIN_PASSWORD in backend/.env.');
    console.log('Add them, then run: npm run seed');
    return;
  }

  if (password.length < 6) {
    throw new Error('ADMIN_PASSWORD must be at least 6 characters long.');
  }

  await mongoose.connect(mongoURI);
  const normalizedEmail = email.trim().toLowerCase();
  const passwordHash = await bcrypt.hash(password, 12);

  const user = await User.findOneAndUpdate(
    { email: normalizedEmail },
    {
      $set: {
        email: normalizedEmail,
        passwordHash,
        role: 'admin',
        status: 'active',
      },
      $setOnInsert: { createdAt: new Date() },
    },
    { returnDocument: 'after', upsert: true },
  ).select('email role status');

  console.log(`Admin account ready: ${user.email} (${user.role}, ${user.status})`);
  await mongoose.disconnect();
}

seed().catch(async (error) => {
  console.error('Seed failed:', error);
  await mongoose.disconnect();
  process.exit(1);
});
