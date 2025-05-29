// File: lib/models/product.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Untuk formatting harga

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String subtitle;
  final double? rating;
  final String? category;
  int stock; // Ubah menjadi non-nullable jika stock selalu ada, atau beri default
  final bool isActive; // Dibuat non-nullable
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Field baru untuk diskon
  final double? originalPrice; // Harga asli sebelum diskon
  final double? discountPercentage; // Persentase diskon (misal 0.1 untuk 10%)

  Product({
    required this.id,
    required this.name,
    required this.price, // Ini akan menjadi harga setelah diskon jika ada
    required this.imageUrl,
    required this.subtitle,
    this.rating,
    this.category,
    this.stock = 0, // Default stock ke 0 jika tidak ada
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.originalPrice,
    this.discountPercentage,
  });

  // Getter yang digunakan di UI Anda
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  // Getter untuk menampilkan persentase diskon dalam format yang lebih baik jika diperlukan
  // Ini sudah ada di UI Anda, jadi kita bisa langsung pakai discountPercentage
  // int get displayDiscountPercentage => discountPercentage != null ? (discountPercentage! * 100).round() : 0;

  String get formattedPrice {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    return formatCurrency.format(price);
  }

  String? get formattedOriginalPrice {
    if (originalPrice != null && originalPrice! > price) {
      final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
      return formatCurrency.format(originalPrice);
    }
    return null;
  }

  bool get isInStock => stock > 0;


  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    double currentPrice = (data['price'] ?? 0.0).toDouble();
    double? originalPriceData = (data['originalPrice'] as num?)?.toDouble();
    double? discountPercentageData = (data['discountPercentage'] as num?)?.toDouble();

    // Jika ada originalPrice, pastikan price adalah harga setelah diskon
    // Jika tidak ada originalPrice tapi ada discountPercentage, hitung harga diskon
    if (originalPriceData == null && discountPercentageData != null && discountPercentageData > 0) {
      originalPriceData = currentPrice; // Asumsikan price yang di DB adalah harga asli
      currentPrice = originalPriceData * (1 - discountPercentageData);
    } else if (originalPriceData != null && discountPercentageData == null) {
      // Hitung discountPercentage jika tidak ada tapi ada originalPrice dan price
      if (originalPriceData > currentPrice) {
        discountPercentageData = (originalPriceData - currentPrice) / originalPriceData;
      }
    }


    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: currentPrice, // Harga setelah diskon
      imageUrl: data['imageUrl'] ?? '',
      subtitle: data['subtitle'] ?? '',
      rating: (data['rating'] as num?)?.toDouble(),
      category: data['category'],
      stock: (data['stock'] ?? 0).toInt(), // Default ke 0 jika null
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      originalPrice: originalPriceData,
      discountPercentage: discountPercentageData,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price, // Simpan harga setelah diskon
      'imageUrl': imageUrl,
      'subtitle': subtitle,
      'rating': rating,
      'category': category,
      'stock': stock,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(), // Selalu update
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    String? subtitle,
    double? rating,
    String? category,
    int? stock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? originalPrice,
    double? discountPercentage,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      subtitle: subtitle ?? this.subtitle,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }
}