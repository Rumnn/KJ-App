import bcrypt from 'bcryptjs';
import dbModule from './src/db.js';
async function seed() {
  const db = await dbModule.getDb();
  const email = 'user@gmail.com';
  const password = 'password';
  const existing = dbModule.dbGet('SELECT id FROM users WHERE email = ?', [email]);
  if (!existing) {
    const passwordHash = await bcrypt.hash(password, 12);
    dbModule.dbRun('INSERT INTO users (email, passwordHash) VALUES (?, ?)', [email, passwordHash]);
    console.log('Seed Data Added!');
  } else {
    console.log('User Already Exists!');
  }
}
seed();