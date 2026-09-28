import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // На сервере Nginx сам перенаправит /api на Node.js.
  // При локальной отладке используем localhost:3000.
  static String get baseUrl {
    if (kReleaseMode) {
      return '/api'; 
    }
    return 'http://localhost:3000/api';
  }

  static Future<Map<String, dynamic>> fetchNextMatch() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/match/latest')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) return json.decode(res.body);
    } catch (_) {}
    return {};
  }

  static Future<Map<String, dynamic>> fetchMasiaData() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/masia')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) return json.decode(res.body);
    } catch (_) {}
    return {};
  }

  static Future<Map<String, dynamic>> fetchTransfersAndFinance() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/transfers-and-finance')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) return json.decode(res.body);
    } catch (_) {}
    return {};
  }
}