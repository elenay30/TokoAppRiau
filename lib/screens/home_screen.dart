// File: lib/screens/home_screen.dart - Updated dengan Real-time Notifications
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'food_category_screen.dart';
import 'news_screen.dart';
import 'all_categories_screen.dart';
import 'ramadhan_products_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart'; // TAMBAHAN: Import NotificationProvider
import 'kitchen_ingredients_category_screen.dart';
import 'drinks_category_screen.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
// TAMBAHAN: Import script Ramadhan
import '../utils/ramadhan_data_script.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;
  final ProductService _productService = ProductService();

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Product> _searchResults = [];

  // TAMBAHAN: Method untuk initialize data Ramadhan
  Future<void> _initializeRamadhanData() async {
    try {
      await RamadhanDataScript.initializeRamadhanProducts();
    } catch (e) {
      print('Error initializing Ramadhan data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initializeRamadhanData();
    
    // TAMBAHAN: Initialize notifications saat HomeScreen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn) {
        context.read<NotificationProvider>().initializeNotifications();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  String _getConsistentUserName(AuthProvider authProvider) {
    if (authProvider.userModel != null &&
        authProvider.userModel!.nama.isNotEmpty) {
      String firestoreName = authProvider.userModel!.nama.trim();
      if (firestoreName != 'User' && firestoreName.isNotEmpty) {
        return firestoreName;
      }
    }

    if (authProvider.firebaseUser?.displayName != null &&
        authProvider.firebaseUser!.displayName!.isNotEmpty) {
      String displayName = authProvider.firebaseUser!.displayName!.trim();
      if (displayName != 'User' && displayName.isNotEmpty) {
        return displayName;
      }
    }

    if (authProvider.firebaseUser?.email != null) {
      String emailUser = authProvider.firebaseUser!.email!.split('@')[0];
      if (emailUser.isNotEmpty) {
        return emailUser;
      }
    }
    return 'User';
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSearching = true;
      });
    }

    try {
      final results = await _productService.searchProducts(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      print('Error searching products: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    if (mounted) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;

    final primaryColor = const Color(0xFF2D7BEE);
    final secondaryColor = const Color(0xFFE3F2FD);
    final accentColor = Colors.amber;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        String userName = _getConsistentUserName(authProvider);

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Column(
              children: [
                // Header with profile and notification
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: _buildProfileImage(
                                authProvider,
                                userName,
                                isSmallScreen ? 18 : 22,
                                primaryColor,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 10 : 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Halo, $userName!',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Pesan kebutuhan favorit kamu',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          // UPDATED: Real-time Notification Button
                          Consumer<NotificationProvider>(
                            builder: (context, notificationProvider, child) {
                              return Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: secondaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.notifications_none_rounded,
                                        color: primaryColor,
                                      ),
                                      iconSize: isSmallScreen ? 22 : 24,
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const NewsScreen(
                                              showBackButton: true,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // UPDATED: Real-time unread count badge
                                  if (notificationProvider.unreadCount > 0)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${notificationProvider.unreadCount > 99 ? '99+' : notificationProvider.unreadCount}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari produk favorit...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.search, color: primaryColor),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12.0 : 15.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Content berdasarkan status pencarian
                Expanded(
                  child: _isSearching
                      ? _buildSearchResults(accentColor, horizontalPadding)
                      : _buildNormalContent(
                          screenWidth,
                          horizontalPadding,
                          primaryColor,
                          secondaryColor,
                          accentColor,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(Color accentColor, double horizontalPadding) {
    if (_searchResults.isEmpty && _isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Produk tidak ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba kata kunci lain',
              style: GoogleFonts.poppins(
                fontSize: 14, 
                color: Colors.grey[500]
              ),
            ),
          ],
        ),
      );
    }
    if (_searchResults.isEmpty && !_isSearching) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Container(
                  height: 18,
                  width: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Hasil Pencarian (${_searchResults.length})',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final product = _searchResults[index];
                return _buildProductItem(product, accentColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: _buildProductItem - HAPUS NAVIGASI, ADD TO CART LANGSUNG
  Widget _buildProductItem(Product product, Color accentColor) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isInCart(product.id);
        final cartQuantity = cartProvider.getProductQuantity(product.id);

        return Container(
          // HAPUS GestureDetector - TIDAK ADA AKSI SAAT KLIK PRODUK
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 30,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (product.hasDiscount && product.discountPercentage != null)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[600],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                "-${(product.discountPercentage! * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (product.category != null)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(product.category!),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                product.category!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "Rp ${product.formattedPrice}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (product.formattedOriginalPrice != null)
                          Expanded(
                            child: Text(
                              "Rp ${product.formattedOriginalPrice}",
                              style: GoogleFonts.poppins(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        SizedBox(width: product.formattedOriginalPrice != null ? 4 : 0),
                        
                        // Add button or quantity control
                        if (!isInCart)
                          InkWell(
                            onTap: () => _addToCartNew(product),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.4),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          )
                        else
                          _buildQuantityControl(product, cartProvider, cartQuantity),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ramadhan':
        return Colors.amber;
      case 'foods':
      case 'food':
        return Colors.blue;
      case 'drinks':
      case 'drink':
        return Colors.green[700]!;
      case 'kitchen & ingredients':
      case 'kitchen':
        return Colors.orange[800]!;
      default:
        return Colors.purple;
    }
  }

  Widget _buildNormalContent(
    double screenWidth,
    double horizontalPadding,
    Color primaryColor,
    Color secondaryColor,
    Color accentColor,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Banner Carousel with Indicators
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Column(
              children: [
                SizedBox(
                  height: screenWidth * 0.35,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _banners.length,
                    onPageChanged: (index) {
                      if (mounted) {
                        setState(() {
                          _currentBannerIndex = index;
                        });
                      }
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            _banners[index]['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: index % 2 == 0
                                        ? [
                                            primaryColor,
                                            primaryColor.withOpacity(0.7),
                                          ]
                                        : [
                                            accentColor,
                                            accentColor.withOpacity(0.7),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _banners[index]['icon'],
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _banners[index]['title'],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _banners.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 8,
                      width: _currentBannerIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentBannerIndex == index
                            ? primaryColor
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Shopping Category Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 18,
                      width: 4,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Shopping Category',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllCategoriesScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('Lihat Semua'),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Category Boxes
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - (12 * 2)) / 3;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/food_category');
                      },
                      child: _buildModernCategoryItem(
                        'Foods',
                        'assets/images/foods.png',
                        Colors.blue[100]!,
                        primaryColor,
                        width: itemWidth,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/kitchen_ingredients_category');
                      },
                      child: _buildModernCategoryItem(
                        'Kitchen &\nIngredients',
                        'assets/images/dapur.png',
                        Colors.orange[100]!,
                        Colors.orange[800]!,
                        width: itemWidth,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/drinks_category');
                      },
                      child: _buildModernCategoryItem(
                        'Drinks',
                        'assets/images/minum.png',
                        Colors.green[100]!,
                        Colors.green[800]!,
                        width: itemWidth,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Festival Ramadhan Section - Firebase Stream
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 18,
                          width: 4,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Festival Ramadhan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/ramadhan_products');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: accentColor,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('Lihat Semua'),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: accentColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 230,
                  child: StreamBuilder<List<Product>>(
                    stream: _productService.getProductsByCategory('Ramadhan'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        print("Error Stream Ramadhan: ${snapshot.error}");
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Error memuat produk: ${snapshot.error}', 
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600], 
                                  fontSize: 14
                                )
                              ),
                            ],
                          ),
                        );
                      }
                      final products = snapshot.data ?? [];
                      if (products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada produk Ramadhan', 
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600], 
                                  fontSize: 14
                                )
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _buildModernProductItem(product, accentColor);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80), // Space for navbar
        ],
      ),
    );
  }

  // Daftar banner tetap sama
  final List<Map<String, dynamic>> _banners = [
    {'image': 'assets/images/banner1.png', 'title': 'SALE UP TO 50%', 'icon': Icons.shopping_bag_outlined},
    {'image': 'assets/images/banner2.png', 'title': 'SPECIAL OFFERS', 'icon': Icons.local_offer_outlined},
    {'image': 'assets/images/banner1.png', 'title': 'NEW ARRIVALS', 'icon': Icons.new_releases_outlined},
  ];

  Widget _buildProfileImage(
    AuthProvider authProvider,
    String userName,
    double radius,
    Color primaryColor,
  ) {
    try {
      String? photoUrl;
      if (authProvider.userModel?.fotoProfilPath != null &&
          authProvider.userModel!.fotoProfilPath!.isNotEmpty) {
        photoUrl = authProvider.userModel!.fotoProfilPath;
      } 
      else if (authProvider.firebaseUser?.photoURL != null &&
          authProvider.firebaseUser!.photoURL!.isNotEmpty) {
        photoUrl = authProvider.firebaseUser!.photoURL;
      }

      if (photoUrl != null) {
        if (photoUrl.startsWith('http')) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFFE3F2FD),
            backgroundImage: NetworkImage(photoUrl),
            onBackgroundImageError: (_, __) { /* Handle error jika perlu */ },
          );
        } else if (photoUrl.startsWith('assets/')) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFFE3F2FD),
            backgroundImage: AssetImage(photoUrl),
            onBackgroundImageError: (_, __) { /* Handle error jika perlu */ },
          );
        } else if (File(photoUrl).existsSync()){ 
          return CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFFE3F2FD),
            backgroundImage: FileImage(File(photoUrl)),
            onBackgroundImageError: (_, __) { /* Handle error jika perlu */ },
          );
        }
      }
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE3F2FD),
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : "?",
          style: GoogleFonts.poppins(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: radius,
          ),
        ),
      );
    } catch (e) {
      print("Error building profile image: $e");
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE3F2FD),
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : "?",
          style: GoogleFonts.poppins(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: radius,
          ),
        ),
      );
    }
  }

  Widget _buildModernCategoryItem(
    String name,
    String imagePath,
    Color backgroundColor,
    Color iconColor, {
    required double width,
  }) {
    return Container(
      width: width,
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              imagePath,
              height: 30,
              width: 30,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.category, color: iconColor, size: 24);
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.black87,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: _buildModernProductItem - HAPUS NAVIGASI, ADD TO CART LANGSUNG
  Widget _buildModernProductItem(Product product, Color accentColor) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isInCart(product.id);
        final cartQuantity = cartProvider.getProductQuantity(product.id);

        return Container(
          // HAPUS GestureDetector - TIDAK ADA AKSI SAAT KLIK PRODUK
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 30,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (product.hasDiscount && product.discountPercentage != null)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[600],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                "-${(product.discountPercentage! * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "Rp ${product.formattedPrice}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (product.formattedOriginalPrice != null)
                          Expanded(
                            child: Text(
                              "Rp ${product.formattedOriginalPrice}",
                              style: GoogleFonts.poppins(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        SizedBox(width: product.formattedOriginalPrice != null ? 4 : 0),
                        
                        // Add button or quantity control
                        if (!isInCart)
                          InkWell(
                            onTap: () => _addToCartNew(product),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.4),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          )
                        else
                          _buildQuantityControl(product, cartProvider, cartQuantity),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Quantity Control Widget
  Widget _buildQuantityControl(Product product, CartProvider cartProvider, int quantity) {
    return Container(
      height: 28,
      width: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber[300]!),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (quantity > 1) {
                  cartProvider.updateQuantity(product.id, quantity - 1);
                } else {
                  cartProvider.removeFromCart(product.id);
                }
              },
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: Center(
                  child: Icon(
                    quantity > 1 ? Icons.remove : Icons.delete_outline,
                    size: 14,
                    color: quantity > 1 ? Colors.amber[700] : Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 24,
            height: 28,
            color: Colors.white,
            child: Center(
              child: Text(
                quantity.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                cartProvider.updateQuantity(product.id, quantity + 1);
              },
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.amber[600],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method _addToCartNew
  void _addToCartNew(Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    cartProvider.addProduct(product, quantity: 1);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ ${product.name} ditambahkan ke keranjang!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'LIHAT',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  // Login Dialog
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Login Diperlukan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Silakan login terlebih dahulu untuk menambahkan produk ke keranjang.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: Text(
              'Login',
              style: GoogleFonts.poppins(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}