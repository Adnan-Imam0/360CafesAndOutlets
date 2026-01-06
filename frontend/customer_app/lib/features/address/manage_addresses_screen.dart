import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'address_provider.dart';
import '../auth/auth_provider.dart';

class ManageAddressesScreen extends StatefulWidget {
  const ManageAddressesScreen({super.key});

  @override
  State<ManageAddressesScreen> createState() => _ManageAddressesScreenState();
}

class _ManageAddressesScreenState extends State<ManageAddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.customerProfile != null) {
        final customerId = auth.customerProfile!['customer_id'];
        context.read<AddressProvider>().fetchAddresses(customerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addressProvider.addresses.isEmpty
          ? const Center(child: Text('No addresses saved yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addressProvider.addresses.length,
              itemBuilder: (context, index) {
                final addr = addressProvider.addresses[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      _getIconForLabel(addr['address_label']),
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      addr['address_label'] ?? 'Address',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(addr['full_address'] ?? ''),
                    trailing: addr['is_default'] == true
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-address'),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}
