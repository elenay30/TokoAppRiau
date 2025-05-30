// File: lib/models/transaction.dart - FIXED VERSION
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionStatus {
  pending,
  paid,
  shipped,
  delivered,
  cancelled,
}

extension TransactionStatusExtension on TransactionStatus {
  String get value {
    switch (this) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.paid:
        return 'paid';
      case TransactionStatus.shipped:
        return 'shipped';
      case TransactionStatus.delivered:
        return 'delivered';
      case TransactionStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Menunggu Pembayaran';
      case TransactionStatus.paid:
        return 'Dibayar';
      case TransactionStatus.shipped:
        return 'Sedang Dikirim';
      case TransactionStatus.delivered:
        return 'Selesai';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  static TransactionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'paid':
        return TransactionStatus.paid;
      case 'shipped':
        return TransactionStatus.shipped;
      case 'delivered':
        return TransactionStatus.delivered;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }
}

class TransactionItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final String subtitle;

  TransactionItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.subtitle = '',
  });

  // FIXED: toFirestore method
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'subtitle': subtitle,
    };
  }

  // FIXED: fromFirestore method
  factory TransactionItem.fromFirestore(Map<String, dynamic> data) {
    return TransactionItem(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      imageUrl: data['imageUrl'] ?? '',
      subtitle: data['subtitle'] ?? '',
    );
  }

  TransactionItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? subtitle,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}

class Transaction {
  final String id;
  final String userId;
  final List<TransactionItem> items;
  final double totalAmount;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? shippingAddress;
  final String? paymentMethod;

  Transaction({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.shippingAddress,
    this.paymentMethod,
  });

  String get statusString => status.displayName;

  // FIXED: toFirestore method dengan proper timestamp handling
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toFirestore()).toList(),
      'totalAmount': totalAmount,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.fromDate(createdAt),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
    };
  }

  // FIXED: fromFirestore method dengan proper error handling
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      
      // Parse items with error handling
      List<TransactionItem> itemsList = [];
      if (data['items'] != null) {
        final itemsData = data['items'] as List<dynamic>;
        for (var itemData in itemsData) {
          try {
            if (itemData is Map<String, dynamic>) {
              itemsList.add(TransactionItem.fromFirestore(itemData));
            }
          } catch (e) {
            print('❌ Error parsing transaction item: $e');
          }
        }
      }

      // Parse timestamps with fallback
      DateTime createdAt = DateTime.now();
      DateTime? updatedAt;
      
      if (data['createdAt'] != null) {
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is String) {
          createdAt = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
        }
      }
      
      if (data['updatedAt'] != null) {
        if (data['updatedAt'] is Timestamp) {
          updatedAt = (data['updatedAt'] as Timestamp).toDate();
        } else if (data['updatedAt'] is String) {
          updatedAt = DateTime.tryParse(data['updatedAt']);
        }
      }

      return Transaction(
        id: doc.id,
        userId: data['userId'] ?? '',
        items: itemsList,
        totalAmount: (data['totalAmount'] ?? 0).toDouble(),
        status: TransactionStatusExtension.fromString(data['status'] ?? 'pending'),
        createdAt: createdAt,
        updatedAt: updatedAt,
        shippingAddress: data['shippingAddress'],
        paymentMethod: data['paymentMethod'],
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing Transaction from Firestore: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ Document data: ${doc.data()}');
      rethrow;
    }
  }

  Transaction copyWith({
    String? id,
    String? userId,
    List<TransactionItem>? items,
    double? totalAmount,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? shippingAddress,
    String? paymentMethod,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}