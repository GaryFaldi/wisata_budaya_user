import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'session_service.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.0.198:3000';

  /// Headers dengan token dinamis
  static Future<Map<String, String>> getHeaders() async {
    final token = await SessionService.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: await getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == "success") {
      final user = User.fromJson(
        body['data']['user'],
        token: body['data']['accessToken'],
      );

      await SessionService.saveSession(user);

      return user;
    } else if (response.statusCode == 401) {
      throw Exception('Email atau password salah');
    }

    throw Exception(
      body['message'] ?? 'HTTP Error: ${response.statusCode}',
    );
  }

  static Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: await getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final user = User.fromJson(
        body['data']['user'],
        token: body['data']['accessToken'],
      );

      await SessionService.saveSession(user);

      return user;
    } else if (response.statusCode == 422) {
      final errors = body['errors'] as Map<String, dynamic>?;

      final firstError = errors?.values.first;

      throw Exception(
        firstError is List ? firstError.first : 'Data tidak valid',
      );
    }

    throw Exception(
      body['message'] ?? 'HTTP Error: ${response.statusCode}',
    );
  }

  static Future<void> logout() async {
    await SessionService.clearSession();
  }
}
