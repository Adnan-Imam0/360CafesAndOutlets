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
      child: MaterialApp.router(
        title: 'Cafe 360 Customer',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            primary: Colors.deepOrange,
            secondary: Colors.orangeAccent,
          ),
          textTheme: GoogleFonts.interTextTheme(),
        ),
        routerConfig: _router,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
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
);
