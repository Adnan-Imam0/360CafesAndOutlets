import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

// Screens
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/auth/complete_profile_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/home/main_scaffold.dart';
import 'features/shop_details/shop_details_screen.dart';
import 'features/orders/checkout_screen.dart';
import 'features/orders/orders_screen.dart';
import 'features/address/manage_addresses_screen.dart';
import 'features/address/add_address_screen.dart';

// Providers
import 'features/auth/auth_provider.dart';
import 'features/home/shop_provider.dart';
import 'features/cart/cart_provider.dart';
import 'features/address/address_provider.dart';
import 'core/services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: const CustomerApp(),
    );
  }
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Rebuild router when auth state changes
    final router = GoRouter(
      refreshListenable: authProvider,
      initialLocation: '/login',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/complete-profile',
          builder: (context, state) => const CompleteProfileScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/shop/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final shopData = state.extra as Map<String, dynamic>?;
            return ShopDetailsScreen(shopId: id, shopData: shopData);
          },
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/addresses',
          builder: (context, state) => const ManageAddressesScreen(),
        ),
        GoRoute(
          path: '/add-address',
          builder: (context, state) => const AddAddressScreen(),
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authProvider.user != null;
        final isLoggingIn = state.uri.toString() == '/login';

        // If loading, don't redirect yet (optional, but safely handled by splash usually)
        if (authProvider.isLoading) return null;

        if (!isLoggedIn && !isLoggingIn) return '/login';

        if (isLoggedIn && isLoggingIn) {
          // Check profile completeness
          if (authProvider.isProfileComplete) {
            return '/home';
          } else {
            return '/complete-profile';
          }
        }
        return null;
      },
    );

    return MaterialApp.router(
      title: '360 Customer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          primary: Colors.deepOrange,
          secondary: Colors.orangeAccent,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      builder: (context, child) {
        return StreamBuilder<bool>(
          stream: ConnectivityService.instance.connectionStatus,
          initialData: true,
          builder: (context, snapshot) {
            final isConnected = snapshot.data ?? true;
            return Stack(
              children: [
                if (child != null) child,
                if (!isConnected)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'No Internet Connection',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
      routerConfig: router,
    );
  }
}
