import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket _socket;
  bool _isConnected = false;

  // Use the SAME IP as ApiClient!
  // If you are on Emulator: http://10.0.2.2:3000
  // If you are on Real Device: http://192.168.0.102:3000
  static const String _serverUrl = 'http://192.168.0.102:3000';

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .enableAutoConnect() // disable auto-connection
          .build(),
    );

    _socket.onConnect((_) {
      debugPrint('Socket connected: ${_socket.id}');
      _isConnected = true;
    });

    _socket.onDisconnect((_) {
      debugPrint('Socket disconnected');
      _isConnected = false;
    });

    _socket.onConnectError((err) {
      debugPrint('Socket connect error: $err');
    });

    _socket.connect();
  }

  void joinRoom(String room) {
    if (!_isConnected) _socket.connect();
    _socket.emit('join_room', room);
    debugPrint('Joining room: $room');
  }

  void on(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  void off(String event) {
    _socket.off(event);
  }
}
