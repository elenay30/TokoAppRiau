// File: lib/main.dart - PASTIKAN IMPORT INI ADA
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import Providers
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';

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
    // PERBAIKAN: Firebase initialization dengan error handling yang lebih baik
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // PERBAIKAN: Initialize product data dengan error handling individual
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
        // PERBAIKAN: AuthProvider dengan error handling
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            try {
              return AuthProvider();
            } catch (e) {
              print('❌ AuthProvider creation error: $e');
              // Return basic AuthProvider yang tidak akan crash
              return AuthProvider();
            }
          },
        ),
        
        // CartProvider bergantung pada auth state
        ChangeNotifierProvider<CartProvider>(
          create: (context) {
            try {
              return CartProvider();
            } catch (e) {
              print('❌ CartProvider creation error: $e');
              return CartProvider();
            }
          },
        ),
        
        // TransactionService untuk checkout
        ChangeNotifierProvider<TransactionService>(
          create: (context) {
            try {
              return TransactionService();
            } catch (e) {
              print('❌ TransactionService creation error: $e');
              return TransactionService();
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
          // PERBAIKAN: Tambahkan useMaterial3 untuk compatibility
          useMaterial3: true,
          // PERBAIKAN: Improve color scheme
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
        // PERBAIKAN: Route handling dengan error handling
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
                return MaterialPageRoute(builder: (context) => const MainScreen());
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
                return MaterialPageRoute(builder: (context) => const CartScreen());
              case '/checkout':
                return MaterialPageRoute(builder: (context) => const CheckoutScreen());
              case '/transaction':
                return MaterialPageRoute(builder: (context) => const TransactionScreen());
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

  // PERBAIKAN: Helper method untuk error route
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
                  Text(
                    'Error: $error',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.red[400],
                    ),
                    textAlign: TextAlign.center,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}