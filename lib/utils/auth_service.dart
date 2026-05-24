import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'session_service.dart';

class AuthService {
  static const String baseUrl = 'https://your-api-domain.com';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<User> login({
    required String email,
    required String password,
  }) async {
    // DUMMY MODE
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'test@gmail.com' && password == '12345678') {
      final user = User(
          id: 1, name: 'User Demo', email: email, token: 'dummy-token-123');
      await SessionService.saveSession(user);
      return user;
    }
    throw Exception('Email atau password salah');

    // API MODE
    // final response = await http.post(
    //   Uri.parse('$baseUrl/api/login'),
    //   headers: _headers,
    //   body: jsonEncode({'email': email, 'password': password}),
    // );
    // final body = jsonDecode(response.body);
    // if (response.statusCode == 200 && body['status'] == true) {
    //   final user = User.fromJson(body['data']['user'], token: body['data']['token']);
    //   await SessionService.saveSession(user);
    //   return user;
    // } else if (response.statusCode == 401) {
    //   throw Exception('Email atau password salah');
    // }
    // throw Exception(body['message'] ?? 'HTTP Error: ${response.statusCode}');
  }

  static Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    // DUMMY MODE
    await Future.delayed(const Duration(seconds: 1));
    final user =
        User(id: 1, name: name, email: email, token: 'dummy-token-123');
    await SessionService.saveSession(user);
    return user;

    // API MODE
    // final response = await http.post(
    //   Uri.parse('$baseUrl/api/register'),
    //   headers: _headers,
    //   body: jsonEncode({
    //     'name': name,
    //     'email': email,
    //     'password': password,
    //     'password_confirmation': passwordConfirmation,
    //   }),
    // );
    // final body = jsonDecode(response.body);
    // if ((response.statusCode == 200 || response.statusCode == 201) && body['status'] == true) {
    //   final user = User.fromJson(body['data']['user'], token: body['data']['token']);
    //   await SessionService.saveSession(user);
    //   return user;
    // } else if (response.statusCode == 422) {
    //   final errors = body['errors'] as Map<String, dynamic>?;
    //   final firstError = errors?.values.first;
    //   throw Exception(firstError is List ? firstError.first : 'Data tidak valid');
    // }
    // throw Exception(body['message'] ?? 'HTTP Error: ${response.statusCode}');
  }

  static Future<void> logout() async {
    await SessionService.clearSession();
  }
}
