import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/connectivity_service.dart';
import 'auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _handleGoogleSignIn() async {
    // 1. Check Connectivity First
    final isConnected = await ConnectivityService.instance.isConnected;
    if (!isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No Internet. Please check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().signInWithGoogle();
      if (mounted) {
        // AuthProvider handles navigation state via user listener,
        // but we can explicitly check here too
        if (context.read<AuthProvider>().user != null) {
          final auth = context.read<AuthProvider>();
          if (auth.isProfileComplete) {
            context.go('/home');
          } else {
            context.go('/complete-profile');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delivery_dining,
              size: 80,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 24),
            Text(
              '360 Cafe&Outlets',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Order fresh food instantly',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 64),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.deepOrange,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
