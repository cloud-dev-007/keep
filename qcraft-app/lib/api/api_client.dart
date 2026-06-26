import 'dart:io';

import 'package:dio/dio.dart';

import 'auth_store.dart';
import 'models.dart';

/// Thrown for non-2xx responses or transport failures. UI layer catches these
/// and shows a snackbar.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.detail});

  final String message;
  final int? statusCode;
  final Object? detail;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thin wrapper over Dio. One instance per app; held by `apiClient` in main.dart.
class ApiClient {
  ApiClient({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: _normalize(baseUrl ?? defaultBaseUrl),
            // Quiz generation is LLM-heavy — give the server plenty of time.
            connectTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 120),
            receiveTimeout: const Duration(seconds: 180),
            headers: {'Accept': 'application/json'},
            // Don't throw on 4xx — we want to inspect the body for the error
            // message NestJS returns ({statusCode, message, error}).
            validateStatus: (s) => s != null && s < 500,
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // Attach the bearer token to every request when authenticated.
        onRequest: (options, handler) {
          final token = authStore.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        // A 401 means the token is missing/expired — drop the session so the
        // app falls back to the login screen. (401 comes through as a normal
        // response because validateStatus allows <500.)
        onResponse: (response, handler) {
          if (response.statusCode == 401) {
            authStore.clear();
          }
          handler.next(response);
        },
      ),
    );
  }

  /// Default base URL. Override per build with `--dart-define=API_BASE_URL=...`.
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://qcraft.code-etp.name.ng/',
  );

  static String _normalize(String url) {
    var u = url.trim();
    if (!u.endsWith('/')) u = '$u/';
    return u;
  }

  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  // -------------------------------------------------------------------------
  // Health
  // -------------------------------------------------------------------------

  Future<Map<String, dynamic>> health() async {
    final res = await _safe(() => _dio.get<dynamic>('health'));
    return (res.data is Map<String, dynamic>) ? res.data as Map<String, dynamic> : {};
  }

  // -------------------------------------------------------------------------
  // Auth
  // -------------------------------------------------------------------------

  /// Registers a new account, stores the returned token, and returns it.
  Future<void> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final res = await _safe(
      () => _dio.post<dynamic>('auth/register', data: {
        'email': email,
        'password': password,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      }),
    );
    await _persistSession(_asMap(res.data));
  }

  /// Logs in, stores the returned token.
  Future<void> login({required String email, required String password}) async {
    final res = await _safe(
      () => _dio.post<dynamic>('auth/login', data: {
        'email': email,
        'password': password,
      }),
    );
    await _persistSession(_asMap(res.data));
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException('Login succeeded but no token was returned');
    }
    final user = data['user'];
    await authStore.setSession(
      token: token,
      email: user is Map ? user['email'] as String? : null,
      name: user is Map ? user['name'] as String? : null,
    );
  }

  Future<void> logout() => authStore.clear();

  // -------------------------------------------------------------------------
  // Documents
  // -------------------------------------------------------------------------

  Future<List<DocumentModel>> getDocuments() async {
    final res = await _safe(() => _dio.get<dynamic>('document'));
    return _asList(res.data).map(DocumentModel.fromJson).toList(growable: false);
  }

  /// Uploads a single file. The backend accepts up to 10 in one request but
  /// the UI ships one at a time for simpler progress reporting.
  Future<List<DocumentModel>> uploadDocument(
    File file, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final form = FormData.fromMap({
      'files': [
        await MultipartFile.fromFile(file.path, filename: _basename(file.path)),
      ],
    });
    final res = await _safe(
      () => _dio.post<dynamic>(
        'document/upload',
        data: form,
        onSendProgress: onProgress,
      ),
    );
    return _asList(res.data).map(DocumentModel.fromJson).toList(growable: false);
  }

  Future<void> deleteDocument(int id) async {
    await _safe(() => _dio.delete<dynamic>('document/$id'));
  }

  // -------------------------------------------------------------------------
  // Quizzes
  // -------------------------------------------------------------------------

  Future<List<QuizModel>> getQuizzes() async {
    final res = await _safe(() => _dio.get<dynamic>('quiz'));
    return _asList(res.data).map(QuizModel.fromJson).toList(growable: false);
  }

  Future<QuizModel> createQuiz(QuizSetupRequest setup) async {
    final res = await _safe(
      () => _dio.post<dynamic>('quiz/create', data: setup.toJson()),
    );
    return QuizModel.fromJson(_asMap(res.data));
  }

  /// Generate (or regenerate) questions for an existing quiz.
  /// This is the slow call — can easily take 30–90s under Groq's free tier.
  Future<QuizModel> generateQuiz(int quizId) async {
    final res = await _safe(
      () => _dio.post<dynamic>('quiz/generate/$quizId'),
    );
    return QuizModel.fromJson(_asMap(res.data));
  }

  Future<QuizAttemptResultModel> evaluateAttempt(QuizAttemptRequest req) async {
    final res = await _safe(
      () => _dio.post<dynamic>('quiz/evaluate', data: req.toJson()),
    );
    return QuizAttemptResultModel.fromJson(_asMap(res.data));
  }

  // -------------------------------------------------------------------------
  // Internals
  // -------------------------------------------------------------------------

  Future<Response<T>> _safe<T>(Future<Response<T>> Function() run) async {
    try {
      final res = await run();
      final code = res.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        throw ApiException(
          _extractMessage(res.data) ?? 'Request failed ($code)',
          statusCode: code,
          detail: res.data,
        );
      }
      return res;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        _extractMessage(e.response?.data) ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        detail: e.response?.data ?? e,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  static String? _extractMessage(dynamic body) {
    if (body is Map) {
      final m = body['message'];
      if (m is String) return m;
      if (m is List && m.isNotEmpty) return m.first.toString();
      final err = body['error'];
      if (err is String) return err;
    }
    if (body is String && body.isNotEmpty) return body;
    return null;
  }

  /// The q-engine API wraps every successful response in
  /// `{status, message, data: <payload>}`. We unwrap to the inner payload
  /// before type-shaping so callers can think in terms of "the list/map of
  /// rows the endpoint conceptually returns".
  static dynamic _unwrap(dynamic data) {
    if (data is Map && data.containsKey('data') &&
        (data['status'] == true || data['status'] == false || data.containsKey('message'))) {
      return data['data'];
    }
    return data;
  }

  static List<Map<String, dynamic>> _asList(dynamic data) {
    final payload = _unwrap(data);
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    return const [];
  }

  static Map<String, dynamic> _asMap(dynamic data) {
    final payload = _unwrap(data);
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return <String, dynamic>{};
  }

  static String _basename(String path) {
    final ix = path.replaceAll('\\', '/').lastIndexOf('/');
    return ix < 0 ? path : path.substring(ix + 1);
  }
}
