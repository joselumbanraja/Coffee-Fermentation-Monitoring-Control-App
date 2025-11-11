import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ========================= KONFIGURASI DASAR =========================
  static const String baseUrl = 'http://172.25.41.127/api/profiles.php';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // ======================================
  // AUTH - LOGIN & REGISTER
  // ======================================
  Future<Map<String, dynamic>> register(
      String fullname, String username, String password) async {
    final url = Uri.parse('$baseUrl?type=register');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'fullname': fullname,
        'username': username,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl?type=login');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(data['user']));
    }
    return data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  Future<Map<String, dynamic>?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // ========================= PROFILE ENDPOINT =========================
  Future<List<dynamic>> fetchProfiles() async {
    try {
      final uri = Uri.parse('$baseUrl?type=profile');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        if (j is Map && j['success'] == true && j['data'] != null) {
          return (j['data'] as List);
        } else if (j is List) {
          return j;
        }
      }
    } catch (e) {
      debugPrint('fetchProfiles error: $e');
    }
    return [];
  }

  Future<bool> createProfile(Map<String, dynamic> p) async {
    try {
      final uri = Uri.parse('$baseUrl?type=profile');
      final res = await http.post(uri, headers: headers, body: jsonEncode(p));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        return j['success'] == true || j['id'] != null;
      }
    } catch (e) {
      debugPrint('createProfile error: $e');
    }
    return false;
  }

  Future<bool> updateProfile(Map<String, dynamic> p) async {
    try {
      final uri = Uri.parse('$baseUrl?type=profile');
      final res = await http.put(uri, headers: headers, body: jsonEncode(p));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        return j['success'] == true;
      }
    } catch (e) {
      debugPrint('updateProfile error: $e');
    }
    return false;
  }

  Future<bool> deleteProfile(int id) async {
    try {
      final uri = Uri.parse('$baseUrl?type=profile&id=$id');
      final res = await http.delete(uri);
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        return j['success'] == true;
      }
    } catch (e) {
      debugPrint('deleteProfile error: $e');
    }
    return false;
  }

  // ========================= HISTORY ENDPOINT =========================
  Future<List<dynamic>> fetchHistory() async {
    try {
      final uri = Uri.parse('$baseUrl?type=history');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        if (j is Map && j['success'] == true && j['data'] != null) {
          return (j['data'] as List);
        } else if (j is List) {
          return j;
        }
      }
    } catch (e) {
      debugPrint('fetchHistory error: $e');
    }
    return [];
  }

  Future<bool> addHistory(Map<String, dynamic> history) async {
    try {
      final uri = Uri.parse('$baseUrl?type=history');
      final res =
          await http.post(uri, headers: headers, body: jsonEncode(history));

      debugPrint("Response Code: ${res.statusCode}");
      debugPrint("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        return j['success'] == true;
      }
    } catch (e) {
      debugPrint('addHistory error: $e');
    }
    return false;
  }

  Future<bool> deleteHistory(int id) async {
    try {
      final uri = Uri.parse('$baseUrl?type=history&id=$id');
      final res = await http.delete(uri);
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        return j['success'] == true;
      }
    } catch (e) {
      debugPrint('deleteHistory error: $e');
    }
    return false;
  }

  // ========================= SENSOR ENDPOINT =========================
  Future<List<dynamic>> fetchSensor({int limit = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl?type=sensor&limit=$limit');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        if (j is Map && j['success'] == true && j['data'] != null) {
          return (j['data'] as List);
        } else if (j is List) {
          return j;
        }
      }
    } catch (e) {
      debugPrint('fetchSensor error: $e');
    }
    return [];
  }

  // ========================= FERM. CONTROL ENDPOINT =========================
  Future<bool> toggleFermentation(int profileId, bool on) async {
    try {
      final uri = Uri.parse('$baseUrl?type=fermentation');
      final res = await http.post(uri,
          headers: headers,
          body: jsonEncode({'profile_id': profileId, 'status': on ? 1 : 0}));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        return j['success'] == true;
      }
    } catch (e) {
      debugPrint('toggleFermentation error: $e');
    }
    return false;
  }
}
