// File: lib/screens/checkout_screen.dart - COMPLETE FIXED VERSION
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/transaction_service.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart' as models;
import '../providers/auth_provider.dart';
import '../screens/main_screen.dart';
import 'package:intl/intl.dart';
// TAMBAHAN: Import untuk OpenStreetMap
import '../widgets/openstreetmap_address_picker.dart';
import 'package:latlong2/latlong.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedShippingOption = 'Standard';
  String _selectedPaymentMethod = 'Transfer Bank';
  String _selectedBank = '';
  bool _isProcessingPayment = false;
  String _deliveryAddress = '';
  bool _isPaymentCompleted = false; // Flag untuk mencegah auto-redirect ke cart

  String _contactPhone = '';
  String _contactEmail = '';

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  void _initializeUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.userModel != null) {
      setState(() {
        _contactPhone = authProvider.userModel!.telepon.trim().isNotEmpty
            ? authProvider.userModel!.telepon.trim()
            : '+6281000000';
        _contactEmail = authProvider.userModel!.email.trim().isNotEmpty
            ? authProvider.userModel!.email.trim()
            : 'emailsample@example.com';
        
        _deliveryAddress = authProvider.userModel!.alamat?.trim().isNotEmpty == true
            ? authProvider.userModel!.alamat!.trim()
            : '';
            
        _phoneController.text = _contactPhone;
        _emailController.text = _contactEmail;
        _addressController.text = _deliveryAddress;
      });
      
      print('🏠 Alamat dimuat dari database: "$_deliveryAddress"');
    } else {
      setState(() {
        _contactPhone = '+6281000000';
        _contactEmail = 'emailsample@example.com';
        _deliveryAddress = '';
        _phoneController.text = _contactPhone;
        _emailController.text = _contactEmail;
        _addressController.text = _deliveryAddress;
      });
      
      print('⚠️ User belum login, menggunakan alamat kosong');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments.containsKey('address')) {
      String routeAddress = arguments['address'] as String? ?? '';
      if (_deliveryAddress.isEmpty && routeAddress.isNotEmpty) {
        setState(() {
          _deliveryAddress = routeAddress;
          _addressController.text = _deliveryAddress;
        });
        print('🏠 Menggunakan alamat dari route: "$routeAddress"');
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2D7BEE);
    final secondaryColor = const Color(0xFFFF8C00);

    return Consumer3<CartProvider, TransactionService, AuthProvider>(
      builder: (context, cartProvider, transactionService, authProvider, child) {
        // FIXED: Hanya redirect ke cart jika cart kosong DAN payment belum selesai
        if (cartProvider.items.isEmpty && !cartProvider.isLoading && !_isPaymentCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/cart');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        double cartTotal = cartProvider.totalAmount;
        double shippingCost = _selectedShippingOption == 'Express' ? 12000.0 : 0.0;
        double finalTotalAmount = cartTotal + shippingCost;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: primaryColor,
                  size: 16,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Checkout',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: cartProvider.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        'Memuat data keranjang...',
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Background decorations
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -100,
                      left: -100,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondaryColor.withOpacity(0.05),
                        ),
                      ),
                    ),
                    
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 80),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle("Order Summary", primaryColor),
                                  const SizedBox(height: 12),
                                  _buildOrderSummaryBadge(cartProvider, primaryColor),
                                  const SizedBox(height: 16),
                                  _buildCartItemsList(cartProvider),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle("Shipping Address", primaryColor),
                                  const SizedBox(height: 12),
                                  _buildAddressCard(primaryColor, authProvider),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle("Contact Information", primaryColor),
                                  const SizedBox(height: 12),
                                  _buildContactCard(secondaryColor, authProvider),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle("Shipping Options", primaryColor),
                                  const SizedBox(height: 12),
                                  _buildShippingOptions(primaryColor),
                                  const SizedBox(height: 8),
                                  _buildEstimationInfo(),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle("Payment Method", primaryColor),
                                  const SizedBox(height: 12),
                                  _buildPaymentOptions(primaryColor),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        if (cartProvider.items.isNotEmpty)
                          _buildBottomPaymentBar(
                            finalTotalAmount,
                            primaryColor,
                            cartProvider,
                            transactionService,
                            authProvider,
                          ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  // IMPROVED: Process Payment Method dengan modal sukses yang tidak bisa di-dismiss
  Future<void> _processPayment(
    double finalTotalAmount,
    CartProvider cartProvider,
    TransactionService transactionService,
    AuthProvider authProvider,
    Color primaryColor,
  ) async {
    if (!authProvider.isLoggedIn || authProvider.firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda harus login untuk melanjutkan.")),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      print('🛒 Creating transaction...');
      print('  - Total: $finalTotalAmount');
      print('  - Items: ${cartProvider.items.length}');
      print('  - Address: $_deliveryAddress');
      print('  - Payment: $_selectedPaymentMethod');
      
      // STEP 1: Create Transaction
      String? transactionId = await transactionService.createTransaction(
        items: cartProvider.items,
        totalAmount: finalTotalAmount,
        userId: authProvider.firebaseUser!.uid,
        shippingAddress: _deliveryAddress,
        paymentMethod: "$_selectedPaymentMethod${_selectedBank.isNotEmpty ? ' - $_selectedBank' : ''}",
        status: _selectedPaymentMethod == 'COD' 
            ? models.TransactionStatus.pending 
            : models.TransactionStatus.pending,
      );

      if (transactionId != null) {
        print('✅ Transaction created successfully: $transactionId');
        
        // STEP 2: Set payment completed flag SEBELUM clear cart
        setState(() {
          _isPaymentCompleted = true;
        });
        
        // STEP 3: Refresh Transaction List
        print('🔄 Refreshing transaction list...');
        await transactionService.fetchUserTransactions();
        print('✅ Transaction list refreshed');
        
        // STEP 4: Clear Cart SETELAH transaction berhasil
        await cartProvider.clearCart();
        print('✅ Cart cleared');
        
        if (mounted) {
          // STEP 5: Show Success Modal yang tidak bisa di-dismiss
          _showSuccessModal(context, primaryColor, transactionId, transactionService);
        }
      } else {
        print('❌ Transaction creation failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text("Gagal membuat pesanan. Coba lagi.", style: GoogleFonts.poppins()),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error processing payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Error: ${e.toString()}",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

void _showSuccessModal(
  BuildContext context, 
  Color primaryColor, 
  String transactionId,
  TransactionService transactionService,
) {
  String paymentMethod = _selectedPaymentMethod;
  String additionalInfo = '';
  
  if (_selectedPaymentMethod == 'Transfer Bank' && _selectedBank.isNotEmpty) {
    additionalInfo = 'via $_selectedBank';
  } else if (_selectedPaymentMethod == 'COD') {
    additionalInfo = 'Bayar saat barang tiba';
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                primaryColor.withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.2),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 55,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 28),
              
              // Success Title
              Text(
                '🎉 Pembayaran Berhasil!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'Pesanan Anda telah berhasil diproses',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Transaction ID Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'ID Pesanan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${transactionId.length > 8 ? transactionId.substring(0, 8) : transactionId}...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              
              // Action Buttons
              Column(
                children: [
                  // Primary Button - Lihat Pesanan (ke Transaction Screen)
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        print('🔄 Navigating to Orders tab with refresh');
                        
                        // FIXED: Close dialog first
                        Navigator.of(context).pop();
                        
                        // Force refresh transaction data
                        await transactionService.fetchUserTransactions();
                        
                        // Navigate to main screen and programmatically switch to Orders tab
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                            settings: RouteSettings(
                              arguments: {
                                'selectedIndex': 2, // Orders tab
                                'forceRefresh': true,
                              }
                            ),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                      label: Text(
                        'Lihat Pesanan Saya',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  // Secondary Button - Kembali Belanja (ke Home)
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        print('🔄 Navigating to home screen');
                        
                        Navigator.of(context).pop();
                        
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                            settings: const RouteSettings(
                              arguments: {'selectedIndex': 0}
                            ),
                          ),
                          (route) => false,
                        );
                      },
                      icon: Icon(
                        Icons.shopping_bag_outlined, 
                        color: primaryColor,
                        size: 20,
                      ),
                      label: Text(
                        'Lanjut Belanja',
                        style: GoogleFonts.poppins(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  // Rest of the methods remain the same...
  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryBadge(CartProvider cartProvider, Color primaryColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 16, color: primaryColor),
              const SizedBox(width: 4),
              Text(
                "${cartProvider.itemCount} items",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemsList(CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: cartProvider.items.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  "Keranjang belanja kosong.",
                  style: GoogleFonts.poppins(),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartProvider.items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final item = cartProvider.items[index];
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildProductImage(item),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.subtitle.isNotEmpty)
                              Text(
                                item.subtitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              "Rp${item.price.toStringAsFixed(0)}",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Rp${(item.price * item.quantity).toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF2D7BEE),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAddressCard(Color primaryColor, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delivery Address",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _deliveryAddress.isNotEmpty
                      ? _deliveryAddress
                      : "Alamat pengiriman belum diatur.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showEditAddressDialog(context, primaryColor, authProvider),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_outlined,
                color: primaryColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Color secondaryColor, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.phone_outlined,
              color: secondaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Contact",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$_contactPhone\n$_contactEmail",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showEditContactDialog(context, secondaryColor, authProvider),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_outlined,
                color: secondaryColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOptions(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildShippingOption(
            label: 'Standard',
            description: '1-3 days',
            price: 'FREE',
            isSelected: _selectedShippingOption == 'Standard',
            primaryColor: primaryColor,
            onTap: () => setState(() => _selectedShippingOption = 'Standard'),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildShippingOption(
            label: 'Express',
            description: 'same day',
            price: 'Rp12.000',
            isSelected: _selectedShippingOption == 'Express',
            primaryColor: primaryColor,
            onTap: () => setState(() => _selectedShippingOption = 'Express'),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption({
    required String label,
    required String description,
    required String price,
    required bool isSelected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
       child: Row(
         children: [
           Container(
             width: 24,
             height: 24,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               border: Border.all(
                 color: isSelected ? primaryColor : Colors.grey[400]!,
                 width: 2,
               ),
             ),
             child: isSelected
                 ? Center(
                     child: Container(
                       width: 12,
                       height: 12,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: primaryColor,
                       ),
                     ),
                   )
                 : const SizedBox(),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     Text(
                       'Pengiriman $label',
                       style: GoogleFonts.poppins(
                         fontWeight: FontWeight.w600,
                         fontSize: 14,
                         color: Colors.black87,
                       ),
                     ),
                     const SizedBox(width: 6),
                     Container(
                       padding: const EdgeInsets.symmetric(
                         horizontal: 6,
                         vertical: 2,
                       ),
                       decoration: BoxDecoration(
                         color: isSelected
                             ? primaryColor.withOpacity(0.1)
                             : Colors.grey[100],
                         borderRadius: BorderRadius.circular(4),
                       ),
                       child: Text(
                         description,
                         style: GoogleFonts.poppins(
                           fontSize: 11,
                           fontWeight: FontWeight.w500,
                           color: isSelected ? primaryColor : Colors.grey[600],
                         ),
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 2),
                 Text(
                   label == 'Standard'
                       ? 'Pengiriman reguler'
                       : 'Pengiriman cepat di hari yang sama',
                   style: GoogleFonts.poppins(
                     fontSize: 12,
                     color: Colors.grey[600],
                   ),
                 ),
               ],
             ),
           ),
           Text(
             price,
             style: GoogleFonts.poppins(
               fontWeight: FontWeight.w600,
               fontSize: 14,
               color: isSelected ? primaryColor : Colors.black87,
             ),
           ),
         ],
       ),
     ),
   );
 }

 Widget _buildEstimationInfo() {
   return Padding(
     padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
     child: Row(
       children: [
         Icon(
           Icons.calendar_today_outlined,
           size: 14,
           color: Colors.grey[600],
         ),
         const SizedBox(width: 8),
         Text(
           'Estimasi tiba: 2-4 hari kerja',
           style: GoogleFonts.poppins(
             fontSize: 12,
             color: Colors.grey[600],
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildPaymentOptions(Color primaryColor) {
   return Container(
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.circular(16),
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.05),
           blurRadius: 10,
           offset: const Offset(0, 2),
         ),
       ],
     ),
     child: Column(
       children: [
         _buildPaymentOption(
           label: 'Transfer Bank',
           description: _selectedBank.isNotEmpty ? _selectedBank : 'Pilih bank',
           icon: Icons.account_balance_outlined,
           isSelected: _selectedPaymentMethod == 'Transfer Bank',
           primaryColor: primaryColor,
           onTap: () {
             setState(() => _selectedPaymentMethod = 'Transfer Bank');
             _showBankSelectionDialog(context, primaryColor);
           },
         ),
         Divider(height: 1, color: Colors.grey[200]),
         _buildPaymentOption(
           label: 'Cash on Delivery (COD)',
           description: 'Bayar saat barang tiba',
           icon: Icons.payments_outlined,
           isSelected: _selectedPaymentMethod == 'COD',
           primaryColor: primaryColor,
           onTap: () {
             setState(() {
               _selectedPaymentMethod = 'COD';
               _selectedBank = '';
             });
           },
         ),
       ],
     ),
   );
 }

 Widget _buildPaymentOption({
   required String label,
   required String description,
   required IconData icon,
   required bool isSelected,
   required Color primaryColor,
   required VoidCallback onTap,
 }) {
   return InkWell(
     onTap: onTap,
     child: Padding(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
       child: Row(
         children: [
           Container(
             width: 24,
             height: 24,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               border: Border.all(
                 color: isSelected ? primaryColor : Colors.grey[400]!,
                 width: 2,
               ),
             ),
             child: isSelected
                 ? Center(
                     child: Container(
                       width: 12,
                       height: 12,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: primaryColor,
                       ),
                     ),
                   )
                 : const SizedBox(),
           ),
           const SizedBox(width: 12),
           Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: primaryColor.withOpacity(0.1),
               borderRadius: BorderRadius.circular(8),
             ),
             child: Icon(
               icon,
               color: primaryColor,
               size: 20,
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   label,
                   style: GoogleFonts.poppins(
                     fontWeight: FontWeight.w600,
                     fontSize: 14,
                     color: Colors.black87,
                   ),
                 ),
                 Text(
                   description,
                   style: GoogleFonts.poppins(
                     fontSize: 12,
                     color: Colors.grey[600],
                   ),
                 ),
               ],
             ),
           ),
           if (label == 'Transfer Bank')
             Icon(
               Icons.arrow_forward_ios,
               size: 16,
               color: Colors.grey[400],
             ),
         ],
       ),
     ),
   );
 }

 Widget _buildBottomPaymentBar(
   double finalTotalAmount,
   Color primaryColor,
   CartProvider cartProvider,
   TransactionService transactionService,
   AuthProvider authProvider,
 ) {
   bool isCheckoutDisabled = cartProvider.items.isEmpty ||
       _deliveryAddress.isEmpty ||
       _contactPhone.isEmpty ||
       _contactEmail.isEmpty ||
       (_selectedPaymentMethod == 'Transfer Bank' && _selectedBank.isEmpty);

   return Container(
     padding: EdgeInsets.all(16).copyWith(
       bottom: MediaQuery.of(context).padding.bottom + 16,
     ),
     decoration: BoxDecoration(
       color: Colors.white,
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.05),
           blurRadius: 10,
           offset: const Offset(0, -2),
         ),
       ],
     ),
     child: Row(
       children: [
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               Text(
                 'Total Payment',
                 style: GoogleFonts.poppins(
                   fontSize: 13,
                   color: Colors.grey[600],
                 ),
               ),
               Text(
                 'Rp${finalTotalAmount.toStringAsFixed(0)}',
                 style: GoogleFonts.poppins(
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                   color: primaryColor,
                 ),
               ),
             ],
           ),
         ),
         Container(
           height: 50,
           decoration: BoxDecoration(
             gradient: LinearGradient(
               colors: isCheckoutDisabled
                   ? [Colors.grey[400]!, Colors.grey[300]!]
                   : [primaryColor, primaryColor.withOpacity(0.8)],
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
             ),
             borderRadius: BorderRadius.circular(25),
             boxShadow: isCheckoutDisabled
                 ? []
                 : [
                     BoxShadow(
                       color: primaryColor.withOpacity(0.3),
                       blurRadius: 8,
                       offset: const Offset(0, 4),
                     ),
                   ],
           ),
           child: ElevatedButton(
             onPressed: isCheckoutDisabled || _isProcessingPayment
                 ? null
                 : () => _processPayment(
                       finalTotalAmount,
                       cartProvider,
                       transactionService,
                       authProvider,
                       primaryColor,
                     ),
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.transparent,
               shadowColor: Colors.transparent,
               disabledBackgroundColor: Colors.transparent,
               minimumSize: const Size(160, 50),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(25),
               ),
             ),
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16),
               child: _isProcessingPayment
                   ? const SizedBox(
                       width: 20,
                       height: 20,
                       child: CircularProgressIndicator(
                         strokeWidth: 2,
                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                       ),
                     )
                   : Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(
                           'Pay Now',
                           style: GoogleFonts.poppins(
                             color: Colors.white,
                             fontWeight: FontWeight.w600,
                             fontSize: 15,
                           ),
                         ),
                         const SizedBox(width: 8),
                         const Icon(
                           Icons.arrow_forward_rounded,
                           color: Colors.white,
                           size: 18,
                         ),
                       ],
                     ),
             ),
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildProductImage(CartItem item) {
   if (item.imageUrl.startsWith('http')) {
     return Image.network(
       item.imageUrl,
       fit: BoxFit.cover,
       loadingBuilder: (context, child, loadingProgress) {
         if (loadingProgress == null) return child;
         return Center(
           child: CircularProgressIndicator(
             value: loadingProgress.expectedTotalBytes != null
                 ? loadingProgress.cumulativeBytesLoaded / 
                   loadingProgress.expectedTotalBytes!
                 : null,
           ),
         );
       },
       errorBuilder: (context, error, stackTrace) {
         return Center(
           child: Text(
             item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
             style: GoogleFonts.poppins(
               fontSize: 20,
               fontWeight: FontWeight.bold,
               color: Colors.black54,
             ),
           ),
         );
       },
     );
   } else if (item.imageUrl.startsWith('assets/')) {
     return Image.asset(
       item.imageUrl,
       fit: BoxFit.cover,
       errorBuilder: (context, error, stackTrace) {
         return Center(
           child: Text(
             item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
             style: GoogleFonts.poppins(
               fontSize: 20,
               fontWeight: FontWeight.bold,
               color: Colors.black54,
             ),
           ),
         );
       },
     );
   }
   
   return Center(
     child: Text(
       item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
       style: GoogleFonts.poppins(
         fontSize: 20,
         fontWeight: FontWeight.bold,
         color: Colors.black54,
       ),
     ),
   );
 }

  void _showBankSelectionDialog(BuildContext context, Color primaryColor) {
    final banks = [
      {
        'name': 'BCA',
        'account': '1234567890',
        'holder': 'PT TokoKu',
        'logo': 'assets/images/logobca.png', // Path gambar BCA
        'color': const Color(0xFF003893), // BCA Blue
        'bgColor': const Color(0xFFE3F2FD),
      },
      {
        'name': 'Mandiri',
        'account': '0987654321',
        'holder': 'PT TokoKu',
        'logo': 'assets/images/logomandiri.png',
        'color': const Color(0xFFFFB300),
        'bgColor': const Color(0xFFFFF8E1),
      },
      {
        'name': 'BNI',
        'account': '1122334455',
        'holder': 'PT TokoKu',
        'logo': 'assets/images/logobni.png', // Path gambar BNI
        'color': const Color(0xFFE65100), // BNI Orange
        'bgColor': const Color(0xFFFBE9E7),
      },
      {
        'name': 'BRI',
        'account': '5544332211',
        'holder': 'PT TokoKu',
        'logo': 'assets/images/logobri.png', // Path gambar BRI
        'color': const Color(0xFF1976D2), // BRI Blue
        'bgColor': const Color(0xFFE3F2FD),
      },
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                primaryColor.withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance_outlined,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Bank',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Transfer ke rekening berikut',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bank Options
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: banks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final bank = banks[index];
                      final isSelected = _selectedBank == bank['name'];

                      return Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (bank['color'] as Color).withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (bank['color'] as Color).withOpacity(0.3)
                                : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: (bank['color'] as Color).withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedBank = bank['name']! as String);
                            Navigator.pop(context);

                            // Show success snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Image.asset(
                                      bank['logo'] as String, // Path gambar
                                      width: 20,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${bank['name']} dipilih sebagai metode pembayaran',
                                      style: GoogleFonts.poppins(fontSize: 13),
                                    ),
                                  ],
                                ),
                                backgroundColor: bank['color'] as Color,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Bank Logo Container
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: bank['bgColor'] as Color,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: (bank['color'] as Color).withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Image.asset(
                                    bank['logo'] as String, // Path gambar
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Bank Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            bank['name']! as String,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (isSelected) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: bank['color'] as Color,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'No. Rek: ${bank['account']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'a.n ${bank['holder']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Selection Indicator
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? (bank['color'] as Color)
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? (bank['color'] as Color)
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Info Text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Transfer ke rekening yang dipilih, lalu upload bukti pembayaran',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
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


 void _showEditContactDialog(BuildContext context, Color secondaryColor, AuthProvider authProvider) {
   _phoneController.text = _contactPhone;
   _emailController.text = _contactEmail;

   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       title: Text(
         'Edit Contact Information',
         style: GoogleFonts.poppins(
           fontWeight: FontWeight.bold,
           fontSize: 18,
           color: Colors.black87,
         ),
       ),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           TextField(
             controller: _phoneController,
             decoration: InputDecoration(
               labelText: 'Phone Number',
               hintText: 'Enter your phone number',
               border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(12),
                 borderSide: BorderSide(color: Colors.grey[300]!),
               ),
               focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(12),
                 borderSide: BorderSide(color: secondaryColor, width: 2),
               ),
               contentPadding: const EdgeInsets.all(16),
             ),
             style: GoogleFonts.poppins(
               fontSize: 14,
               color: Colors.black87,
             ),
           ),
           const SizedBox(height: 16),
           TextField(
             controller: _emailController,
             decoration: InputDecoration(
               labelText: 'Email',
               hintText: 'Enter your email address',
               border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(12),
                 borderSide: BorderSide(color: Colors.grey[300]!),
               ),
               focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(12),
                 borderSide: BorderSide(color: secondaryColor, width: 2),
               ),
               contentPadding: const EdgeInsets.all(16),
             ),
             style: GoogleFonts.poppins(
               fontSize: 14,
               color: Colors.black87,
             ),
           ),
         ],
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.pop(context),
           child: Text(
             'Cancel',
             style: GoogleFonts.poppins(
               color: Colors.grey[600],
               fontWeight: FontWeight.w500,
             ),
           ),
         ),
         TextButton(
           onPressed: () {
             setState(() {
               _contactPhone = _phoneController.text;
               _contactEmail = _emailController.text;
             });
             Navigator.pop(context);
           },
           child: Text(
             'Save',
             style: GoogleFonts.poppins(
               color: secondaryColor,
               fontWeight: FontWeight.w600,
             ),
           ),
         ),
       ],
     ),
   );
 }

 // UPDATED: Method dialog dengan OpenStreetMap integration
 void _showEditAddressDialog(BuildContext context, Color primaryColor, AuthProvider authProvider) {
   _addressController.text = _deliveryAddress;
   
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       title: Text(
         _deliveryAddress.isEmpty ? 'Add Delivery Address' : 'Edit Delivery Address',
         style: GoogleFonts.poppins(
           fontWeight: FontWeight.bold,
           fontSize: 18,
           color: Colors.black87,
         ),
       ),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           TextField(
             controller: _addressController,
             maxLines: 3,
             decoration: InputDecoration(
               hintText: 'Enter your delivery address',
               border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(12),
                 borderSide: BorderSide(color: Colors.grey[300]!),
               ),
               focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(12),
                 borderSide: BorderSide(color: primaryColor, width: 2),
               ),
               contentPadding: const EdgeInsets.all(16),
             ),
             style: GoogleFonts.poppins(
               fontSize: 14,
               color: Colors.black87,
             ),
           ),
           const SizedBox(height: 16),
           
           // TAMBAHAN: OpenStreetMap Button
           Container(
             width: double.infinity,
             height: 44,
             decoration: BoxDecoration(
               gradient: LinearGradient(
                 colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
               ),
               border: Border.all(color: primaryColor.withOpacity(0.3)),
               borderRadius: BorderRadius.circular(12),
             ),
             child: TextButton.icon(
               onPressed: () {
                 Navigator.pop(context); // Close dialog first
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => OpenStreetMapAddressPicker(
                       initialAddress: _deliveryAddress,
                       primaryColor: primaryColor,
                       onAddressSelected: (String address, LatLng? coordinates) async {
                         setState(() {
                           _deliveryAddress = address;
                           _addressController.text = address;
                         });
                         
                         print('🗺️ Alamat dipilih dari OpenStreetMap: "$address"');
                         if (coordinates != null) {
                           print('📍 Koordinat: ${coordinates.latitude}, ${coordinates.longitude}');
                         }
                         
                         await _updateUserAddressInDatabase(authProvider, address);
                       },
                     ),
                   ),
                 );
               },
               icon: Icon(
                 Icons.map_outlined,
                 color: primaryColor,
                 size: 18,
               ),
               label: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text(
                     'Pilih dari Maps',
                     style: GoogleFonts.poppins(
                       color: primaryColor,
                       fontWeight: FontWeight.w600,
                       fontSize: 14,
                     ),
                   ),
                   const SizedBox(width: 6),
                
                 ],
               ),
               style: TextButton.styleFrom(
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                 ),
               ),
             ),
           ),
           
           const SizedBox(height: 12),
           Row(
             children: [
               Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
               const SizedBox(width: 8),
               Expanded(
                 child: Text(
                   'Alamat ini akan disimpan ke profil Anda',
                   style: GoogleFonts.poppins(
                     fontSize: 12,
                     color: Colors.grey[600],
                   ),
                 ),
               ),
             ],
           ),
         ],
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.pop(context),
           child: Text(
             'Cancel',
             style: GoogleFonts.poppins(
               color: Colors.grey[600],
               fontWeight: FontWeight.w500,
             ),
           ),
         ),
         TextButton(
           onPressed: () async {
             final newAddress = _addressController.text.trim();
             setState(() {
               _deliveryAddress = newAddress;
             });
             Navigator.pop(context);
             await _updateUserAddressInDatabase(authProvider, newAddress);
           },
           child: Text(
             'Save',
             style: GoogleFonts.poppins(
               color: primaryColor,
               fontWeight: FontWeight.w600,
             ),
           ),
         ),
       ],
     ),
   );
 }

 Future<void> _updateUserAddressInDatabase(AuthProvider authProvider, String newAddress) async {
   if (!authProvider.isLoggedIn || authProvider.userModel == null) {
     print('❌ User tidak login atau userModel null');
     return;
   }
   
   try {
     print('🏠 Updating alamat to database: "$newAddress"');
     
     final updatedUser = authProvider.userModel!.copyWith(
       alamat: newAddress.trim().isEmpty ? null : newAddress.trim(),
     );
     
     print('🏠 Updated UserModel alamat: "${updatedUser.alamat}"');
     
     bool success = await authProvider.updateUserProfile(updatedUser);
     
     if (success && mounted) {
       print('✅ Alamat berhasil disimpan ke database');
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Row(
             children: [
               Icon(Icons.check_circle, color: Colors.white, size: 20),
               const SizedBox(width: 8),
               Text(
                 'Alamat berhasil disimpan ke profil',
                 style: GoogleFonts.poppins(),
               ),
             ],
           ),
           backgroundColor: Colors.green,
           duration: const Duration(seconds: 2),
           behavior: SnackBarBehavior.floating,
         ),
       );
     } else if (mounted) {
       print('⚠️ Gagal menyimpan alamat ke database');
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Row(
             children: [
               Icon(Icons.warning, color: Colors.white, size: 20),
               const SizedBox(width: 8),
               Text(
                 'Alamat tersimpan sementara, gagal sync ke profil',
                 style: GoogleFonts.poppins(),
               ),
             ],
           ),
           backgroundColor: Colors.orange,
           duration: const Duration(seconds: 2),
           behavior: SnackBarBehavior.floating,
         ),
       );
     }
   } catch (e) {
     print('❌ Error updating user address: $e');
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Row(
             children: [
               Icon(Icons.error, color: Colors.white, size: 20),
               const SizedBox(width: 8),
               Expanded(
                 child: Text(
                   'Error menyimpan alamat: ${e.toString()}',
                   style: GoogleFonts.poppins(fontSize: 13),
                 ),
               ),
             ],
           ),
           backgroundColor: Colors.red,
           duration: const Duration(seconds: 3),
           behavior: SnackBarBehavior.floating,
         ),
       );
     }
   }
 }
}