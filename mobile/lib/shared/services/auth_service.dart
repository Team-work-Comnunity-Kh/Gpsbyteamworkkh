import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  static const _boxName = 'auth';
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  late final Dio dio = Dio(BaseOptions(
    baseUrl: Hive.box('settings').get('api_url', defaultValue: apiUrl) as String,
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 30),
    headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));

  AuthService() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = Hive.box(_boxName).get(_accessTokenKey) as String?;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<void> setApiUrl(String value) async {
    var normalized = value.trim().replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasAuthority || !{'http', 'https'}.contains(uri.scheme)) {
      throw const FormatException('Enter a valid http:// or https:// server URL');
    }
    if (const bool.fromEnvironment('dart.vm.product') && uri.scheme != 'https') {
      throw const FormatException('Release builds require an HTTPS API URL');
    }
    if (!normalized.endsWith('/api')) normalized = '$normalized/api';
    await Hive.box('settings').put('api_url', normalized);
    dio.options.baseUrl = normalized;
  }

  dynamic unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'];
    }
    return data;
  }

  Future<AuthResult> login(String identifier, String password) async {
    final normalized = identifier.trim();
    final body = normalized.contains('@')
        ? {'email': normalized.toLowerCase(), 'password': password}
        : {'phone': normalized, 'password': password};
    final response = await dio.post('/auth/login', data: body);
    return AuthResult.fromJson(Map<String, dynamic>.from(unwrap(response.data) as Map));
  }

  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String password,
    String? email,
    String? phone,
  }) async {
    final response = await dio.post('/auth/register', data: {
      if (email != null && email.trim().isNotEmpty) 'email': email.trim().toLowerCase(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'password': password,
      'language': 'km',
    });
    return AuthResult.fromJson(Map<String, dynamic>.from(unwrap(response.data) as Map));
  }

  Future<void> storeTokens(String accessToken, String refreshToken) async {
    final box = Hive.box(_boxName);
    await box.put(_accessTokenKey, accessToken);
    await box.put(_refreshTokenKey, refreshToken);
  }

  Future<UserModel?> getStoredUser() async {
    final accessToken = Hive.box(_boxName).get(_accessTokenKey) as String?;
    if (accessToken == null || accessToken.isEmpty) return null;

    try {
      final response = await dio.get('/auth/me');
      return UserModel.fromJson(Map<String, dynamic>.from(unwrap(response.data) as Map));
    } catch (_) {
      return _tryRefresh();
    }
  }

  Future<UserModel?> _tryRefresh() async {
    final box = Hive.box(_boxName);
    final refreshToken = box.get(_refreshTokenKey) as String?;
    if (refreshToken == null || refreshToken.isEmpty) {
      await clearTokens();
      return null;
    }

    try {
      final response = await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
      final tokens = Map<String, dynamic>.from(unwrap(response.data) as Map);
      await storeTokens(tokens['accessToken'] as String, tokens['refreshToken'] as String);
      final profileResponse = await dio.get('/auth/me');
      return UserModel.fromJson(
        Map<String, dynamic>.from(unwrap(profileResponse.data) as Map),
      );
    } catch (_) {
      await clearTokens();
      return null;
    }
  }

  Future<void> logout() async {
    final box = Hive.box(_boxName);
    final refreshToken = box.get(_refreshTokenKey) as String?;
    try {
      await dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {
      // Local sign-out must still work if the backend is unavailable.
    }
    await clearTokens();
  }

  Future<void> clearTokens() async {
    final box = Hive.box(_boxName);
    await box.delete(_accessTokenKey);
    await box.delete(_refreshTokenKey);
  }
}
