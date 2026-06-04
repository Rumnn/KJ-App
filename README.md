# KJ - Ứng dụng học tiếng Nhật JLPT

Ứng dụng học tiếng Nhật theo chuẩn JLPT, xây dựng bằng **Flutter** cho frontend và **Node.js + Express + MongoDB** cho backend.

## Tính Năng Chính

- Tra cứu và học Kanji JLPT, bao gồm thứ tự nét viết.
- Từ vựng JLPT từ N5 đến N1.
- Ngữ pháp theo cấp độ N5, N4, N3.
- Flashcard ôn tập Kanji, từ vựng và ngữ pháp.
- Luyện viết Kanji với nhận dạng chữ viết tay bằng ML Kit.
- Quiz kiểm tra kiến thức và lưu kết quả học tập.
- Chat AI giải đáp thắc mắc bằng Gemini hoặc Ollama local.
- Bảng xếp hạng người học.
- Dashboard thống kê streak, quiz và tiến độ học tập.
- Trang Lessons dạng **Horizontal Carousel Block**, thân thiện hơn với mobile.
- Chuyển đổi ngôn ngữ giao diện **English / Tiếng Việt** trong phần cài đặt.
- Trang quản trị Admin để xem thống kê hệ thống, quản lý user, role, trạng thái tài khoản và kết quả quiz.
- Đăng ký, đăng nhập, JWT auth và phân quyền user/admin.

## Yêu Cầu Hệ Thống

| Công cụ | Phiên bản tối thiểu | Ghi chú |
| --- | --- | --- |
| Flutter SDK | 3.x, Dart SDK >= 3.5 | Frontend |
| Node.js | 18+ | Backend |
| MongoDB | 6+ | Database |
| Android Studio / Xcode | Mới nhất | Chạy emulator hoặc thiết bị thật |
| Git | Bất kỳ | Clone source |
| Ollama | Tùy chọn | Chạy AI local |

## Cài Đặt

### 1. Clone Dự Án

```bash
git clone https://github.com/<your-username>/KJ-main.git
cd KJ-main
```

### 2. Cài Đặt Backend

```bash
cd backend
npm install
```

Tạo hoặc chỉnh sửa `backend/.env`:

```env
# MongoDB
MONGO_URI=mongodb://localhost:27017/kj_db

# JWT
JWT_SECRET=KJ

# Admin seed account
ADMIN_EMAIL=admin@gmail.com
ADMIN_PASSWORD=admin123

# Google Gemini
GEMINI_API_KEY=<your-gemini-api-key>

# Ollama local AI
AI_PROVIDER=ollama
OLLAMA_MODEL=llama3.2:3b
OLLAMA_URL=http://localhost:11434
OLLAMA_TIMEOUT_MS=60000
OLLAMA_NUM_PREDICT=1200
OLLAMA_TEMPERATURE=0.3
OLLAMA_KEEP_ALIVE=30m
```

Nếu dùng Ollama, pull model trước:

```bash
ollama pull llama3.2:3b
```

### 3. Khởi Động MongoDB

Đảm bảo MongoDB đang chạy trước khi chạy backend:

```bash
# Windows, nếu MongoDB không chạy như service
mongod

# macOS / Linux
sudo systemctl start mongod
```

### 4. Seed Tài Khoản Admin

Sau khi MongoDB chạy và `.env` có `ADMIN_EMAIL` / `ADMIN_PASSWORD`, chạy:

```bash
cd backend
npm run seed
```

Nếu thành công:

```text
Admin account ready: admin@gmail.com (admin, active)
```

Tài khoản admin đăng nhập như user bình thường. Trong app, vào **Profile Settings** để mở **Admin Panel**.

### 5. Cài Đặt Flutter Frontend

```bash
cd ..
flutter doctor
flutter pub get
```

Nếu chạy trên thiết bị thật, chỉnh IP backend trong `lib/appConfig.dart`:

```dart
static const String _localIp = '192.168.x.x';
```

Nếu chạy Web hoặc emulator cùng máy, app tự dùng `localhost`.

## Chạy Ứng Dụng

### Backend

```bash
cd backend
npm run dev
```

Hoặc:

```bash
npm start
```

Backend mặc định chạy tại:

```text
http://0.0.0.0:3000
```

### Flutter

Mở terminal mới tại thư mục gốc:

```bash
# Web
flutter run -d chrome

# Android emulator
flutter run -d emulator-5554

# Thiết bị thật
flutter run

# Xem danh sách thiết bị
flutter devices
```

## Cấu Trúc Dự Án

```text
KJ-main/
├── backend/
│   ├── src/
│   │   ├── server.js              # Entry point backend
│   │   ├── routes/                # auth, user, admin, ai
│   │   ├── models/                # Mongoose models
│   │   └── middleware/            # auth/admin middleware
│   ├── seed.js                    # Tạo/cập nhật tài khoản admin
│   ├── .env                       # Biến môi trường
│   └── package.json
│
├── lib/
│   ├── main.dart
│   ├── app.dart                   # MaterialApp, theme, localization
│   ├── appConfig.dart             # API URL config
│   ├── router.dart                # GoRouter routes + admin guard
│   ├── l10n/                      # Bản dịch EN/VI
│   ├── screens/
│   │   ├── admin/                 # Admin Panel
│   │   ├── auth/                  # Login / Signup
│   │   ├── home/                  # Home + Lessons carousel
│   │   ├── kanji/
│   │   ├── vocab/
│   │   ├── grammar/
│   │   ├── flashcard/
│   │   ├── quiz/
│   │   ├── writing/
│   │   ├── chat/
│   │   ├── dashboard/
│   │   ├── leaderboard/
│   │   └── settings/
│   ├── models/
│   ├── providers/
│   ├── services/
│   └── widgets/
│
├── assets/
│   ├── kanjiData.json
│   ├── jlpt_vocab.csv
│   └── grammar/
│
├── l10n.yaml
├── pubspec.yaml
└── README.md
```

## API Endpoint Chính

### Auth

| Method | Endpoint | Mô tả |
| --- | --- | --- |
| `POST` | `/auth/register` | Đăng ký tài khoản |
| `POST` | `/auth/login` | Đăng nhập, trả JWT kèm role/status |

### User

| Method | Endpoint | Mô tả |
| --- | --- | --- |
| `GET` | `/user/profile` | Lấy thông tin user hiện tại |
| `PUT` | `/user/profile` | Cập nhật email/password |
| `DELETE` | `/user/profile` | Xóa tài khoản hiện tại |
| `GET` | `/user/leaderboard` | Lấy bảng xếp hạng |
| `GET` | `/user/quizResults` | Lấy kết quả quiz của user |
| `GET` | `/user/quizResults/:id` | Lấy chi tiết một kết quả quiz |
| `POST` | `/user/quizResults` | Tạo kết quả quiz |
| `PUT` | `/user/quizResults/:id` | Cập nhật kết quả quiz |
| `DELETE` | `/user/quizResults/:id` | Xóa kết quả quiz |

### Admin

Các endpoint admin yêu cầu JWT của user có `role = admin`.

| Method | Endpoint | Mô tả |
| --- | --- | --- |
| `GET` | `/admin/summary` | Thống kê tổng quan hệ thống |
| `GET` | `/admin/users` | Danh sách user, hỗ trợ search/filter/page |
| `GET` | `/admin/users/:id` | Chi tiết user và quiz gần đây |
| `PATCH` | `/admin/users/:id` | Cập nhật email, role, status |
| `DELETE` | `/admin/users/:id` | Xóa user và quiz results liên quan |
| `GET` | `/admin/quiz-results` | Danh sách kết quả quiz toàn hệ thống |
| `DELETE` | `/admin/quiz-results/:id` | Xóa quiz result và tính lại điểm user |

### AI Và Health

| Method | Endpoint | Mô tả |
| --- | --- | --- |
| `POST` | `/ai/chat` | Chat với AI |
| `GET` | `/health` | Kiểm tra trạng thái server |

## Tính Năng Mới Đã Bổ Sung

### Admin Panel

- User model có `role`, `status`, `lastLoginAt`.
- Admin có thể xem thống kê tổng quan, danh sách user và kết quả quiz.
- Admin có thể đổi role, khóa/mở khóa user và xóa user.
- Admin có thể xóa quiz result sai, hệ thống tự tính lại XP/points/quizCount.
- User bị `blocked` không thể đăng nhập.

### Lessons Mobile Carousel

- Lessons được tổ chức thành các block ngang: Kanji, Ngữ pháp, Từ vựng, Bộ thủ.
- Mỗi block có carousel card vuốt ngang, phù hợp màn hình mobile.
- Các route học cũ được giữ nguyên.

### Đa Ngôn Ngữ EN/VI

- Dùng Flutter localization với `l10n.yaml` và ARB files.
- Người dùng đổi ngôn ngữ trong Settings.
- UI chính, Home, Lessons, Settings, Auth, Dashboard, Leaderboard và Admin được dịch theo ngôn ngữ đã chọn.
- Nội dung bài học trong assets được giữ nguyên.

## Kiểm Tra

Các lệnh đã dùng để kiểm tra:

```bash
flutter pub get
flutter analyze
flutter build web
```

Backend có thể kiểm tra nhanh cú pháp bằng:

```bash
node --check src/server.js
node --check src/routes/adminRoutes.js
node --check seed.js
```

## Xử Lý Lỗi Thường Gặp

### `Failed to connect to MongoDB`

Kiểm tra MongoDB đã chạy chưa:

```bash
mongod
```

Hoặc kiểm tra service MongoDB trên hệ điều hành của bạn.

### `Connection refused` trên thiết bị thật

Kiểm tra:

1. Điện thoại và máy tính cùng mạng Wi-Fi.
2. IP trong `lib/appConfig.dart` đúng với IP LAN của máy chạy backend.
3. Firewall không chặn port `3000`.

### Không đăng nhập được admin

Kiểm tra:

1. MongoDB đang chạy.
2. `.env` có `ADMIN_EMAIL` và `ADMIN_PASSWORD`.
3. Đã chạy:

```bash
cd backend
npm run seed
```

4. User admin trong database có `role = admin` và `status = active`.

### AI Chat không phản hồi

Nếu dùng Gemini, kiểm tra `GEMINI_API_KEY`.

Nếu dùng Ollama:

```bash
ollama list
ollama ps
ollama pull llama3.2:3b
```

Sau khi đổi `.env`, restart backend:

```bash
cd backend
npm run dev
```

## Tech Stack

| Thành phần | Công nghệ |
| --- | --- |
| Frontend | Flutter 3.x, Dart, Riverpod, GoRouter, Hive, Flutter Localizations |
| Backend | Node.js, Express 5, Mongoose |
| Database | MongoDB |
| AI | Google Gemini API / Ollama local |
| ML | Google ML Kit Digital Ink Recognition |
