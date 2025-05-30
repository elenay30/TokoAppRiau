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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase initialized successfully');
    
    // Initialize product data
    print('📦 Initializing product data...');
    try {
      await Future.wait([
        FoodDataScript.initializeFoodProducts(),
        KitchenIngredientsDataScript.initializeKitchenIngredientsProducts(),
        RamadhanDataScript.initializeRamadhanProducts(),
      ]);
      print('✅ All product data initialized successfully');
    } catch (e) {
      print('⚠️ Error initializing product data: $e');
    }
    
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider harus pertama karena provider lain bergantung padanya
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        
        // CartProvider bergantung pada auth state
        ChangeNotifierProvider(create: (context) => CartProvider()),
        
        // TransactionService untuk checkout
        ChangeNotifierProvider(create: (context) => TransactionService()),
      ],
      child: MaterialApp(
        title: 'TokoKu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF2D7BEE),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF2D7BEE),
            elevation: 0,
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
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainScreen(), // PASTIKAN ROUTE INI ADA
          '/home': (context) => const HomeScreen(),
          
          // Category screens
          '/food_category': (context) => const FoodCategoryScreen(),
          '/drinks_category': (context) => const DrinksCategoryScreen(),
          '/kitchen_ingredients_category': (context) => const KitchenIngredientsCategoryScreen(),
          '/fruit_category': (context) => const FruitCategoryScreen(),
          '/personalcare_category': (context) => const PersonalcareCategoryScreen(),
          '/all_categories': (context) => const AllCategoriesScreen(),
          '/ramadhan_products': (context) => const RamadhanProductsScreen(),
          
          // News and info screens
          '/news': (context) => const NewsScreen(),
          '/detail_promo': (context) => const DetailPromoScreen(),
          
          // Transaction screens
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/transaction': (context) => const TransactionScreen(),
          
          // Setting screens
          '/setting': (context) => const SettingScreen(),
          '/edit_profile': (context) => const ProfileUpdateScreen(),
          '/creator_profile': (context) => const CreatorProfileScreen(),
          '/about': (context) => const AboutScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Page Not Found'),
                backgroundColor: const Color(0xFF2D7BEE),
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Halaman tidak ditemukan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Silakan kembali ke halaman sebelumnya.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}