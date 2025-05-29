// ===================================
// TAHAP 2: ENHANCED SERVICES & FIXED TRANSACTION MODEL
// ===================================

// ===================================
// 1. FIXED TRANSACTION MODEL
// File: lib/models/transaction.dart
// ===================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart'; // Pastikan import path benar

enum TransactionStatus { pending, paid, shipped, delivered, cancelled }

class Transaction {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? shippingAddress;
  final String? notes;
  final String? paymentMethod;
  final String? trackingNumber;
  final double? shippingCost;
  final double? taxAmount;

  Transaction({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.shippingAddress,
    this.notes,
    this.paymentMethod,
    this.trackingNumber,
    this.shippingCost,
    this.taxAmount,
  });

  // FIXED: From Firestore with proper error handling
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    try {
      if (!doc.exists) {
        throw Exception('Transaction document does not exist');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Parse items with safety checks
      List<CartItem> items = [];
      if (data['items'] != null && data['items'] is List) {
        items = (data['items'] as List).map((item) {
          try {
            // Create CartItem from map data
            return CartItem(
              id: item['id']?.toString() ?? '',
              name: item['name']?.toString() ?? 'Unknown Product',
              subtitle: item['subtitle']?.toString() ?? '',
              price: (item['price'] as num?)?.toDouble() ?? 0.0,
              imageUrl: item['imageUrl']?.toString() ?? '',
              quantity: (item['quantity'] as num?)?.toInt() ?? 1,
              productId: item['productId']?.toString() ?? '',
              addedAt: item['addedAt'] != null 
                ? (item['addedAt'] as Timestamp).toDate() 
                : DateTime.now(),
            );
          } catch (e) {
            print('Error parsing cart item: $e');
            // Return empty cart item if parsing fails
            return CartItem(
              id: '',
              name: 'Error Product',
              subtitle: '',
              price: 0.0,
              imageUrl: '',
              quantity: 0,
              productId: '',
              addedAt: DateTime.now(),
            );
          }
        }).where((item) => item.quantity > 0).toList(); // Filter out error items
      }

      return Transaction(
        id: doc.id,
        userId: data['userId']?.toString() ?? '',
        items: items,
        totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
        status: _getStatusFromString(data['status']?.toString() ?? 'pending'),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        shippingAddress: data['shippingAddress']?.toString(),
        notes: data['notes']?.toString(),
        paymentMethod: data['paymentMethod']?.toString(),
        trackingNumber: data['trackingNumber']?.toString(),
        shippingCost: (data['shippingCost'] as num?)?.toDouble(),
        taxAmount: (data['taxAmount'] as num?)?.toDouble(),
      );
    } catch (e) {
      print('Error creating Transaction from Firestore: $e');
      // Return minimal transaction object
      return Transaction(
        id: doc.id,
        userId: '',
        items: [],
        totalAmount: 0.0,
        status: TransactionStatus.pending,
        createdAt: DateTime.now(),
      );
    }
  }

  // FIXED: To Firestore with proper data structure
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => {
        'id': item.id,
        'name': item.name,
        'subtitle': item.subtitle,
        'price': item.price,
        'imageUrl': item.imageUrl,
        'quantity': item.quantity,
        'productId': item.productId,
        'addedAt': Timestamp.fromDate(item.addedAt),
      }).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'shippingAddress': shippingAddress,
      'notes': notes,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'shippingCost': shippingCost,
      'taxAmount': taxAmount,
    };
  }

  // Helper method untuk convert string ke enum
  static TransactionStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return TransactionStatus.pending;
      case 'paid': return TransactionStatus.paid;
      case 'shipped': return TransactionStatus.shipped;
      case 'delivered': return TransactionStatus.delivered;
      case 'cancelled': return TransactionStatus.cancelled;
      default: return TransactionStatus.pending;
    }
  }

  // Getter untuk status dalam bahasa Indonesia
  String get statusString {
    switch (status) {
      case TransactionStatus.pending: return 'Menunggu Pembayaran';
      case TransactionStatus.paid: return 'Dibayar';
      case TransactionStatus.shipped: return 'Dikirim';
      case TransactionStatus.delivered: return 'Selesai';
      case TransactionStatus.cancelled: return 'Dibatalkan';
    }
  }

  // Getter untuk warna status
  String get statusColor {
    switch (status) {
      case TransactionStatus.pending: return '#FF9800'; // Orange
      case TransactionStatus.paid: return '#2196F3'; // Blue
      case TransactionStatus.shipped: return '#9C27B0'; // Purple
      case TransactionStatus.delivered: return '#4CAF50'; // Green
      case TransactionStatus.cancelled: return '#F44336'; // Red
    }
  }

  // Copy with method
  Transaction copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? totalAmount,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? shippingAddress,
    String? notes,
    String? paymentMethod,
    String? trackingNumber,
    double? shippingCost,
    double? taxAmount,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      shippingCost: shippingCost ?? this.shippingCost,
      taxAmount: taxAmount ?? this.taxAmount,
    );
  }

  // Getter untuk menghitung jumlah item
  int get totalItems {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  // Getter untuk subtotal (tanpa shipping dan tax)
  double get subtotal {
    return items.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }

  // Method untuk validasi
  bool isValid() {
    return userId.isNotEmpty && 
           items.isNotEmpty && 
           totalAmount > 0;
  }
}
