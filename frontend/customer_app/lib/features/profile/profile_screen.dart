import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().customerProfile;
    _nameController = TextEditingController(
      text: profile?['display_name'] ?? '',
    );
    _phoneController = TextEditingController(
      text: profile?['phone_number'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().updateProfile(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _selectedImage,
      );
      setState(() {
        _isEditing = false;
        _selectedImage = null; // Clear selected image after save
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.customerProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                // Cancel edit
                setState(() {
                  _isEditing = false;
                  _selectedImage = null;
                  _nameController.text = profile?['display_name'] ?? '';
                  _phoneController.text = profile?['phone_number'] ?? '';
                });
              } else {
                // Start edit
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(profile),
          const SizedBox(height: 24),
          // Always show Address Management
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.blue),
            title: const Text('My Addresses'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/addresses'),
          ),
          const SizedBox(height: 16),

          if (!_isEditing) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ] else ...[
            _buildEditForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? profile) {
    if (profile == null) return const SizedBox.shrink();

    ImageProvider? backgroundImage;
    if (_isEditing && _selectedImage != null) {
      backgroundImage = kIsWeb
          ? NetworkImage(_selectedImage!.path)
          : FileImage(File(_selectedImage!.path)) as ImageProvider;
    } else if (profile['profile_picture_url'] != null &&
        profile['profile_picture_url'].isNotEmpty) {
      backgroundImage = NetworkImage(profile['profile_picture_url']);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _isEditing ? _pickImage : null,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepOrange.shade100,
                backgroundImage: backgroundImage,
                child: backgroundImage == null
                    ? Text(
                        (profile['display_name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (!_isEditing) ...[
          Text(
            profile['display_name'] ?? 'User',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            profile['email'] ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(profile['phone_number'] ?? 'No Phone'),
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone Number'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }
}
