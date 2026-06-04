import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../appConfig.dart';

class AdminService {
  AdminService._();

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
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

  static Future<Map<String, dynamic>> getSummary() async {
    final res = await _dio.get('/admin/summary');
    return Map<String, dynamic>.from(res.data as Map);
  }

  static Future<Map<String, dynamic>> getUsers({
    String search = '',
    String role = '',
    String status = '',
    int page = 1,
  }) async {
    final res = await _dio.get('/admin/users', queryParameters: {
      if (search.isNotEmpty) 'search': search,
      if (role.isNotEmpty) 'role': role,
      if (status.isNotEmpty) 'status': status,
      'page': page,
      'limit': 25,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  static Future<Map<String, dynamic>> getUserDetail(String id) async {
    final res = await _dio.get('/admin/users/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  static Future<void> updateUser(
    String id, {
    String? email,
    String? role,
    String? status,
  }) async {
    await _dio.patch('/admin/users/$id', data: {
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
    });
  }

  static Future<void> deleteUser(String id) async {
    await _dio.delete('/admin/users/$id');
  }

  static Future<Map<String, dynamic>> getQuizResults({
    String userId = '',
    String level = '',
    int page = 1,
  }) async {
    final res = await _dio.get('/admin/quiz-results', queryParameters: {
      if (userId.isNotEmpty) 'userId': userId,
      if (level.isNotEmpty) 'level': level,
      'page': page,
      'limit': 25,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  static Future<void> deleteQuizResult(String id) async {
    await _dio.delete('/admin/quiz-results/$id');
  }

  static String handleError(Object error) {
    if (error is DioException && error.response?.data is Map) {
      final data = error.response!.data as Map;
      return data['message'] as String? ?? 'Admin request failed';
    }
    return error.toString();
  }
}
