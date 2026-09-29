import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://cules-hub.onrender.com/api';
    }
    return 'http://localhost:3000/api';
  }

  // 1. Запрос ближайших и прошлых матчей Барселоны
  static Future<List<dynamic>> fetchMatches() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/matches'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка при получении матчей');
      }
    } catch (e) {
      print('Error fetching matches: $e');
      return [];
    }
  }

  // 2. Запрос турнирной таблицы Ла Лиги
  static Future<List<dynamic>> fetchStandings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/standings'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка при получении таблицы');
      }
    } catch (e) {
      print('Error fetching standings: $e');
      return [];
    }
  }

  // 3. Запрос данных La Masia / Barça Atlètic
  static Future<Map<String, dynamic>> fetchMasiaData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/masia'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching Masia data: $e');
      return {};
    }
  }

  // 4. Запрос данных по финансам, зарплатам и контрактам
  static Future<Map<String, dynamic>> fetchTransfersAndFinance() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/finance'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching finance data: $e');
      return {};
    }
  }
}