import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();
  static ConnectivityService get instance => _instance;

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  ConnectivityService._internal() {
    _init();
  }

  void _init() async {
    // 1. Listen for changes
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateStatus(results);
    });

    // 2. Check initial status
    final initialResult = await _connectivity.checkConnectivity();
    _updateStatus(initialResult);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // If results contains NONE, it might still have other connections?
    // Actually connectivity_plus docs say: "The list... represents all active connections."
    // If the list contains .none, does it mean NO connection?
    // Usually if it contains .mobile or .wifi, we are good.
    // If it ONLY contains .none, we are bad.
    // But usually it returns [ConnectivityResult.none] if disconnected.

    bool isConnected = !results.contains(ConnectivityResult.none);
    debugPrint('Connectivity Changed: $results -> isConnected: $isConnected');
    _connectionStatusController.add(isConnected);
  }

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
