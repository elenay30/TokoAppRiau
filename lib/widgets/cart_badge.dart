// File: lib/widgets/cart_badge.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/cart_provider.dart';

class CartBadge extends StatelessWidget {
  final Widget child;
  final Color badgeColor;
  final Color textColor;
  final Color borderColor;

  const CartBadge({
    Key? key,
    required this.child,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.borderColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Debug: Print untuk memastikan CartProvider bekerja
        print('🛒 CartBadge - itemCount: ${cartProvider.itemCount}');
        print('🛒 CartBadge - items length: ${cartProvider.items.length}');
        print('🛒 CartBadge - isLoading: ${cartProvider.isLoading}');
        
        final itemCount = cartProvider.itemCount;
        
        return Stack(
          clipBehavior: Clip.none, // Penting: agar badge tidak terpotong
          children: [
            this.child, // Widget utama (Icon cart)
            if (itemCount > 0) // Hanya tampil jika ada item
              Positioned(
                right: -8, // Posisi di kanan atas
                top: -6,   // Posisi di kanan atas
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: badgeColor,
                    border: Border.all(color: borderColor, width: 1), // Border putih
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    itemCount > 99 ? '99+' : '$itemCount', // Maksimal 99+
                    style: GoogleFonts.poppins(
                      color: textColor,
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
    );
  }
}

// TAMBAHAN: Widget khusus untuk AppBar atau Toolbar
class AppBarCartBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final Color iconColor;
  final double iconSize;

  const AppBarCartBadge({
    Key? key,
    this.onTap,
    this.iconColor = Colors.black87,
    this.iconSize = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, '/cart'),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CartBadge(
          badgeColor: Colors.red,
          textColor: Colors.white,
          borderColor: Colors.white,
          child: Icon(
            Icons.shopping_cart_outlined,
            color: iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}