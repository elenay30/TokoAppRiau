// File: lib/models/cart_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final String subtitle;
  final double price;
  final String imageUrl;
  final String productId;
  final DateTime addedAt;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    required this.productId,
    required this.addedAt,
    this.quantity = 1,
  });

  // Mengonversi objek CartItem menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'subtitle': subtitle,
      'price': price,
      'imageUrl': imageUrl,
      'productId': productId,
      'addedAt': Timestamp.fromDate(addedAt),
      'quantity': quantity,
    };
  }

  // Membuat objek CartItem dari DocumentSnapshot Firestore
  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return CartItem(
      id: doc.id,
      name: data['name'] ?? 'Unknown Product',
      subtitle: data['subtitle'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      productId: data['productId'] ?? doc.id, // Fallback ke doc.id jika productId kosong
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  // TAMBAHAN: Factory constructor dari Product
  factory CartItem.fromProduct(dynamic product, {int quantity = 1}) {
    return CartItem(
      id: product.id,
      productId: product.id,
      name: product.name,
      subtitle: product.subtitle ?? '',
      price: product.price,
      imageUrl: product.imageUrl,
      addedAt: DateTime.now(),
      quantity: quantity,
    );
  }

  // Method untuk menambah kuantitas
  void incrementQuantity() {
    quantity++;
  }

  // Method untuk mengurangi kuantitas (dengan batasan minimal 1)
  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  // Menghitung subtotal untuk item ini
  double get subtotal => price * quantity;

  // Copy with method untuk update
  CartItem copyWith({
    String? id,
    String? name,
    String? subtitle,
    double? price,
    String? imageUrl,
    String? productId,
    DateTime? addedAt,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      productId: productId ?? this.productId,
      addedAt: addedAt ?? this.addedAt,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'CartItem(id: $id, productId: $productId, name: $name, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}