import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = 'http://192.168.42.20:3000'}); // Real Device IP

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('API GET Error: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('API POST Error: $e');
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    List<http.MultipartFile>? files,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);
    final headers = await _getHeaders();

    // Add headers (excluding Content-Type as MultipartRequest handles it)
    headers.forEach((key, value) {
      if (key != 'Content-Type') {
        request.headers[key] = value;
      }
    });

    request.fields.addAll(fields);
    if (files != null) {
      request.files.addAll(files);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<dynamic> putMultipart(
    String endpoint,
    Map<String, String> fields, {
    List<http.MultipartFile>? files,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('PUT', uri);
    final headers = await _getHeaders();

    headers.forEach((key, value) {
      if (key != 'Content-Type') {
        request.headers[key] = value;
      }
    });

    request.fields.addAll(fields);
    if (files != null) {
      request.files.addAll(files);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        if (response.body.trim().startsWith('<')) {
          final preview = response.body.length > 200
              ? response.body.substring(0, 200) + '...'
              : response.body;
          throw Exception('Server returned HTML: $preview');
        }
        rethrow;
      }
    } else {
      debugPrint('API Error ${response.statusCode}: ${response.body}');
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
