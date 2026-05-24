import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wisata_model.dart';

class WisataService {
  // Ganti dengan base URL API kamu
  static const String baseUrl = 'http://192.168.1.10:3000';
  static const String token = 'YOUR_BEARER_TOKEN_HERE';

  static Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

  /// Ambil semua data wisata
  static Future<List<Wisata>> getAllWisata() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/locations/1'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == true) {
        return (body['data'] as List).map((e) => Wisata.fromJson(e)).toList();
      }
      throw Exception('Gagal mengambil data wisata');
    }
    throw Exception('HTTP Error: ${response.statusCode}');
  }

  /// Ambil detail wisata berdasarkan ID
  static Future<Wisata> getWisataById(int id) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.10:3000/api/locations/$id'),
      headers: _headers,
    );

    final contentResponse = await http.get(
      Uri.parse('http://192.168.1.10:3000/api/content/$id'),
      headers: _headers,
    );

    final audioResponse = await http.get(
      Uri.parse('http://192.168.1.10:3000/api/audio/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200 &&
        contentResponse.statusCode == 200 &&
        audioResponse.statusCode == 200) {
      print('Response Content: ${contentResponse.body}');
      final body = jsonDecode(response.body);
      final contentBody = jsonDecode(contentResponse.body);
      final audioBody = jsonDecode(audioResponse.body);
      if (body['status'] == "success") {
        Wisata wisata = Wisata.fromJson(body);
        wisata.sejarah = contentBody['data'][0]['sections'][0]['body'] ?? '';
        wisata.audioSejarah = audioBody['data'][0]['audioUrl'];
        return wisata;
      }
      throw Exception('Wisata tidak ditemukan');
    } else if (response.statusCode == 404) {
      throw Exception('Wisata tidak ditemukan');
    }
    throw Exception('HTTP Error: ${response.statusCode}');
  }
}
