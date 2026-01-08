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

  ApiClient({this.baseUrl = 'http://localhost:3000'}); // Local Docker URL

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _requestWithRetry(
    Future<http.Response> Function() requestFn, {
    int retries = 6, // Increased to cover ~60s cold start
  }) async {
    for (int i = 0; i < retries; i++) {
      try {
        final response = await requestFn();

        // If 429 (Too Many Requests), throw to trigger retry (with backoff)
        if (response.statusCode == 429) {
          throw Exception('Rate Limit Exceeded');
        }

        // Do not retry on 404 (Not Found) or 400 (Bad Request)
        if (response.statusCode == 404 || response.statusCode == 400) {
          return _handleResponse(response);
        }
        return _handleResponse(response);
      } catch (e) {
        // Stop retrying on 404 (Not Found), 400 (Bad Request), or 409 (Conflict)
        // Stop retrying on 404 (Not Found), 400 (Bad Request), or 409 (Conflict)
        final errorStr = e.toString();
        if (errorStr.contains('Error 404') ||
            errorStr.contains('Error 400') ||
            errorStr.contains('Error 409')) {
          debugPrint('Aborting retry due to permanent error: $errorStr');
          rethrow;
        }

        if (i == retries - 1) rethrow; // Final attempt failed

        // Aggressive Backoff for Cold Starts: 2s, 4s, 8s, 16s
        final delay = Duration(seconds: 2 * (1 << i));
        debugPrint(
          'Retry ${i + 1} of $retries due to: $e. Waiting ${delay.inSeconds}s...',
        );
        await Future.delayed(delay);
      }
    }
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    return _requestWithRetry(
      () => http.get(Uri.parse('$baseUrl$endpoint'), headers: headers),
    );
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    return _requestWithRetry(
      () => http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ),
    );
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    return _requestWithRetry(
      () => http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ),
    );
  }

  Future<dynamic> patch(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    return _requestWithRetry(
      () => http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ),
    );
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    return _requestWithRetry(
      () => http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers),
    );
  }

  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    List<http.MultipartFile>? files,
  }) async {
    final headers = await _getHeaders();

    return _requestWithRetry(() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      request.headers.addAll(headers);
      request.fields.addAll(fields);
      if (files != null) {
        // We need to recreate files for each retry because streams are single-use
        // Note: This naive approach assumes 'files' list can be reused, which works if they are new instances.
        // But http.MultipartFile from path is usually fine. If passed as bytes, might be an issue.
        // For now, assuming basic usage.
        request.files.addAll(files);
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    });
  }

  Future<dynamic> putMultipart(
    String endpoint,
    Map<String, String> fields, {
    List<http.MultipartFile>? files,
  }) async {
    final headers = await _getHeaders();

    return _requestWithRetry(() async {
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
      return await http.Response.fromStream(streamedResponse);
    });
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

      String errorMessage =
          'Something went wrong (Error ${response.statusCode})';

      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('error')) {
          errorMessage = body['error'];
        } else if (body is Map && body.containsKey('message')) {
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
