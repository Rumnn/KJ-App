import express from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { requireAuth } from '../middleware/authMiddleware.js';

const router = express.Router();

const SENSEI_SYSTEM_PROMPT = `Bạn là một Japanese Sensei chuyên nghiệp, có trình độ tiếng Nhật trên N1 và am hiểu sâu về ngôn ngữ học, Kanji, từ vựng, Keigo, Sonkeigo và Kenjougo.

Vai trò của bạn:
Bạn không chỉ dịch nghĩa từ vựng, mà phải giải thích như một giáo viên tiếng Nhật, giúp người học hiểu được sắc thái, ngữ cảnh sử dụng và cách dùng tự nhiên của từ.

Khi người dùng hỏi về một hoặc nhiều từ/Kanji tiếng Nhật, hãy trả lời theo cấu trúc sau (khi phù hợp):

1. Tổng quan
- Nêu cách đọc, nghĩa chính và âm Hán Việt nếu có.
- Giải thích nghĩa gốc hoặc ý nghĩa Kanji nếu cần.

2. Bảng so sánh (nếu câu hỏi có nhiều từ cần so sánh)
So sánh theo: Nghĩa chính, Sắc thái, Mức độ trang trọng, Ngữ cảnh, Đối tượng, Văn nói/Văn viết.

3. Phân tích chi tiết
- Điểm khác biệt lớn nhất.
- Lỗi thường gặp của người học.
- Gợi ý từ phù hợp cho từng tình huống.

4. Ví dụ thực tế
Với mỗi từ, ít nhất 2 ví dụ (đời thường + công việc/trang trọng):
- Câu tiếng Nhật
- Phiên âm romaji
- Nghĩa tiếng Việt
- Giải thích sắc thái

5. Kết luận dễ nhớ
- Tóm tắt ngắn gọn.
- Mẹo ghi nhớ đơn giản.

Phong cách trả lời:
- Dùng tiếng Việt.
- Trình bày bằng Markdown (sử dụng **bold**, *italic*, bảng, bullet points).
- Giọng văn thân thiện, khích lệ.
- Ưu tiên ví dụ thực tế.
- Khi người dùng chào hỏi hoặc hỏi câu thông thường, hãy trả lời tự nhiên mà không cần tuân thủ cứng nhắc cấu trúc trên.
- Thỉnh thoảng thêm emoji phù hợp để tạo cảm giác thân thiện.`;

router.post('/chat', requireAuth, async (req, res) => {
  try {
    const { message, history } = req.body;

    if (!message || typeof message !== 'string' || message.trim() === '') {
      return res.status(400).json({ message: 'Message is required' });
    }

    const apiKey = process.env.GEMINI_API_KEY;
    console.log('[AI] Using API key:', apiKey ? `${apiKey.substring(0, 10)}...` : 'NOT SET');
    if (!apiKey || apiKey === 'your_gemini_api_key_here') {
      return res.status(500).json({ message: 'AI service not configured. Please add GEMINI_API_KEY to .env' });
    }

    const genAI = new GoogleGenerativeAI(apiKey);

    // Try models in order of preference
    const modelNames = ['gemini-2.0-flash-lite', 'gemini-2.0-flash'];
    let reply = null;
    let lastError = null;

    for (const modelName of modelNames) {
      try {
        const model = genAI.getGenerativeModel({
          model: modelName,
          systemInstruction: SENSEI_SYSTEM_PROMPT,
        });

        const chatHistory = (history || []).map(msg => ({
          role: msg.role === 'user' ? 'user' : 'model',
          parts: [{ text: msg.content }],
        }));

        const chat = model.startChat({ history: chatHistory });
        const result = await chat.sendMessage(message.trim());
        reply = result.response.text();
        break; // success
      } catch (err) {
        lastError = err;
        if (!err.message?.includes('429') && !err.message?.includes('quota')) {
          throw err; // Non-quota error, don't retry
        }
        console.warn(`Model ${modelName} quota exceeded, trying next...`);
      }
    }

    if (!reply) throw lastError;
    res.status(200).json({ reply });
  } catch (error) {
    console.error('AI Chat error:', error?.message || error);

    const msg = error?.message || '';
    if (msg.includes('API_KEY') || msg.includes('API key')) {
      return res.status(500).json({ message: '❌ API key không hợp lệ. Vui lòng kiểm tra GEMINI_API_KEY trong .env' });
    }
    if (msg.includes('429') || msg.includes('quota') || msg.includes('RESOURCE_EXHAUSTED')) {
      return res.status(429).json({ message: '⏳ Sensei đang nghỉ ngơi! API đã vượt giới hạn miễn phí. Vui lòng thử lại sau 1-2 phút.' });
    }
    if (msg.includes('SAFETY')) {
      return res.status(500).json({ message: '⚠️ Nội dung không phù hợp, vui lòng thử câu hỏi khác.' });
    }
    res.status(500).json({ message: `❌ Lỗi AI: ${msg || 'Không xác định'}` });
  }
});

export default router;
