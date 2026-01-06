import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'address_provider.dart';
import '../auth/auth_provider.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController(text: 'Home');
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Lahore'); // Default
  bool _isLoading = false;

  final List<String> _labels = ['Home', 'Work', 'Other'];

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      if (auth.customerProfile == null) throw Exception('User not loaded');

      final addressData = {
        'customer_id': auth.customerProfile!['customer_id'],
        'address_label': _labelController.text,
        'full_address': _addressController.text,
        'city': _cityController.text,
        'is_default': false, // Can expand later
        'latitude': 0.0, // Placeholder
        'longitude': 0.0, // Placeholder
      };

      await context.read<AddressProvider>().addAddress(addressData);
      if (mounted) {
        context.pop(); // Go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Address')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _labels.contains(_labelController.text)
                    ? _labelController.text
                    : 'Other',
                items: _labels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _labelController.text = val!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Full Address',
                  hintText: 'House 123, Street 4, Phase 5',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
