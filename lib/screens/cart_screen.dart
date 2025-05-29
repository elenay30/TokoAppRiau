// File: lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String deliveryAddress = '';
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserAddress();
    });
  }

  Future<void> _loadUserAddress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.userModel != null) {
      // PERBAIKAN: Ambil alamat dari database user menggunakan method yang sudah ada
      String userAddress = authProvider.userModel!.alamat?.trim().isNotEmpty == true
          ? authProvider.userModel!.alamat!.trim()
          : '';
      
      if (mounted) {
        setState(() {
          deliveryAddress = userAddress;
          _addressController.text = deliveryAddress;
        });
      }
      
      print('🏠 Alamat dimuat dari database user: "$userAddress"');
    } else {
      print('⚠️ User belum login, alamat kosong');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2D7BEE);
    final secondaryColor = const Color(0xFFFF8C00);

    return Consumer2<CartProvider, AuthProvider>(
      builder: (context, cartProvider, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text('Shopping Cart', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)),
            centerTitle: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              Positioned(top: -100, right: -100, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.05)))),
              Positioned(bottom: -100, left: -100, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: secondaryColor.withOpacity(0.05)))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 16, color: primaryColor),
                              const SizedBox(width: 4),
                              Text("${cartProvider.itemCount} items", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13, color: primaryColor)),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: cartProvider.items.isEmpty
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => _buildClearCartDialog(context, primaryColor, cartProvider),
                                  );
                                },
                          icon: Icon(Icons.delete_outline, color: cartProvider.items.isEmpty ? Colors.grey[400] : Colors.red[400], size: 18),
                          label: Text('Clear Cart', style: GoogleFonts.poppins(color: cartProvider.items.isEmpty ? Colors.grey[400] : Colors.red[400], fontSize: 13, fontWeight: FontWeight.w500)),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.location_on_outlined, color: primaryColor, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Delivery Address', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  deliveryAddress.isEmpty
                                      ? Text('Please add a delivery address', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic))
                                      : Text(deliveryAddress, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.5)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                                child: Icon(deliveryAddress.isEmpty ? Icons.add : Icons.edit_outlined, color: primaryColor, size: 16),
                              ),
                              onPressed: () => _showEditAddressDialog(context, primaryColor, authProvider),
                              constraints: const BoxConstraints(), padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: cartProvider.isLoading
                        ? Center(child: CircularProgressIndicator(color: primaryColor))
                        : cartProvider.items.isEmpty
                            ? _buildEmptyCart(primaryColor)
                            : _buildCartItems(primaryColor, cartProvider),
                  ),
                  if (cartProvider.items.isNotEmpty && !cartProvider.isLoading)
                    _buildCheckoutSection(primaryColor, cartProvider),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditAddressDialog(BuildContext context, Color primaryColor, AuthProvider authProvider) {
    _addressController.text = deliveryAddress;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(deliveryAddress.isEmpty ? 'Add Delivery Address' : 'Edit Delivery Address', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                        hintText: 'Enter your delivery address',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
                        contentPadding: const EdgeInsets.all(16)),
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
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
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500))),
                TextButton(
                    onPressed: () async {
                      final newAddress = _addressController.text.trim();
                      if (mounted) {
                        setState(() {
                          deliveryAddress = newAddress;
                        });
                      }
                      Navigator.pop(context);
                      
                      // Update address in user profile database
                      await _updateUserAddressInDatabase(authProvider, newAddress);
                    },
                    child: Text('Save', style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.w600))),
              ],
            ));
  }

  // TAMBAHAN: Method untuk update alamat ke database user
  Future<void> _updateUserAddressInDatabase(AuthProvider authProvider, String newAddress) async {
    if (!authProvider.isLoggedIn || authProvider.userModel == null) {
      print('❌ User tidak login atau userModel null');
      return;
    }
    
    try {
      print('🏠 Updating alamat to database: "$newAddress"');
      
      // Buat UserModel baru dengan alamat yang diupdate menggunakan copyWith yang sudah ada
      final updatedUser = authProvider.userModel!.copyWith(
        alamat: newAddress.trim().isEmpty ? null : newAddress.trim(),
      );
      
      print('🏠 Updated UserModel alamat: "${updatedUser.alamat}"');
      
      // Update ke database melalui AuthProvider
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

  Widget _buildEmptyCart(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.shopping_cart_outlined, size: 60, color: primaryColor)),
          const SizedBox(height: 24),
          Text('Your Cart is Empty', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Looks like you haven\'t added anything\nto your cart yet.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], height: 1.5)),
          const SizedBox(height: 24),
          Container(
            height: 50,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              label: Text('Continue Shopping', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), padding: const EdgeInsets.symmetric(horizontal: 24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(Color primaryColor, CartProvider cartProvider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: cartProvider.items.length,
      itemBuilder: (context, index) {
        final item = cartProvider.items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildProductImage(item)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis,),
                      if (item.subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(item.subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis,),
                        ),
                      const SizedBox(height: 4),
                      Text('Rp ${item.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
                      child: Row(
                        children: [
                          _buildModernCircularButton(
                            icon: Icons.remove,
                            onPressed: () {
                              if (item.quantity > 1) {
                                cartProvider.updateQuantity(item.productId, item.quantity - 1);
                              } else {
                                cartProvider.removeFromCart(item.productId);
                              }
                            },
                            primaryColor: primaryColor,
                          ),
                          SizedBox(width: 30, child: Text(item.quantity.toString(), textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600))),
                          _buildModernCircularButton(
                            icon: Icons.add,
                            onPressed: () {
                              cartProvider.updateQuantity(item.productId, item.quantity + 1);
                            },
                            primaryColor: primaryColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${(item.price * item.quantity).toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
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

  Widget _buildCheckoutSection(Color primaryColor, CartProvider cartProvider) {
    bool isCheckoutDisabled = cartProvider.items.isEmpty || deliveryAddress.isEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal (${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? 'item' : 'items'})', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
              Text('Rp ${cartProvider.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping Fee', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
              Text('FREE', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green[600])),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              Text('Rp ${cartProvider.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          if (deliveryAddress.isEmpty && cartProvider.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('Please add a delivery address to proceed', style: GoogleFonts.poppins(fontSize: 13, color: Colors.red[400], fontStyle: FontStyle.italic)),
            ),
          SizedBox(
            width: double.infinity, height: 50,
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: isCheckoutDisabled ? [Colors.grey[400]!, Colors.grey[300]!] : [primaryColor, primaryColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isCheckoutDisabled ? [] : [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
              child: ElevatedButton.icon(
                onPressed: isCheckoutDisabled
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/checkout', arguments: {
                          'address': deliveryAddress,
                          'cartItems': cartProvider.items,
                          'totalAmount': cartProvider.totalAmount,
                        });
                      },
                icon: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white),
                label: Text('Proceed to Checkout', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, disabledBackgroundColor: Colors.transparent, shadowColor: Colors.transparent, disabledForegroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearCartDialog(BuildContext context, Color primaryColor, CartProvider cartProvider) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Clear Cart', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
      content: Text('Are you sure you want to clear all items from your cart?', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500))),
        TextButton(
            onPressed: () async {
              await cartProvider.clearCart();
              Navigator.pop(context);
            },
            child: Text('Clear', style: GoogleFonts.poppins(color: Colors.red[500], fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildModernCircularButton({required IconData icon, required VoidCallback onPressed, required Color primaryColor}) {
    return SizedBox(width: 28, height: 28, child: IconButton(icon: Icon(icon, size: 16), color: primaryColor, padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: onPressed));
  }

  Widget _buildProductImage(CartItem item) {
    if (item.imageUrl.startsWith('http')) {
      return Image.network(
        item.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : '?', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)));
        },
      );
    } else if (item.imageUrl.startsWith('assets/')) {
      return Image.asset(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
            return Center(child: Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : '?', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)));
            },
        );
    }
    return Center(child: Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : '?', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)));
  }
}