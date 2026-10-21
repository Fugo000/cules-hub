import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://cules-hub.onrender.com/api';
    }
    return 'https://cules-hub.onrender.com/api';
  }

  static String _noCacheUrl(String path) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '$baseUrl/$path?t=$ts';
  }

  static Future<List<dynamic>> fetchMatches() async {
    try {
      final response = await http.get(Uri.parse(_noCacheUrl('matches')));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching matches: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> fetchMatchDetails(String matchId) async {
    try {
      final response = await http.get(Uri.parse(_noCacheUrl('matches/$matchId')));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching match details: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> fetchSquad2026() async {
    try {
      final response = await http.get(Uri.parse(_noCacheUrl('squad')));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching squad: $e');
      return {};
    }
  }

  static Future<List<dynamic>> fetchStandings() async {
    try {
      final response = await http.get(Uri.parse(_noCacheUrl('standings')));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching standings: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> fetchMasiaData() async {
    try {
      final response = await http.get(Uri.parse(_noCacheUrl('masia')));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching Masia data: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> fetchTransfersAndFinance() async {
    try {
      final response = await http.get(Uri.parse(_noCacheUrl('finance')));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching finance data: $e');
      return {};
    }
  }
}