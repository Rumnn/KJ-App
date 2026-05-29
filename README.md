# KJ — Ứng dụng học tiếng Nhật (JLPT)

Ứng dụng di động hỗ trợ học tiếng Nhật theo chuẩn JLPT, được xây dựng bằng **Flutter** (frontend) và **Node.js + Express + MongoDB** (backend).

## Tính năng chính

- 📖 Tra cứu & học Kanji (bao gồm thứ tự nét viết)
- 📝 Từ vựng JLPT (N5 → N1)
- 📗 Ngữ pháp theo cấp độ
- 🃏 Flashcard ôn tập
- ✍️ Luyện viết Kanji (nhận dạng chữ viết tay bằng ML Kit)
- 🧠 Quiz kiểm tra kiến thức
- 🤖 Chat AI giải đáp thắc mắc (Gemini / Ollama)
- 🏆 Bảng xếp hạng (Leaderboard)
- 📊 Dashboard thống kê tiến độ học tập
- 🔐 Đăng ký / Đăng nhập tài khoản

---

## Yêu cầu hệ thống

### Công cụ cần cài đặt

| Công cụ                | Phiên bản tối thiểu  | Tải về                                                                               |
| ---------------------- | -------------------- | ------------------------------------------------------------------------------------ |
| Flutter SDK            | 3.x (Dart SDK ≥ 3.5) | [flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)      |
| Node.js                | 18+                  | [nodejs.org](https://nodejs.org/)                                                    |
| MongoDB                | 6+                   | [mongodb.com/try/download/community](https://www.mongodb.com/try/download/community) |
| Android Studio / Xcode | Mới nhất             | Để chạy trên emulator hoặc thiết bị thật                                             |
| Git                    | Bất kỳ               | [git-scm.com](https://git-scm.com/)                                                  |

### Tùy chọn (nếu dùng AI local)

| Công cụ | Ghi chú                                                                               |
| ------- | ------------------------------------------------------------------------------------- |
| Ollama  | Chạy LLM local (mặc định model `qwen3:4b`). Tải tại [ollama.com](https://ollama.com/) |

---

## Cài đặt

### 1. Clone dự án

```bash
git clone https://github.com/<your-username>/KJ-main.git
cd KJ-main
```

### 2. Cài đặt Backend

```bash
# Di chuyển vào thư mục backend
cd backend

# Cài đặt dependencies
npm install
```

#### Cấu hình biến môi trường

Chỉnh sửa file `backend/.env` theo nhu cầu:

```env
# MongoDB — đổi URI nếu MongoDB chạy ở địa chỉ khác
MONGO_URI=mongodb://localhost:27017/kj_db

# JWT Secret — nên đổi sang chuỗi bí mật riêng
JWT_SECRET=KJ

# === Chọn 1 trong 2 AI Provider bên dưới ===

# --- Lựa chọn 1: Google Gemini (online, miễn phí) ---
# Lấy API key tại: https://aistudio.google.com/app/apikey
GEMINI_API_KEY=<your-gemini-api-key>

# --- Lựa chọn 2: Ollama (offline, chạy local) ---
AI_PROVIDER=ollama
OLLAMA_MODEL=qwen3:4b
OLLAMA_URL=http://localhost:11434
OLLAMA_TIMEOUT_MS=30000
```

> **Lưu ý:** Nếu dùng Ollama, hãy cài đặt và pull model trước:
>
> ```bash
> ollama pull qwen3:4b
> ```

### 3. Khởi động MongoDB

Đảm bảo MongoDB đang chạy trước khi khởi động backend:

```bash
# Windows (nếu cài MongoDB làm service, nó tự chạy)
# Hoặc chạy thủ công:
mongod

# macOS / Linux
sudo systemctl start mongod
# hoặc
brew services start mongodb-community
```

### 4. Cài đặt Flutter Frontend

```bash
# Quay lại thư mục gốc
cd ..

# Kiểm tra môi trường Flutter
flutter doctor

# Cài đặt dependencies
flutter pub get
```

#### Cấu hình kết nối Backend

Chỉnh sửa file `lib/appConfig.dart` — thay `_localIp` bằng **địa chỉ IP LAN** của máy đang chạy backend:

```dart
static const String _localIp = '192.168.x.x'; // IP LAN của máy tính
```

> **Cách tìm IP LAN:**
>
> - **Windows:** Mở CMD → gõ `ipconfig` → tìm `IPv4 Address`
> - **macOS / Linux:** Mở Terminal → gõ `ifconfig` hoặc `ip addr`
>
> **Lưu ý:** Nếu chạy trên **Web** hoặc **Emulator trên cùng máy**, không cần đổi IP — app tự dùng `localhost`.

---

## Chạy ứng dụng

### Bước 1 — Khởi động Backend

```bash
cd backend

# Chế độ development (tự restart khi sửa code)
npm run dev

# Hoặc chạy bình thường
npm start
```

Nếu thành công, terminal hiển thị:

```
Connected to MongoDB at mongodb://localhost:27017/kj_db
Server listening at http://0.0.0.0:3000
```

### Bước 2 — Chạy Flutter App

Mở terminal **mới** (giữ backend chạy ở terminal cũ):

```bash
# Chạy trên Chrome (Web)
flutter run -d chrome

# Chạy trên Android Emulator
flutter run -d emulator-5554

# Chạy trên thiết bị Android thật (kết nối USB)
flutter run

# Chạy trên iOS Simulator (macOS)
flutter run -d iPhone

# Xem danh sách thiết bị khả dụng
flutter devices
```

---

## Cấu trúc dự án

```
KJ-main/
├── backend/                  # Backend API (Node.js + Express)
│   ├── src/
│   │   ├── server.js         # Entry point
│   │   ├── routes/           # API routes (auth, user, ai)
│   │   ├── models/           # Mongoose models
│   │   └── middleware/       # Middleware (auth, ...)
│   ├── .env                  # Biến môi trường
│   └── package.json
│
├── lib/                      # Flutter source code
│   ├── main.dart             # Entry point
│   ├── app.dart              # MaterialApp / Theme
│   ├── appConfig.dart        # Cấu hình API URL
│   ├── router.dart           # Định tuyến (GoRouter)
│   ├── screens/              # Các màn hình
│   │   ├── auth/             #   Đăng nhập / Đăng ký
│   │   ├── home/             #   Trang chủ
│   │   ├── kanji/            #   Tra cứu Kanji
│   │   ├── vocab/            #   Từ vựng
│   │   ├── grammar/          #   Ngữ pháp
│   │   ├── flashcard/        #   Flashcard
│   │   ├── quiz/             #   Làm quiz
│   │   ├── writing/          #   Luyện viết
│   │   ├── chat/             #   Chat AI
│   │   ├── dashboard/        #   Thống kê
│   │   ├── leaderboard/      #   Bảng xếp hạng
│   │   └── settings/         #   Cài đặt
│   ├── models/               # Data models
│   ├── providers/            # Riverpod providers
│   ├── services/             # API & local services
│   └── widgets/              # Reusable widgets
│
├── assets/                   # Dữ liệu tĩnh
│   ├── kanjiData.json        # Dữ liệu Kanji
│   ├── jlpt_vocab.csv        # Dữ liệu từ vựng
│   └── grammar/              # Dữ liệu ngữ pháp
│
├── pubspec.yaml              # Flutter dependencies
└── README.md
```

---

## Các API Endpoint chính

| Method   | Endpoint                | Mô tả                         |
| -------- | ----------------------- | ----------------------------- |
| `POST`   | `/auth/register`        | Đăng ký tài khoản             |
| `POST`   | `/auth/login`           | Đăng nhập                     |
| `GET`    | `/user/profile`         | Lấy thông tin user            |
| `PUT`    | `/user/profile`         | Cập nhật thông tin user       |
| `DELETE` | `/user/profile`         | Xoá tài khoản hiện tại        |
| `GET`    | `/user/quizResults`     | Lấy danh sách kết quả quiz    |
| `GET`    | `/user/quizResults/:id` | Lấy chi tiết một kết quả quiz |
| `POST`   | `/user/quizResults`     | Tạo kết quả quiz mới          |
| `PUT`    | `/user/quizResults/:id` | Cập nhật kết quả quiz         |
| `DELETE` | `/user/quizResults/:id` | Xoá kết quả quiz              |
| `POST`   | `/ai/chat`              | Chat với AI                   |
| `GET`    | `/health`               | Kiểm tra trạng thái server    |

---

## Xử lý lỗi thường gặp

### ❌ `Failed to connect to MongoDB`

→ Kiểm tra MongoDB đã chạy chưa (`mongod` hoặc kiểm tra service).

### ❌ `Connection refused` trên thiết bị thật

→ Kiểm tra:

1. Điện thoại và máy tính cùng mạng WiFi
2. IP trong `appConfig.dart` đúng với IP LAN của máy chạy backend
3. Firewall không chặn port `3000`

### ❌ `flutter doctor` báo thiếu license

→ Chạy: `flutter doctor --android-licenses`

### ❌ AI Chat không phản hồi

→ Kiểm tra:

- Nếu dùng **Gemini**: API key hợp lệ trong `.env`
- Nếu dùng **Ollama**: Ollama đang chạy (`ollama serve`) và đã pull model

---

## Tech Stack

| Thành phần | Công nghệ                                   |
| ---------- | ------------------------------------------- |
| Frontend   | Flutter 3.x, Dart, Riverpod, GoRouter, Hive |
| Backend    | Node.js, Express 5, Mongoose                |
| Database   | MongoDB                                     |
| AI         | Google Gemini API / Ollama (local LLM)      |
| ML         | Google ML Kit (nhận dạng chữ viết tay)      |
