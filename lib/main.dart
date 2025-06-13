// File: lib/main.dart - UPDATED dengan NotificationProvider
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import Providers
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart'; // TAMBAHAN
import 'providers/notification_provider.dart'; // TAMBAHAN

// Import Services
import 'services/transaction_service.dart';

// Import Utils
import 'utils/food_data_script.dart';
import 'utils/kitchen_ingredients_data_script.dart';
import 'utils/ramadhan_data_script.dart';

// Import semua screen - PASTIKAN SEMUA ADA
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/food_category_screen.dart';
import 'screens/news_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/creator_profile_screen.dart';
import 'screens/about_screen.dart';
import 'screens/detail_promo_screen.dart';
import 'screens/profile_update_screen.dart';
import 'screens/fruit_category_screen.dart';
import 'screens/drinks_category_screen.dart';
import 'screens/personalcare_category_screen.dart';
import 'screens/kitchen_ingredients_category_screen.dart';
import 'screens/all_categories_screen.dart';
import 'screens/ramadhan_products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase initialization dengan error handling yang lebih baik
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Initialize product data dengan error handling individual
    print('📦 Initializing product data...');
    try {
      // Initialize each data script individually to catch specific errors
      try {
        await FoodDataScript.initializeFoodProducts();
        print('✅ Food products initialized');
      } catch (e) {
        print('⚠️ Error initializing food products: $e');
      }
      
      try {
        await KitchenIngredientsDataScript.initializeKitchenIngredientsProducts();
        print('✅ Kitchen ingredients initialized');
      } catch (e) {
        print('⚠️ Error initializing kitchen ingredients: $e');
      }
      
      try {
        await RamadhanDataScript.initializeRamadhanProducts();
        print('✅ Ramadhan products initialized');
      } catch (e) {
        print('⚠️ Error initializing ramadhan products: $e');
      }
      
      print('✅ Product data initialization completed');
    } catch (e) {
      print('⚠️ General error initializing product data: $e');
    }
    
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    // App bisa tetap berjalan meskipun Firebase gagal, untuk debugging
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // URUTAN PENTING: AuthProvider harus pertama
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            try {
              print('🔐 Creating AuthProvider...');
              return AuthProvider();
            } catch (e) {
              print('❌ AuthProvider creation error: $e');
              return AuthProvider();
            }
          },
        ),
        
        // CartProvider bergantung pada auth state
        ChangeNotifierProvider<CartProvider>(
          create: (context) {
            try {
              print('🛒 Creating CartProvider...');
              return CartProvider();
            } catch (e) {
              print('❌ CartProvider creation error: $e');
              return CartProvider();
            }
          },
        ),
        
        // TAMBAHAN: ProfileProvider bergantung pada AuthProvider
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) {
            try {
              print('👤 Creating ProfileProvider...');
              return ProfileProvider();
            } catch (e) {
              print('❌ ProfileProvider creation error: $e');
              return ProfileProvider();
            }
          },
        ),
        
        // TransactionService untuk checkout
        ChangeNotifierProvider<TransactionService>(
          create: (context) {
            try {
              print('💳 Creating TransactionService...');
              return TransactionService();
            } catch (e) {
              print('❌ TransactionService creation error: $e');
              return TransactionService();
            }
          },
        ),
        
        // TAMBAHAN: NotificationProvider harus terakhir (bergantung pada AuthProvider)
        ChangeNotifierProvider<NotificationProvider>(
          create: (context) {
            try {
              print('🔔 Creating NotificationProvider...');
              final provider = NotificationProvider();
              // Jangan initialize langsung di sini, biarkan screen yang handle
              return provider;
            } catch (e) {
              print('❌ NotificationProvider creation error: $e');
              return NotificationProvider();
            }
          },
        ),
      ],
      child: MaterialApp(
        title: 'TokoKu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF2D7BEE),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D7BEE),
            brightness: Brightness.light,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF2D7BEE),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D7BEE),
              foregroundColor: Colors.white,
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
          try {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (context) => const SplashScreen());
              case '/login':
                return MaterialPageRoute(builder: (context) => const LoginScreen());
              case '/register':
                return MaterialPageRoute(builder: (context) => const RegisterScreen());
              case '/main':
                // PERBAIKAN: Handle arguments untuk MainScreen
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                  settings: RouteSettings(name: '/main', arguments: args),
                );
              case '/home':
                return MaterialPageRoute(builder: (context) => const HomeScreen());
              case '/food_category':
                return MaterialPageRoute(builder: (context) => const FoodCategoryScreen());
              case '/drinks_category':
                return MaterialPageRoute(builder: (context) => const DrinksCategoryScreen());
              case '/kitchen_ingredients_category':
                return MaterialPageRoute(builder: (context) => const KitchenIngredientsCategoryScreen());
              case '/fruit_category':
                return MaterialPageRoute(builder: (context) => const FruitCategoryScreen());
              case '/personalcare_category':
                return MaterialPageRoute(builder: (context) => const PersonalcareCategoryScreen());
              case '/all_categories':
                return MaterialPageRoute(builder: (context) => const AllCategoriesScreen());
              case '/ramadhan_products':
                return MaterialPageRoute(builder: (context) => const RamadhanProductsScreen());
              case '/news':
                return MaterialPageRoute(builder: (context) => const NewsScreen());
              case '/detail_promo':
                return MaterialPageRoute(builder: (context) => const DetailPromoScreen());
              case '/cart':
                // PERBAIHAN: Handle arguments untuk CartScreen
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                  settings: RouteSettings(name: '/cart', arguments: args),
                );
              case '/checkout':
                // PERBAIKAN: Handle arguments untuk CheckoutScreen
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (context) => const CheckoutScreen(),
                  settings: RouteSettings(name: '/checkout', arguments: args),
                );
              case '/transaction':
                // PERBAIKAN: Handle arguments untuk TransactionScreen
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (context) => const TransactionScreen(),
                  settings: RouteSettings(name: '/transaction', arguments: args),
                );
              case '/setting':
                return MaterialPageRoute(builder: (context) => const SettingScreen());
              case '/edit_profile':
                return MaterialPageRoute(builder: (context) => const ProfileUpdateScreen());
              case '/creator_profile':
                return MaterialPageRoute(builder: (context) => const CreatorProfileScreen());
              case '/about':
                return MaterialPageRoute(builder: (context) => const AboutScreen());
              default:
                return _buildErrorRoute(settings.name ?? 'Unknown');
            }
          } catch (e) {
            print('❌ Route generation error for ${settings.name}: $e');
            return _buildErrorRoute(settings.name ?? 'Unknown', error: e.toString());
          }
        },
        onUnknownRoute: (settings) {
          return _buildErrorRoute(settings.name ?? 'Unknown');
        },
      ),
    );
  }

  // Helper method untuk error route
  MaterialPageRoute _buildErrorRoute(String routeName, {String? error}) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
          backgroundColor: const Color(0xFF2D7BEE),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Halaman tidak ditemukan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Route: $routeName',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      'Error: $error',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.red[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  child: Text(
                    'Kembali ke Home',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                const SizedBox(height: 8),
                // TAMBAHAN: Debug button untuk melihat available providers
                if (error != null)
                  TextButton(
                    onPressed: () {
                      // Debug: Print available providers
                      try {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        print('✅ AuthProvider available: ${authProvider != null}');
                      } catch (e) {
                        print('❌ AuthProvider not available: $e');
                      }
                      
                      try {
                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        print('✅ CartProvider available: ${cartProvider != null}');
                      } catch (e) {
                        print('❌ CartProvider not available: $e');
                      }
                      
                      try {
                        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                        print('✅ NotificationProvider available: ${notificationProvider != null}');
                      } catch (e) {
                        print('❌ NotificationProvider not available: $e');
                      }
                      
                      try {
                        final transactionService = Provider.of<TransactionService>(context, listen: false);
                        print('✅ TransactionService available: ${transactionService != null}');
                      } catch (e) {
                        print('❌ TransactionService not available: $e');
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Check console for provider availability debug info',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Debug Providers',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.orange[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}