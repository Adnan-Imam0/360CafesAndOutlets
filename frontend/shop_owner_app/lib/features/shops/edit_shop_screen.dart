import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'shop_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class EditShopScreen extends StatefulWidget {
  const EditShopScreen({super.key});

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _imageController;
  XFile? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final shop = context.read<ShopProvider>().shop!;
    _nameController = TextEditingController(text: shop['shop_name']);
    _addressController = TextEditingController(text: shop['address']);
    _phoneController = TextEditingController(text: shop['phone_number']);
    _imageController = TextEditingController(text: shop['profile_picture_url']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _imageController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final data = {
        'shop_name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'profile_picture_url': _imageController.text.trim(),
      };

      await context.read<ShopProvider>().updateShop(data, _selectedImage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop details updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Shop Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image Preview with URL input
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? NetworkImage(_selectedImage!.path)
                                  : FileImage(File(_selectedImage!.path))
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : _imageController.text.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_imageController.text),
                              fit: BoxFit.cover,
                              onError: (_, __) => const Icon(Icons.store),
                            )
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_selectedImage == null &&
                            _imageController.text.isEmpty)
                          const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          ),
                        if (_selectedImage != null ||
                            _imageController.text.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 16),
              // TextFormField(
              //   controller: _imageController,
              //   decoration: const InputDecoration(
              //     labelText: 'Profile Image URL',
              //   ),
              //   onChanged: (_) => setState(() {}),
              // ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Business Phone'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
