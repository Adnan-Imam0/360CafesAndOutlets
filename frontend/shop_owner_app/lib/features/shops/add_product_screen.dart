import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'category_provider.dart';
import 'product_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:image_picker/image_picker.dart';
import 'shop_provider.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? productToEdit;
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  XFile? _selectedImage;

  String? _selectedCategoryId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      final p = widget.productToEdit!;
      _nameController.text = p['name'] ?? '';
      _descriptionController.text = p['description'] ?? '';
      _priceController.text = (p['price'] ?? 0).toString();
      _imageUrlController.text = p['image_url'] ?? '';
      _selectedCategoryId = p['category_id']?.toString();
    }

    // Fetch categories when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shop = context.read<ShopProvider>().shop;
      if (shop != null) {
        context.read<CategoryProvider>().fetchCategories(shop['shop_id']);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _imageUrlController.clear(); // Clear URL if file selected
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final shop = context.read<ShopProvider>().shop;
      if (shop == null) throw Exception('Shop not found');

      final data = {
        'shop_id': shop['shop_id'],
        'category_id': int.parse(_selectedCategoryId!),
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'image_url': _imageUrlController.text.trim().isEmpty
            ? 'https://via.placeholder.com/150'
            : _imageUrlController.text.trim(),
        'is_available': true,
      };

      if (widget.productToEdit != null) {
        await context.read<ProductProvider>().updateProduct(
          widget.productToEdit!['product_id'],
          data,
          _selectedImage,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
          context.pop();
        }
      } else {
        await context.read<ProductProvider>().addProduct(data, _selectedImage);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save product: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Category Name (e.g. Beverages)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final shop = context.read<ShopProvider>().shop;
                if (shop != null) {
                  await context.read<CategoryProvider>().createCategory(
                    shop['shop_id'],
                    controller.text.trim(),
                  );
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productToEdit != null ? 'Edit Product' : 'Add New Product',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: kIsWeb
                                ? NetworkImage(_selectedImage!.path)
                                : FileImage(File(_selectedImage!.path))
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : _imageUrlController.text.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_imageUrlController.text),
                            fit: BoxFit.cover,
                            onError: (_, __) => const Icon(Icons.broken_image),
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Placeholder if no image
                      if (_selectedImage == null &&
                          _imageUrlController.text.isEmpty)
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 50,
                                color: Colors.indigo,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Tap to add product image',
                                style: TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Edit Overlay if image exists
                      if (_selectedImage != null ||
                          _imageUrlController.text.isNotEmpty)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // const SizedBox(height: 16),
              //  TextFormField(
              //    controller: _imageUrlController,
              //    decoration: const InputDecoration(labelText: 'Image URL'),
              //    onChanged: (_) => setState(() {}),
              //  ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categoryProvider.categories
                          .map<DropdownMenuItem<String>>((c) {
                            return DropdownMenuItem(
                              value: c['category_id'].toString(),
                              child: Text(c['name']),
                            );
                          })
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: Theme.of(context).primaryColor,
                    onPressed: _showAddCategoryDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
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
                    : const Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
