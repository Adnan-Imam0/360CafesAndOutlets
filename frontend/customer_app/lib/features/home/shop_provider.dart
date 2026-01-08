import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';

class ShopProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _shops = [];
  bool _isLoading = true; // Start loading initially

  List<dynamic> get shops => _shops;
  bool get isLoading => _isLoading;

  ShopProvider() {
    _loadCachedShops();
  }

  Future<void> _loadCachedShops() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_shops');
    if (cachedData != null) {
      try {
        _shops = await compute(_decodeShops, cachedData);
        _isLoading = false; // Show cached content
        notifyListeners();
      } catch (e) {
        print('Error parsing cached shops: $e');
      }
    }
  }

  Future<void> fetchShops({String? searchQuery, String? category}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try to load from cache first for instant display (only if no filter)
      if (searchQuery == null && category == null) {
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString('cached_shops');
        if (cachedData != null) {
          try {
            _shops = await compute(_decodeShops, cachedData);
            notifyListeners();
          } catch (e) {
            print('Error parsing cached shops: $e');
          }
        }
      }

      // 2. Build Query String
      String endpoint = '/shops';
      final params = <String>[];
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(searchQuery)}');
      }
      if (category != null && category != 'All') {
        params.add('type=${Uri.encodeComponent(category)}');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      // 3. Fetch from API
      final response = await _apiClient.get(endpoint);

      if (response != null && response is List) {
        _shops = response;

        // Update cache only if fetching full list
        if (searchQuery == null && category == null) {
          _cacheShops(response);
        }
      }
    } catch (e) {
      print('Fetch shops failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cacheShops(List<dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = await compute(_encodeShops, data);
    await prefs.setString('cached_shops', encodedData);
  }
}

// Top-level functions for compute
List<dynamic> _decodeShops(String source) {
  return jsonDecode(source) as List<dynamic>;
}

String _encodeShops(List<dynamic> data) {
  return jsonEncode(data);
}
