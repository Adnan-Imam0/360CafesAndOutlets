import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;

  ApiClient({
    this.baseUrl = kIsWeb
        ? 'http://localhost:3006'
        : 'http://192.168.137.1:3006',
  }); // Local for Web, Hotspot for Mobile

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) {
    return _retryRequest(() async {
      final headers = await _getHeaders();
      try {
        final response = await http
            .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
            .timeout(const Duration(seconds: 30));
        return _handleResponse(response);
      } catch (e) {
        debugPrint('API GET Error: $e');
        rethrow;
      }
    });
  }

  Future<dynamic> post(String endpoint, dynamic data) {
    return _retryRequest(() async {
      final headers = await _getHeaders();
      try {
        final body = await compute(_encodeJson, data);
        final response = await http
            .post(Uri.parse('$baseUrl$endpoint'), headers: headers, body: body)
            .timeout(const Duration(seconds: 30));
        return _handleResponse(response);
      } catch (e) {
        debugPrint('API POST Error: $e');
        rethrow;
      }
    });
  }

  Future<dynamic> put(String endpoint, dynamic data) {
    return _retryRequest(() async {
      final headers = await _getHeaders();
      final body = await compute(_encodeJson, data);
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body,
      );
      return _handleResponse(response);
    });
  }

  Future<dynamic> patch(String endpoint, dynamic data) {
    return _retryRequest(() async {
      final headers = await _getHeaders();
      final body = await compute(_encodeJson, data);
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body,
      );
      return _handleResponse(response);
    });
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

  Future<T> _retryRequest<T>(
    Future<T> Function() request, {
    int retries = 3,
  }) async {
    int attempts = 0;
    while (true) {
      attempts++;
      try {
        return await request();
      } catch (e) {
        if (attempts >= retries) rethrow; // Give up

        // Wait before retrying (Exponential Backoff: 1s, 2s, 4s...)
        final delay = Duration(seconds: 1 * (1 << (attempts - 1)));
        debugPrint(
          'Network error ($e). Retrying in ${delay.inSeconds}s... (Attempt $attempts/$retries)',
        );
        await Future.delayed(delay);
      }
    }
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return await compute(_decodeJson, response.body);
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

      String errorMessage =
          'Something went wrong (Error ${response.statusCode})';

      try {
        final body =
            await compute(_decodeJson, response.body) as Map<String, dynamic>;
        if (body.containsKey('error')) {
          errorMessage = body['error'];
        } else if (body.containsKey('message')) {
          errorMessage = body['message'];
        }
      } catch (_) {
        // Fallback to raw body if not JSON, but truncated
        if (response.body.length < 100) errorMessage = response.body;
      }

      throw AppException(errorMessage);
    }
  }
}

// Top-level functions for compute
String _encodeJson(dynamic data) {
  return jsonEncode(data);
}

dynamic _decodeJson(String source) {
  return jsonDecode(source);
}
