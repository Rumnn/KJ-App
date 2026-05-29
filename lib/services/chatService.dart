import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../appConfig.dart';

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}

class ChatService {
  ChatService._();

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));

  static String _responseText(dynamic value) {
    if (value is String) return value;
    if (value is Map) {
      final nested = value['reply'] ??
          value['message'] ??
          value['error'] ??
          value['content'] ??
          value['text'];
      if (nested != null && nested != value) return _responseText(nested);
    }

    return value?.toString() ?? '';
  }

  static Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final res = await _dio.post('/ai/chat', data: {
      'message': message,
      'history': history.map((m) => m.toJson()).toList(),
    });
    final data = res.data;
    if (data is Map) {
      final reply = _responseText(data['reply']);
      if (reply.trim().isNotEmpty) return reply;

      final errorMessage = _responseText(data['message']);
      if (errorMessage.trim().isNotEmpty) {
        throw Exception(errorMessage);
      }

      throw Exception(data.toString());
    }

    if (data is String && data.trim().isNotEmpty) return data;
    throw Exception('Phản hồi từ server không hợp lệ.');
  }
}
