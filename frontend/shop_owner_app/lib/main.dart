import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/shops/shop_provider.dart';
import 'features/shops/create_shop_screen.dart';
import 'features/shops/my_shop_screen.dart';
import 'features/orders/order_provider.dart';
import 'features/orders/orders_screen.dart';
import 'features/orders/order_details_screen.dart';
import 'features/shops/product_provider.dart';
import 'features/shops/menu_screen.dart';
import 'features/shops/add_product_screen.dart';
import 'features/shops/edit_shop_screen.dart';
import 'features/auth/registration_screen.dart';
import 'features/auth/verify_email_screen.dart';
import 'features/shops/category_provider.dart';
import 'features/reviews/review_provider.dart';
import 'features/reviews/reviews_screen.dart';
import 'core/widgets/order_notification_wrapper.dart';
import 'features/dashboard/overview_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final router = GoRouter(
      refreshListenable: authProvider,
      initialLocation: '/',
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final initialized = authProvider.isInitialized;
        final location = state.uri.toString();
        final loggingIn = location == '/login' || location == '/register';

        final verified = authProvider.user?.emailVerified ?? false;

        if (!initialized) return '/splash';
        if (!loggedIn && !loggingIn) return '/login';

        // Block unverified users from accessing main app
        if (loggedIn && !verified && location != '/verify-email') {
          return '/verify-email';
        }

        // Allow verified users to enter
        if (loggedIn && verified && location == '/verify-email') {
          return '/';
        }

        if (loggedIn && (loggingIn || location == '/splash')) return '/';
        return null; // No redirect
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegistrationScreen(),
        ),
        GoRoute(
          path: '/verify-email',
          builder: (context, state) => const VerifyEmailScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) =>
              OrderNotificationWrapper(child: DashboardScreen(child: child)),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const OverviewScreen(),
            ),
            GoRoute(
              path: '/my-shop',
              builder: (context, state) => const MyShopScreen(),
            ),
            GoRoute(
              path: '/create-shop',
              builder: (context, state) => const CreateShopScreen(),
            ),
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersScreen(),
            ),
            GoRoute(
              path: '/menu',
              builder: (context, state) => const MenuScreen(),
            ),
            GoRoute(
              path: '/reviews',
              builder: (context, state) => const ReviewsScreen(),
            ),
            GoRoute(
              path: '/add-product',
              builder: (context, state) {
                final product = state.extra as Map<String, dynamic>?;
                return AddProductScreen(productToEdit: product);
              },
            ),
            GoRoute(
              path: '/edit-shop',
              builder: (context, state) => const EditShopScreen(),
            ),
            GoRoute(
              path: '/order-details/:orderId',
              builder: (context, state) {
                final orderId = int.parse(state.pathParameters['orderId']!);
                final order = state.extra as Map<String, dynamic>?;
                return OrderDetailsScreen(orderId: orderId, order: order);
              },
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Shop Owner',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          primary: Colors.deepOrange,
          secondary: Colors.orangeAccent,
          surface: Colors.grey[50]!,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          displayMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          displaySmall: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyLarge: GoogleFonts.inter(color: Colors.black87),
          bodyMedium: GoogleFonts.inter(color: Colors.black87),
          bodySmall: GoogleFonts.inter(color: Colors.black54),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Colors.deepOrange),
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
