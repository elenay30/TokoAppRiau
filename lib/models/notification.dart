// File: lib/models/notification.dart
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'transaction', 'promo', 'system', 'order'
  final String? imageUrl;
  final Map<String, dynamic>? data; // Data tambahan (transaction ID, product ID, etc.)
  final DateTime createdAt;
  final bool isRead;
  final String? userId; // Untuk notifikasi user-specific
  final String? transactionId; // Jika terkait transaksi
  final String? productId; // Jika terkait produk

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.imageUrl,
    this.data,
    required this.createdAt,
    this.isRead = false,
    this.userId,
    this.transactionId,
    this.productId,
  });

  // Factory untuk membuat dari Firestore document
  factory AppNotification.fromFirestore(Map<String, dynamic> data, String id) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'system',
      imageUrl: data['imageUrl'],
      data: data['data'] as Map<String, dynamic>?,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      userId: data['userId'],
      transactionId: data['transactionId'],
      productId: data['productId'],
    );
  }

  // Convert ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'imageUrl': imageUrl,
      'data': data,
      'createdAt': createdAt,
      'isRead': isRead,
      'userId': userId,
      'transactionId': transactionId,
      'productId': productId,
    };
  }

  // CopyWith method
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? imageUrl,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? userId,
    String? transactionId,
    String? productId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
    );
  }

  // Helper methods
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${(difference.inDays / 7).floor()} minggu yang lalu';
    }
  }

  String get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }
    
    // Default image berdasarkan type
    switch (type) {
      case 'transaction':
        return 'assets/images/transaction_icon.png';
      case 'promo':
        return 'assets/images/promo_icon.png';
      case 'order':
        return 'assets/images/order_icon.png';
      default:
        return 'assets/images/notification_icon.png';
    }
  }
}