// File: lib/screens/personalcare_category_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import '../utils/personalcare_data_script.dart';

class PersonalcareCategoryScreen extends StatefulWidget {
  const PersonalcareCategoryScreen({Key? key}) : super(key: key);

  @override
  State<PersonalcareCategoryScreen> createState() => _PersonalcareCategoryScreenState();
}

class _PersonalcareCategoryScreenState extends State<PersonalcareCategoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> firestoreProducts = [];
  bool isLoadingFirestore = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Method untuk inisialisasi data
  Future<void> _initializeData() async {
    try {
      print('🧴 Initializing personal care products...');
      // Pastikan data produk perawatan pribadi tersedia
      await PersonalCareDataScript.initializePersonalCareProducts();
      print('✅ Personal care products initialized');
    } catch (e) {
      print('❌ Error initializing personal care products: $e');
    } finally {
      // Load data dari Firestore
      _loadFirestoreProducts();
    }
  }

  Future<void> _loadFirestoreProducts() async {
    try {
      setState(() {
        isLoadingFirestore = true;
        firestoreProducts.clear();
      });

      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: 'Perawatan Pribadi')
          .get();

      List<Product> loadedProducts = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        bool isActive = data['isActive'] == true;
        if (!isActive) {
          continue;
        }

        try {
          Product product = Product.fromFirestore(doc);
          loadedProducts.add(product);
        } catch (e) {
          print('Error parsing product ${doc.id}: $e');
        }
      }

      setState(() {
        firestoreProducts = loadedProducts;
        isLoadingFirestore = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        isLoadingFirestore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final primaryColor = const Color(0xFF2D7BEE);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(primaryColor),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _initializeData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  horizontalPadding,
                  horizontalPadding,
                  100.0 // Add extra bottom padding to avoid FAB overlap
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPromoBanner(),
                  _buildSectionTitle(),
                  _buildProductGrid(),
                  const SizedBox(height: 20), // Additional spacing at bottom
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Better positioning
    );
  }

  // AppBar Widget
  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Perawatan Pribadi',
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.black),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Promo Banner Widget
  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 150,
      margin: const EdgeInsets.only(bottom: 20, top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[800]!, Colors.purple[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -30,
                top: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Promo Spesial',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Perawatan Pribadi',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dapatkan diskon hingga 25% untuk produk pilihan',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.spa,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Container(
            height: 18,
            width: 4,
            decoration: BoxDecoration(
              color: Colors.purple[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Produk Populer',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (firestoreProducts.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Text(
                '${firestoreProducts.length} Produk',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Product Grid Widget - IMPROVED VERSION
  Widget _buildProductGrid() {
    if (isLoadingFirestore) {
      return _buildLoadingState();
    }

    if (firestoreProducts.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7, // Slightly reduced to give more height
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: firestoreProducts.length,
      itemBuilder: (context, index) {
        final product = firestoreProducts[index];
        return _buildModernProductCard(product);
      },
    );
  }

  // Loading State Widget
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          CircularProgressIndicator(color: Colors.purple[600]),
          const SizedBox(height: 16),
          Text(
            'Memuat produk terbaru...',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.spa_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada produk perawatan',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Produk perawatan pribadi akan segera tersedia',
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await _initializeData();
            },
            icon: const Icon(Icons.refresh),
            label: Text(
              'Muat Ulang',
              style: GoogleFonts.poppins(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Floating Action Button Widget - IMPROVED POSITIONING
  Widget _buildFloatingActionButton() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16), // Add margin from bottom
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            backgroundColor: Colors.purple[600],
            elevation: 6,
            shape: const CircleBorder(),
            child: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartProvider.itemCount}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modern Product Card Widget - IMPROVED LAYOUT
  Widget _buildModernProductCard(Product product) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isInCart(product.id);
        final cartQuantity = cartProvider.getProductQuantity(product.id);

        return Container(
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
            children: [
              Expanded( // Use Expanded to prevent overflow
                flex: 3, // Give more space to image section
                child: _buildProductImageSection(product),
              ),
              const SizedBox(height: 8),
              Expanded( // Use Expanded for info section too
                flex: 2, // Less space for info section
                child: _buildProductInfoSection(product, isInCart, cartProvider, cartQuantity),
              ),
            ],
          ),
        );
      },
    );
  }

  // Product Image Section Widget - IMPROVED
  Widget _buildProductImageSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded( // Use Expanded for the image container
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: _buildProductImage(product),
                ),
              ),
              // Discount badge
              if (product.hasDiscount && product.discountPercentage != null)
                _buildDiscountBadge(product),
              // Rating badge
              if (product.rating != null && product.rating! > 0)
                _buildRatingBadge(product),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13, // Slightly smaller font
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (product.subtitle != null && product.subtitle!.isNotEmpty)
          Text(
            product.subtitle!,
            style: GoogleFonts.poppins(
              fontSize: 10, // Smaller subtitle
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  // Product Info Section Widget - OPTIMIZED
  Widget _buildProductInfoSection(Product product, bool isInCart, CartProvider cartProvider, int cartQuantity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Better spacing
      children: [
        Flexible( // Use Flexible instead of fixed sizing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rp ${product.formattedPrice}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                  fontSize: 14, // Slightly smaller
                ),
              ),
              if (product.formattedOriginalPrice != null)
                Text(
                  "Rp ${product.formattedOriginalPrice}",
                  style: GoogleFonts.poppins(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[500],
                    fontSize: 11, // Smaller crossed price
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Action button/control
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!isInCart)
              _buildAddToCartButton(product)
            else
              _buildQuantityControl(product, cartProvider, cartQuantity),
          ],
        ),
      ],
    );
  }

  // Discount Badge Widget
  Widget _buildDiscountBadge(Product product) {
    return Positioned(
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
    );
  }

  // Rating Badge Widget
  Widget _buildRatingBadge(Product product) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.amber[600],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              color: Colors.white,
              size: 10,
            ),
            const SizedBox(width: 2),
            Text(
              product.rating!.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add to Cart Button Widget
  Widget _buildAddToCartButton(Product product) {
    return InkWell(
      onTap: () => _addToCart(product),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.purple[600],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.4),
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
    );
  }

  // Product Image Widget
  Widget _buildProductImage(Product product) {
    if (product.imageUrl.startsWith('http')) {
      return Image.network(
        product.imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.spa,
                size: 32,
                color: Colors.purple[400],
              ),
            ),
          );
        },
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple[600],
          ),
        ),
      ),
    );
  }

  // Quantity Control Widget
  Widget _buildQuantityControl(Product product, CartProvider cartProvider, int quantity) {
    return Container(
      height: 28,
      width: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple[300]!),
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
                    color: quantity > 1 ? Colors.purple[700] : Colors.red,
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
                  color: Colors.purple[600],
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

  // Add to Cart Method
  void _addToCart(Product product) {
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

  // Login Dialog Method
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
              style: GoogleFonts.poppins(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }
}