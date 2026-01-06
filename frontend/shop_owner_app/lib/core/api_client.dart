import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = 'http://127.0.0.1:3000'}); // Gateway URL (IPv4)

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
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
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

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    List<http.MultipartFile>? files,
  }) async {
    final headers = await _getHeaders();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    request.headers.addAll(headers);
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
    final headers = await _getHeaders();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl$endpoint'),
    );

    request.headers.addAll(headers);
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
        debugPrint('JSON Decode Error: $e');
        debugPrint('Response Body: ${response.body}');
        if (response.body.trim().startsWith('<')) {
          // Helper for debugging HTML responses (often 404/500 from proxy/server)
          final preview = response.body.length > 200
              ? response.body.substring(0, 200) + '...'
              : response.body;
          throw Exception(
            'Server returned HTML instead of JSON. Ensure Backend is running. Body Preview: $preview',
          );
        }
        rethrow;
      }
    } else {
      debugPrint('API Error ${response.statusCode}: ${response.body}');
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
