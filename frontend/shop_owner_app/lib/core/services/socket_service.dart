import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final _orderController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get orderStream => _orderController.stream;

  void connect(String shopId) {
    if (_socket != null && _socket!.connected) return;

    // Use 10.0.2.2 for Android Emulator, localhost for Web/iOS
    // Gateway runs on port 3000 and proxies /socket.io to Order Service
    // BUT Order Service is behind /orders.
    // The Gateway configures ws: true for /orders.
    // So we connect to http://localhost:3000 and path: /orders/socket.io

    // Actually, usually with proxy, it's cleaner to connect directly or via specific path.
    // The Gateway routes `/orders/*` to Order Service (3004).
    // Socket.io default path is `/socket.io`.
    // So if we connect to `localhost:3000`, we need path `/orders/socket.io`.

    final uri = kIsWeb ? 'http://127.0.0.1:3000' : 'http://10.0.2.2:3000';

    _socket = IO.io(
      uri,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/orders/socket.io') // Crucial for Gateway routing
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Socket Connected: ${_socket!.id}');
      _socket!.emit('join_room', 'shop_$shopId');
    });

    _socket!.onConnectError(
      (err) => debugPrint('Socket Connection Error: $err'),
    );
    _socket!.onError((err) => debugPrint('Socket Error: $err'));

    _socket!.onDisconnect((_) => debugPrint('Socket Disconnected'));

    _socket!.on('new_order', (data) {
      debugPrint('New Order Received: $data');
      _orderController.add(Map<String, dynamic>.from(data));
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
