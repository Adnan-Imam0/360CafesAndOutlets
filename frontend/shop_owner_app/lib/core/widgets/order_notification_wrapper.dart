import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/socket_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class OrderNotificationWrapper extends StatefulWidget {
  final Widget child;
  const OrderNotificationWrapper({super.key, required this.child});

  @override
  State<OrderNotificationWrapper> createState() =>
      _OrderNotificationWrapperState();
}

class _OrderNotificationWrapperState extends State<OrderNotificationWrapper> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    SocketService().orderStream.listen((order) {
      if (!mounted) return;

      _playNotificationSound();
      _showBrowserNotification(order);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('New Order Received!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${order['order_id']}'),
              const SizedBox(height: 8),
              Text('Total: Rs. ${order['total_amount']}'),
              Text('Customer: ${order['customer_name']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _audioPlayer.stop();
                Navigator.pop(context);
              },
              child: const Text('Dismiss'),
            ),
            ElevatedButton(
              onPressed: () {
                _audioPlayer.stop();
                Navigator.pop(context);
                context.go('/order-details/${order['order_id']}');
              },
              child: const Text('View Order'),
            ),
          ],
        ),
      );
    });
  }

  void _requestNotificationPermission() {
    if (kIsWeb) {
      if (html.Notification.permission == 'default') {
        html.Notification.requestPermission();
      }
    }
  }

  Future<void> _playNotificationSound() async {
    try {
      // Use a standard clear notification sound
      await _audioPlayer.play(
        UrlSource(
          'https://codeskulptor-demos.commondatastorage.googleapis.com/pang/pop.mp3',
        ),
      );
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _showBrowserNotification(Map<String, dynamic> order) {
    if (kIsWeb && html.Notification.permission == 'granted') {
      final notification = html.Notification(
        'New Order #${order['order_id']}',
        body:
            'Customer: ${order['customer_name']} - Rs. ${order['total_amount']}',
        icon: '/icons/Icon-192.png',
      );

      notification.onClick.listen((event) {
        // Try to bring window to front
        (html.window as dynamic).focus();
        notification.close();

        // Navigate using deep link ID
        context.go('/order-details/${order['order_id']}');
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
