import express from 'express';
import fs from 'fs';
import { GoogleGenerativeAI } from '@google/generative-ai';
import path from 'path';
import { requireAuth } from '../middleware/authMiddleware.js';

const router = express.Router();

let studyDataCache = null;

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

function resolveAssetsDir() {
  const candidates = [
    path.resolve(process.cwd(), 'assets'),
    path.resolve(process.cwd(), '..', 'assets'),
  ];

  return candidates.find(candidate => fs.existsSync(candidate)) || candidates[0];
}

function parseCsvLine(line) {
  const values = [];
  let current = '';
  let inQuotes = false;

  for (let i = 0; i < line.length; i += 1) {
    const char = line[i];
    const next = line[i + 1];

    if (char === '"' && next === '"') {
      current += '"';
      i += 1;
    } else if (char === '"') {
      inQuotes = !inQuotes;
    } else if (char === ',' && !inQuotes) {
      values.push(current);
      current = '';
    } else {
      current += char;
    }
  }

  values.push(current);
  return values;
}

function loadStudyData() {
  if (studyDataCache) return studyDataCache;

  const assetsDir = resolveAssetsDir();
  const vocabPath = path.join(assetsDir, 'jlpt_vocab.csv');
  const grammarDir = path.join(assetsDir, 'grammar');

  const vocab = fs.readFileSync(vocabPath, 'utf8')
    .split(/\r?\n/)
    .slice(1)
    .filter(Boolean)
    .map(line => {
      const [original, furigana, english, level] = parseCsvLine(line);
      return { original, furigana, english, level };
    });

  const grammar = fs.readdirSync(grammarDir)
    .filter(file => file.endsWith('.json'))
    .flatMap(file => {
      const level = file.match(/grammar_ja_(N\d)\.json/)?.[1] || '';
      const items = JSON.parse(fs.readFileSync(path.join(grammarDir, file), 'utf8'));
      return items.map(item => ({ ...item, level }));
    });

  studyDataCache = { vocab, grammar };
  return studyDataCache;
}

function getJapaneseTerms(text) {
  return [...new Set(text.match(/[\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Han}ー々]+/gu) || [])]
    .filter(term => term.length > 1);
}

function knownKeigoEntry(term) {
  const entries = {
    'ご覧': {
      original: 'ご覧になる',
      furigana: 'ごらんになる',
      english: 'to see/look/watch (respectful form)',
      level: 'Keigo',
      note: 'Dùng để nâng người thực hiện hành động lên, ví dụ nói về thầy, khách hàng, cấp trên.',
    },
    'ご覧になる': {
      original: 'ご覧になる',
      furigana: 'ごらんになる',
      english: 'to see/look/watch (respectful form)',
      level: 'Keigo',
      note: 'Dùng để nâng người thực hiện hành động lên, ví dụ nói về thầy, khách hàng, cấp trên.',
    },
    '拝見': {
      original: '拝見する',
      furigana: 'はいけんする',
      english: 'to see/look at (humble form)',
      level: 'N4/Keigo',
      note: 'Dùng khi nói về hành động của chính mình để hạ mình xuống trước người nghe/người được kính trọng.',
    },
    '拝見する': {
      original: '拝見する',
      furigana: 'はいけんする',
      english: 'to see/look at (humble form)',
      level: 'N4/Keigo',
      note: 'Dùng khi nói về hành động của chính mình để hạ mình xuống trước người nghe/người được kính trọng.',
    },
    '見る': {
      original: '見る',
      furigana: 'みる',
      english: 'to see, to look',
      level: 'N5',
      note: 'Cách nói trung tính, dùng trong hội thoại thông thường.',
    },
  };

  return entries[term];
}

function buildStudyFallbackReply(message) {
  const { vocab, grammar } = loadStudyData();
  const normalized = message.trim().toLowerCase();
  const terms = getJapaneseTerms(message);
  const knownMatches = terms.map(knownKeigoEntry).filter(Boolean);

  const vocabMatches = vocab
    .filter(item => (
      terms.some(term => item.original.includes(term) || term.includes(item.original) || item.furigana.includes(term))
      || normalized.includes(item.original.toLowerCase())
      || normalized.includes(item.furigana.toLowerCase())
    ))
    .slice(0, 8);

  const mergedVocab = [...knownMatches, ...vocabMatches]
    .filter((item, index, arr) => arr.findIndex(other => other.original === item.original) === index)
    .slice(0, 8);

  const grammarMatches = grammar
    .filter(item => (
      terms.some(term => item.title.includes(term) || item.short_explanation.includes(term) || item.long_explanation.includes(term))
      || normalized.includes(item.title.toLowerCase().split(' ')[0])
    ))
    .slice(0, 3);

  if (/^(hi|hello|chào|xin chào|こんにちは|こんばんは)/i.test(normalized)) {
    return 'Xin chào! Sensei đang ở chế độ ôn tập offline. Bạn có thể hỏi về từ vựng, Kanji, mẫu ngữ pháp, hoặc gửi vài từ để mình lập bảng so sánh nhé.';
  }

  if (mergedVocab.length > 1) {
    const rows = mergedVocab
      .map(item => `| **${item.original}** | ${item.furigana} | ${item.english} | ${item.level || ''} | ${item.note || 'Tra theo dữ liệu JLPT trong app.'} |`)
      .join('\n');

    return `Mình đang dùng chế độ ôn tập offline, nên sẽ so sánh theo dữ liệu có sẵn trong app.\n\n| Từ | Cách đọc | Nghĩa chính | Mức | Ghi chú |\n|---|---|---|---|---|\n${rows}\n\n**Kết luận dễ nhớ:**\n- **見る**: cách nói thường.\n- **拝見する**: khi *mình* xem/xem qua thứ của người khác một cách khiêm nhường.\n- **ご覧になる**: khi *người được kính trọng* xem/xem qua.\n\nKhi API hoạt động lại, Sensei sẽ giải thích sâu hơn về sắc thái và ví dụ tự nhiên.`;
  }

  if (mergedVocab.length === 1) {
    const item = mergedVocab[0];
    return `Mình tìm thấy từ này trong dữ liệu ôn tập:\n\n**${item.original}** (${item.furigana})\n\n- **Nghĩa:** ${item.english}\n- **Mức JLPT:** ${item.level || 'chưa rõ'}\n- **Ghi chú:** ${item.note || 'Bạn có thể đặt câu với từ này rồi gửi lại, mình sẽ giúp kiểm tra khi AI hoạt động.'}\n\nVí dụ mẫu: **${item.original}** を勉強します。`;
  }

  if (grammarMatches.length > 0) {
    const blocks = grammarMatches.map(item => {
      const examples = (item.examples || [])
        .slice(0, 2)
        .map(example => `- ${example.jp}\n  ${example.romaji}\n  ${example.vn}`)
        .join('\n');

      return `**${item.title}** (${item.level})\n\n${item.short_explanation}\n\n**Cách dùng:** ${item.formation}\n\n${examples}`;
    }).join('\n\n---\n\n');

    return `Mình tìm thấy mẫu ngữ pháp gần với câu hỏi của bạn:\n\n${blocks}`;
  }

  return 'Sensei đang dùng chế độ ôn tập offline vì API Gemini chưa sẵn sàng. Bạn hãy hỏi bằng một từ tiếng Nhật cụ thể như `見る`, `勉強`, `～ながら`, hoặc gửi dạng `A vs B` để mình tra trong dữ liệu JLPT của app.';
}

function isQuotaError(message) {
  return message.includes('429') || message.includes('quota') || message.includes('RESOURCE_EXHAUSTED');
}

function cleanOllamaReply(reply) {
  if (!reply) return null;

  const withoutThinkingTags = reply.replace(/<think>[\s\S]*?<\/think>/gi, '').trim();
  const markers = ['Trả lời:', 'Tra loi:', 'Đáp án:', 'Dap an:', 'Answer:'];
  const marker = markers.find(item => withoutThinkingTags.includes(item));

  if (marker) {
    return withoutThinkingTags.slice(withoutThinkingTags.indexOf(marker) + marker.length).trim();
  }

  if (/^(okay|let me|i need to|wait,|first,)/i.test(withoutThinkingTags)) {
    return null;
  }

  return withoutThinkingTags;
}

async function buildOllamaReply(message, history) {
  const model = process.env.OLLAMA_MODEL;
  if (!model) return null;

  const baseUrl = process.env.OLLAMA_URL || 'http://localhost:11434';
  const timeoutMs = Number(process.env.OLLAMA_TIMEOUT_MS || 30000);
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(`${baseUrl.replace(/\/$/, '')}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      signal: controller.signal,
      body: JSON.stringify({
        model,
        stream: false,
        think: false,
        options: {
          temperature: Number(process.env.OLLAMA_TEMPERATURE || 0.4),
          num_predict: Number(process.env.OLLAMA_NUM_PREDICT || 800),
        },
        messages: [
          { role: 'system', content: SENSEI_SYSTEM_PROMPT },
          ...(history || []).map(msg => ({
            role: msg.role === 'user' ? 'user' : 'assistant',
            content: msg.content,
          })),
          {
            role: 'user',
            content: `/no_think\nChỉ trả lời đáp án cuối cùng bằng tiếng Việt. Bắt đầu bằng "Trả lời:".\n\n${message.trim()}`,
          },
        ],
      }),
    });

    if (!response.ok) {
      throw new Error(`Ollama returned ${response.status}`);
    }

    const data = await response.json();
    return cleanOllamaReply(data?.message?.content);
  } catch (error) {
    console.warn('Ollama fallback failed:', error?.message || error);
    return null;
  } finally {
    clearTimeout(timeout);
  }
}

async function buildLocalOrOfflineReply(message, history) {
  return await buildOllamaReply(message, history) || buildStudyFallbackReply(message);
}

router.post('/chat', requireAuth, async (req, res) => {
  try {
    const { message, history } = req.body;

    if (!message || typeof message !== 'string' || message.trim() === '') {
      return res.status(400).json({ message: 'Message is required' });
    }

    if (process.env.AI_PROVIDER === 'ollama') {
      return res.status(200).json({ reply: await buildLocalOrOfflineReply(message, history) });
    }

    const apiKey = process.env.GEMINI_API_KEY;
    console.log('[AI] Using API key:', apiKey ? `${apiKey.substring(0, 10)}...` : 'NOT SET');
    if (!apiKey || apiKey === 'your_gemini_api_key_here') {
      return res.status(200).json({ reply: await buildLocalOrOfflineReply(message, history) });
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
    const fallbackReply = () => buildLocalOrOfflineReply(req.body?.message || '', req.body?.history || []);
    if (msg.includes('API_KEY') || msg.includes('API key')) {
      return res.status(200).json({ reply: fallbackReply() });
    }
    if (isQuotaError(msg)) {
      return res.status(200).json({ reply: fallbackReply() });
    }
    if (msg.includes('SAFETY')) {
      return res.status(500).json({ message: '⚠️ Nội dung không phù hợp, vui lòng thử câu hỏi khác.' });
    }
    res.status(500).json({ message: `❌ Lỗi AI: ${msg || 'Không xác định'}` });
  }
});

export default router;
