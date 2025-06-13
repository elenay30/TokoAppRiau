// File: lib/services/notification_service.dart - FIXED VERSION
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _notificationsCollection =>
      _firestore.collection('notifications');

  // FIXED: Simple stream untuk semua notifikasi tanpa complex filter
  Stream<List<AppNotification>> getAllNotifications() {
    return _notificationsCollection
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      print('🔥 Firestore stream update: ${snapshot.docs.length} docs');
      
      final currentUser = _auth.currentUser;
      final notifications = snapshot.docs.map((doc) {
        try {
          return AppNotification.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        } catch (e) {
          print('❌ Error parsing notification ${doc.id}: $e');
          return null;
        }
      }).where((notification) => notification != null)
       .cast<AppNotification>()
       .toList();

      // Filter di client side untuk menghindari complex Firestore queries
      final filteredNotifications = notifications.where((notification) {
        // Show global notifications (promo, system)
        if (notification.userId == null && 
            (notification.type == 'promo' || notification.type == 'system')) {
          return true;
        }
        
        // Show user-specific notifications
        if (currentUser != null && notification.userId == currentUser.uid) {
          return true;
        }
        
        return false;
      }).toList();

      print('📨 Filtered notifications: ${filteredNotifications.length}');
      return filteredNotifications;
    });
  }

  // SIMPLIFIED: Unread count
  Stream<int> getUnreadCount() {
    return getAllNotifications().map((notifications) {
      return notifications.where((n) => !n.isRead).length;
    });
  }

  // Tandai notifikasi sebagai sudah dibaca
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Marked notification as read: $notificationId');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  // Tandai semua notifikasi sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final batch = _firestore.batch();
      
      // Get all notifications first
      final allNotifications = await _notificationsCollection
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      int updateCount = 0;
      for (final doc in allNotifications.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String?;
        final type = data['type'] as String?;
        final isRead = data['isRead'] as bool? ?? false;

        // Check if this notification should be marked as read
        bool shouldUpdate = false;
        if (!isRead) {
          if (userId == null && (type == 'promo' || type == 'system')) {
            shouldUpdate = true; // Global notification
          } else if (userId == currentUser.uid) {
            shouldUpdate = true; // User-specific notification
          }
        }

        if (shouldUpdate) {
          batch.update(doc.reference, {
            'isRead': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          updateCount++;
        }
      }

      if (updateCount > 0) {
        await batch.commit();
        print('✅ Marked $updateCount notifications as read');
      }
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  // === METHODS UNTUK MEMBUAT NOTIFIKASI ===

  // UPDATED: Notifikasi transaksi baru dengan text yang lebih bagus
  Future<void> createTransactionNotification({
    required String userId,
    required String transactionId,
    required String transactionType,
    required double totalAmount,
  }) async {
    try {
      String title = '';
      String message = '';
      
      switch (transactionType.toLowerCase()) {
        case 'pending':
          title = '🛒 Pesanan Berhasil Dibuat';
          message = 'Pesanan Anda sebesar Rp ${_formatCurrency(totalAmount)} berhasil dibuat. Silakan lakukan pembayaran untuk melanjutkan.';
          break;
        case 'paid':
          title = '💳 Pembayaran Berhasil';
          message = 'Pembayaran sebesar Rp ${_formatCurrency(totalAmount)} telah berhasil. Pesanan akan segera diproses.';
          break;
        case 'shipped':
          title = '🚚 Pesanan Sedang Dikirim';
          message = 'Pesanan Anda sedang dalam perjalanan. Estimasi tiba dalam 1-3 hari kerja.';
          break;
        case 'delivered':
          title = '✅ Pesanan Telah Sampai';
          message = 'Pesanan Anda telah sampai di alamat tujuan. Terima kasih telah berbelanja dengan kami!';
          break;
        case 'cancelled':
          title = '❌ Pesanan Dibatalkan';
          message = 'Pesanan sebesar Rp ${_formatCurrency(totalAmount)} telah dibatalkan. Dana akan dikembalikan dalam 1-3 hari kerja.';
          break;
        default:
          title = '📦 Update Pesanan';
          message = 'Ada update pada pesanan Anda sebesar Rp ${_formatCurrency(totalAmount)}.';
      }

      final notification = AppNotification(
        id: '',
        title: title,
        message: message,
        type: 'transaction',
        userId: userId,
        transactionId: transactionId,
        createdAt: DateTime.now(),
        data: {
          'transactionId': transactionId,
          'totalAmount': totalAmount,
          'transactionType': transactionType,
        },
      );

      await _notificationsCollection.add(notification.toFirestore());
      print('✅ Transaction notification created: $title');
    } catch (e) {
      print('❌ Error creating transaction notification: $e');
    }
  }

  // UPDATED: Notifikasi order status update dengan text yang lebih bagus
  Future<void> createOrderStatusNotification({
    required String userId,
    required String transactionId,
    required String status,
    required String productName,
  }) async {
    try {
      String title = '';
      String message = '';
      
      switch (status.toLowerCase()) {
        case 'pending':
          title = '⏳ Menunggu Pembayaran';
          message = 'Pesanan "$productName" menunggu pembayaran Anda. Jangan sampai kehabisan stok!';
          break;
        case 'paid':
          title = '✅ Pembayaran Dikonfirmasi';
          message = 'Pembayaran untuk "$productName" telah dikonfirmasi. Pesanan akan segera diproses dan dikirim.';
          break;
        case 'shipped':
          title = '🚚 Pesanan Sedang Dikirim';
          message = 'Pesanan "$productName" telah dikirim dan sedang dalam perjalanan menuju alamat Anda.';
          break;
        case 'delivered':
          title = '🎉 Pesanan Telah Sampai';
          message = 'Pesanan "$productName" telah sampai di alamat tujuan. Jangan lupa berikan ulasan dan rating!';
          break;
        case 'cancelled':
          title = '🚫 Pesanan Dibatalkan';
          message = 'Pesanan "$productName" telah dibatalkan. Silakan pesan kembali jika masih dibutuhkan.';
          break;
        default:
          title = '📋 Update Status Pesanan';
          message = 'Ada update status untuk pesanan "$productName". Silakan cek detail pesanan Anda.';
      }

      final notification = AppNotification(
        id: '',
        title: title,
        message: message,
        type: 'order',
        userId: userId,
        transactionId: transactionId,
        createdAt: DateTime.now(),
        data: {
          'transactionId': transactionId,
          'status': status,
          'productName': productName,
        },
      );

      await _notificationsCollection.add(notification.toFirestore());
      print('✅ Order status notification created: $title');
    } catch (e) {
      print('❌ Error creating order status notification: $e');
    }
  }

  // Notifikasi promo (global)
  Future<void> createPromoNotification({
    required String title,
    required String message,
    String? imageUrl,
    String? productId,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        title: title,
        message: message,
        type: 'promo',
        imageUrl: imageUrl,
        productId: productId,
        createdAt: DateTime.now(),
        data: {
          'productId': productId,
        },
      );

      await _notificationsCollection.add(notification.toFirestore());
      print('✅ Promo notification created: $title');
    } catch (e) {
      print('❌ Error creating promo notification: $e');
    }
  }

  // Notifikasi sistem (global)
  Future<void> createSystemNotification({
    required String title,
    required String message,
    String? imageUrl,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        title: title,
        message: message,
        type: 'system',
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _notificationsCollection.add(notification.toFirestore());
      print('✅ System notification created: $title');
    } catch (e) {
      print('❌ Error creating system notification: $e');
    }
  }

  // TAMBAHAN: Force refresh method untuk debugging
  Future<List<AppNotification>> forceGetAllNotifications() async {
    try {
      print('🔄 Force fetching all notifications...');
      
      final snapshot = await _notificationsCollection
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      final currentUser = _auth.currentUser;
      final notifications = snapshot.docs.map((doc) {
        try {
          return AppNotification.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        } catch (e) {
          print('❌ Error parsing notification ${doc.id}: $e');
          return null;
        }
      }).where((notification) => notification != null)
       .cast<AppNotification>()
       .toList();

      // Filter di client side
      final filteredNotifications = notifications.where((notification) {
        if (notification.userId == null && 
            (notification.type == 'promo' || notification.type == 'system')) {
          return true;
        }
        
        if (currentUser != null && notification.userId == currentUser.uid) {
          return true;
        }
        
        return false;
      }).toList();

      print('✅ Force fetch result: ${filteredNotifications.length} notifications');
      for (var notif in filteredNotifications.take(3)) {
        print('  - ${notif.type}: ${notif.title}');
      }
      
      return filteredNotifications;
    } catch (e) {
      print('❌ Error force fetching notifications: $e');
      return [];
    }
  }

  // Currency formatting
  String _formatCurrency(double amount) {
    try {
      String formatted = amount.toStringAsFixed(0);
      String result = '';
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          result = '.$result';
        }
        result = formatted[i] + result;
        count++;
      }
      return result;
    } catch (e) {
      print('Error formatting currency: $e');
      return amount.toStringAsFixed(0);
    }
  }

  // Hapus notifikasi
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
      print('✅ Notification deleted: $notificationId');
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  // Hapus notifikasi lama (cleanup)
  Future<void> cleanupOldNotifications({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      final oldNotifications = await _notificationsCollection
          .where('createdAt', isLessThan: cutoffDate)
          .get();

      final batch = _firestore.batch();
      for (final doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Cleaned up ${oldNotifications.docs.length} old notifications');
    } catch (e) {
      print('❌ Error cleaning up old notifications: $e');
    }
  }
}