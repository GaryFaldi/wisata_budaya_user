import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nusantara_trail/utils/auth_service.dart';
import '../models/wisata_model.dart';

class WisataService {
  /// Ambil semua data wisata
  static Future<List<Wisata>> getAllWisata() async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/locations/1'),
      headers: await AuthService.getHeaders(),
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
      Uri.parse('${AuthService.baseUrl}/api/locations/$id'),
      headers: await AuthService.getHeaders(),
    );

    final contentResponse = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/content/$id'),
      headers: await AuthService.getHeaders(),
    );

    final audioResponse = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/audio/$id'),
      headers: await AuthService.getHeaders(),
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
        
        // Safely access nested array indices
        if (contentBody['data'] != null &&
            (contentBody['data'] as List).isNotEmpty &&
            (contentBody['data'][0]['sections'] as List).isNotEmpty) {
          wisata.sejarah = contentBody['data'][0]['sections'][0]['body'] ?? '';
        }
        
        if (audioBody['data'] != null && (audioBody['data'] as List).isNotEmpty) {
          wisata.audioSejarah = audioBody['data'][0]['audioUrl'] ?? '';
        }
        
        return wisata;
      }
      throw Exception('Wisata tidak ditemukan');
    } else if (response.statusCode == 404) {
      throw Exception('Wisata tidak ditemukan');
    }
    throw Exception('HTTP Error: ${response.statusCode}');
  }
}
