import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'shop_provider.dart';
import '../auth/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  XFile? _selectedImage;

  // Owner Details
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _personalPhoneController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _ownerFormKey = GlobalKey<FormState>();

  // Shop Details
  final _shopNameController = TextEditingController();
  String? _selectedShopType; // Changed from Controller to String
  final _shopAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _shopFormKey = GlobalKey<FormState>();

  // Agreement
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cnicController.dispose();
    _personalPhoneController.dispose();
    _permanentAddressController.dispose();
    _shopNameController.dispose();
    // _shopTypeController removed
    _shopAddressController.dispose();
    _businessPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _submit() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms and Conditions'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final ownerId = authProvider.user?.uid ?? '';
      final email = authProvider.user?.email ?? '';

      final data = {
        'owner_id': ownerId,
        'email': email,
        // Owner Details
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'cnic': _cnicController.text.trim(),
        'personal_phone': _personalPhoneController.text.trim(),
        'permanent_address': _permanentAddressController.text.trim(),
        // Shop Details
        'shop_name': _shopNameController.text.trim(),
        'shop_type': _selectedShopType,
        'address': _shopAddressController.text.trim(),
        'phone_number': _businessPhoneController.text.trim(),
        'profile_picture_url': 'https://via.placeholder.com/150',
        'status': 'pending_approval', // Explicit status
      };

      await context.read<ShopProvider>().createShop(data, _selectedImage);
      if (mounted) {
        context.go('/my-shop');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application Submitted for Approval!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_ownerFormKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_shopFormKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Application')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            margin: const EdgeInsets.all(24),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              margin: EdgeInsets.zero,
              elevation: 0, // Remove stepper internal elevation
              onStepContinue: _nextStep,
              onStepCancel: _prevStep,
              controlsBuilder: (context, details) {
                final isLastStep = _currentStep == 2;
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : details.onStepContinue,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isLastStep ? 'Submit Application' : 'Next',
                                ),
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : details.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: Text(
                    'Owner Information',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  content: Form(
                    key: _ownerFormKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cnicController,
                          decoration: const InputDecoration(
                            labelText: 'CNIC (without dashes)',
                            helperText: 'e.g. 1234512345671',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length != 13) return 'CNIC must be 13 digits';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _personalPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Personal Phone',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _permanentAddressController,
                          decoration: const InputDecoration(
                            labelText: 'Permanent Address',
                          ),
                          maxLines: 2,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Shop Details'),
                  content: Form(
                    key: _shopFormKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: _selectedImage == null
                                  ? Border.all(color: Colors.grey)
                                  : null,
                              image: _selectedImage != null
                                  ? DecorationImage(
                                      image: kIsWeb
                                          ? NetworkImage(_selectedImage!.path)
                                          : FileImage(
                                                  File(_selectedImage!.path),
                                                )
                                                as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _selectedImage == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Shop Logo',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _shopNameController,
                          decoration: const InputDecoration(
                            labelText: 'Shop Name',
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedShopType,
                          decoration: const InputDecoration(
                            labelText: 'Shop Type',
                          ),
                          items: ['Cafe', 'Outlet', 'Restaurant', 'Bakery']
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedShopType = val),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _businessPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Business Phone',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _shopAddressController,
                          decoration: const InputDecoration(
                            labelText: 'Shop Address',
                          ),
                          maxLines: 2,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Review & Agree'),
                  content: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Terms and Conditions (Mock):\n\n'
                          '1. You agree to operate your shop legally.\n'
                          '2. You will provide accurate information.\n'
                          '3. You are responsible for all orders.\n'
                          '4. Cafe360 reserves the right to suspend accounts.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text(
                          'I agree to the Terms and Conditions',
                        ),
                        value: _agreedToTerms,
                        onChanged: (v) => setState(() => _agreedToTerms = v!),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
