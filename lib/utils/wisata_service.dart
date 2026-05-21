import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wisata_model.dart';

class WisataService {
  // Ganti dengan base URL API kamu
  static const String baseUrl = 'https://your-api-domain.com';
  static const String token = 'YOUR_BEARER_TOKEN_HERE';

  static Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

  /// Ambil semua data wisata
  static Future<List<Wisata>> getAllWisata() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/wisata'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == true) {
        return (body['data'] as List)
            .map((e) => Wisata.fromJson(e))
            .toList();
      }
      throw Exception('Gagal mengambil data wisata');
    }
    throw Exception('HTTP Error: ${response.statusCode}');
  }

  /// Ambil detail wisata berdasarkan ID
  static Future<Wisata> getWisataById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/wisata/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == true) {
        return Wisata.fromJson(body['data']);
      }
      throw Exception('Wisata tidak ditemukan');
    } else if (response.statusCode == 404) {
      throw Exception('Wisata tidak ditemukan');
    }
    throw Exception('HTTP Error: ${response.statusCode}');
  }
}
