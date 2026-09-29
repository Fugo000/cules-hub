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

  // 1. Запрос всех матчей
  static Future<List<dynamic>> fetchMatches() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/matches'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching matches: $e');
      return [];
    }
  }

  // 2. Детали конкретного матча
  static Future<Map<String, dynamic>> fetchMatchDetails(String matchId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/matches/$matchId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching match details: $e');
      return {};
    }
  }

  // 3. Официальный состав сезона 2026/2027
  static Future<Map<String, dynamic>> fetchSquad2026() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/squad'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching squad: $e');
      return {};
    }
  }

  // 4. Запрос данных La Masia
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

  // 5. Запрос финансов
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