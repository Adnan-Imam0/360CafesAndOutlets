import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'order_provider.dart';
import '../shops/shop_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic>? order;

  const OrderDetailsScreen({super.key, required this.orderId, this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? _order;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    if (_order == null) {
      _fetchOrder();
    }
  }

  Future<void> _fetchOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final order = await context.read<OrderProvider>().getOrderById(
        widget.orderId,
      );
      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Failed to load order: $_error')),
      );
    }

    final order = _order!;
    final status = order['status'] as String;
    final items = (order['items'] as List?) ?? [];
    final totalAmount =
        double.tryParse(order['total_amount'].toString()) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order['order_id']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Bill',
            onPressed: () => _printOrder(context),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Chip(
                label: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: _getStatusColor(status),
                side: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Section
            _buildSectionHeader('Customer Details'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepOrange.shade100,
                        child: Text(
                          (order['customer_name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                      title: Text(
                        order['customer_name'] ?? 'Unknown Customer',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Placed on ${_formatDate(order['created_at'])}',
                      ),
                    ),
                    const Divider(),
                    _buildContactRow(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: order['customer_phone'] ?? 'No Phone',
                      onTap: () => _launchPhone(order['customer_phone']),
                    ),
                    const SizedBox(height: 12),
                    _buildContactRow(
                      icon: Icons.location_on,
                      title: 'Delivery Address',
                      value: order['delivery_address'] ?? 'No Address',
                      isMultiline: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Items Section
            _buildSectionHeader('Order Items'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(
                      item['name'] ?? 'Product',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item['quantity']}x',
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    trailing: Text(
                      'Rs. ${item['price']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Payment Section
            _buildSectionHeader('Payment'),
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rs. ${totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100), // Space for FABs
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildActionButtons(context, order),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    bool isMultiline = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: isMultiline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: onTap != null
                          ? Colors.blue.shade700
                          : Colors.black87,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : null,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildActionButtons(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    final status = order['status'] as String;
    final orderId = order['order_id'] as int;

    if (status == 'pending') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _updateStatus(context, orderId, 'rejected'),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject Order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(context, orderId, 'accepted'),
                  icon: const Icon(Icons.check),
                  label: const Text('Accept Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (['accepted', 'preparing', 'ready'].contains(status)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showStatusSheet(context, orderId, status),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5), // Blue
          ),
          child: const Text('Update Status'),
        ),
      );
    }

    return null;
  }

  Future<void> _updateStatus(
    BuildContext context,
    int orderId,
    String status,
  ) async {
    debugPrint('Updating status for Order $orderId to $status');
    try {
      await context.read<OrderProvider>().updateStatus(orderId, status);
      debugPrint('Update successful. Checking mounted...');
      if (context.mounted) {
        debugPrint('Context mounted. Going to /orders...');
        context.go('/orders'); // Force navigation to orders list
      } else {
        debugPrint('Context NOT mounted.');
      }
    } catch (e) {
      debugPrint('Update failed with error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }

  void _showStatusSheet(
    BuildContext context,
    int orderId,
    String currentStatus,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Update Order Status',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (currentStatus != 'preparing')
              ListTile(
                leading: const Icon(Icons.kitchen),
                title: const Text('Mark as Preparing'),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(context, orderId, 'preparing');
                },
              ),
            if (currentStatus != 'ready')
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('Mark as Ready for Pickup'),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(context, orderId, 'ready');
                },
              ),
            if (currentStatus != 'delivered')
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Mark as Delivered'),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(context, orderId, 'delivered');
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String? phone) async {
    if (phone == null) return;
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _printOrder(BuildContext context) async {
    final doc = pw.Document();

    final items = (_order!['items'] as List?) ?? [];
    final totalAmount =
        double.tryParse(_order!['total_amount'].toString()) ?? 0.0;
    final dateStr = _formatDate(_order!['created_at']);

    final shop = context.read<ShopProvider>().shop;
    final shopName = shop?['shop_name'] ?? 'Cafe 360';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  shopName,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Order #${_order!['order_id']}'),
              pw.Text('Date: $dateStr'),
              pw.Divider(),
              pw.Text('Customer: ${_order!['customer_name']}'),
              pw.Text('Phone: ${_order!['customer_phone']}'),
              pw.Text('Address: ${_order!['delivery_address']}'),
              pw.Divider(),
              pw.Text(
                'Items:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              ...items.map(
                (item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text('${item["quantity"]}x ${item["name"]}'),
                    ),
                    pw.Text('Rs. ${item["price"]}'),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Rs. ${totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Thank you for your order!',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Order_${_order!['order_id']}_Receipt',
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown Date';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(dateStr));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.indigo;
      case 'ready':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
