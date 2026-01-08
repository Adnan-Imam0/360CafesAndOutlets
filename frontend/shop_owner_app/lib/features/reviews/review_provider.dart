import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class ReviewProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get average rating
  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold(0.0, (sum, r) => sum + (r['rating'] as num));
    return total / _reviews.length;
  }

  // Get rating distribution (e.g., {'5': 10, '4': 2})
  Map<int, int> get ratingDistribution {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in _reviews) {
      final rating = r['rating'] as int;
      if (dist.containsKey(rating)) {
        dist[rating] = dist[rating]! + 1;
      }
    }
    return dist;
  }

  Future<void> fetchShopReviews(int shopId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/reviews/shop/$shopId');
      _reviews = response;
    } catch (e) {
      _error = e.toString();
      _reviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
