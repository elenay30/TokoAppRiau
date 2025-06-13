// File: lib/services/transaction_service.dart - UPDATED dengan Auto Notifications
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart' as models;
import '../models/cart_item.dart';
import '../services/notification_service.dart'; // TAMBAH INI

class TransactionService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService(); // TAMBAH INI

  List<models.Transaction> _transactions = [];
  bool _isLoading = false;
  String? _lastUserId;
  bool _isDisposed = false; // Flag untuk prevent calls after dispose

  List<models.Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // UPDATED: Create Transaction dengan auto notification
  Future<String?> createTransaction({
    required List<CartItem> items,
    required double totalAmount,
    required String userId,
    required String shippingAddress,
    required String paymentMethod,
    required models.TransactionStatus status,
  }) async {
    if (_isDisposed) return null;
    
    try {
      print('🔄 TransactionService.createTransaction started');
      print('  - User ID: $userId');
      print('  - Items count: ${items.length}');
      print('  - Total: $totalAmount');
      print('  - Address: $shippingAddress');
      print('  - Payment: $paymentMethod');
      
      // VALIDATION: Check user authentication
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user found');
        return null;
      }
      if (currentUser.uid != userId) {
        print('❌ User ID mismatch: ${currentUser.uid} vs $userId');
        return null;
      }
      
      // VALIDATION: Check items
      if (items.isEmpty) {
        print('❌ No items in transaction');
        return null;
      }

      // Convert CartItems to Transaction items
      List<models.TransactionItem> transactionItems = items.map((cartItem) {
        return models.TransactionItem(
          id: cartItem.id,
          name: cartItem.name,
          price: cartItem.price,
          quantity: cartItem.quantity,
          imageUrl: cartItem.imageUrl,
          subtitle: cartItem.subtitle,
        );
      }).toList();

      // Create transaction object
      final transaction = models.Transaction(
        id: '', // Will be set by Firestore
        userId: userId,
        items: transactionItems,
        totalAmount: totalAmount,
        status: status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );

      print('🔄 Creating transaction document...');
      
      // Use batch write for atomic operation
      final batch = _firestore.batch();
      final docRef = _firestore.collection('transactions').doc();
      
      // Set the transaction ID
      final transactionWithId = transaction.copyWith(id: docRef.id);
      
      // Convert to map for Firestore
      final transactionData = transactionWithId.toFirestore();
      
      print('🔄 Transaction data to save:');
      print('  - ID: ${docRef.id}');
      print('  - User ID: ${transactionData['userId']}');
      print('  - Items: ${transactionData['items']}');
      print('  - Total: ${transactionData['totalAmount']}');
      
      batch.set(docRef, transactionData);
      
      // Execute batch
      await batch.commit();
      
      print('✅ Transaction saved successfully with ID: ${docRef.id}');

      // === TAMBAHAN: AUTO CREATE NOTIFICATION ===
      try {
        await _notificationService.createTransactionNotification(
          userId: userId,
          transactionId: docRef.id,
          transactionType: status.name,
          totalAmount: totalAmount,
        );
        print('✅ Transaction notification created');
      } catch (e) {
        print('⚠️ Failed to create notification, but transaction was successful: $e');
        // Don't fail the entire transaction if notification fails
      }
      
      // Add to local list immediately untuk UI responsiveness
      if (!_isDisposed) {
        _transactions.insert(0, transactionWithId);
        notifyListeners();
      }
      
      return docRef.id;
      
    } catch (e, stackTrace) {
      print('❌ Error creating transaction: $e');
      print('❌ Stack trace: $stackTrace');
      return null;
    }
  }

  // TAMBAHAN: Update Transaction Status dengan auto notification
  Future<bool> updateTransactionStatus(String transactionId, models.TransactionStatus newStatus) async {
    if (_isDisposed) return false;
    
    try {
      print('🔄 Updating transaction status to: ${newStatus.name}');
      
      // Get current transaction untuk mendapatkan info user dan produk
      final transactionDoc = await _firestore.collection('transactions').doc(transactionId).get();
      if (!transactionDoc.exists) {
        print('❌ Transaction not found');
        return false;
      }

      final transactionData = transactionDoc.data() as Map<String, dynamic>;
      final userId = transactionData['userId'] as String;
      final items = transactionData['items'] as List<dynamic>;
      final firstProductName = items.isNotEmpty ? items.first['name'] as String : 'Produk';

      // Update status
      await _firestore.collection('transactions').doc(transactionId).update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Transaction status updated');

      // === TAMBAHAN: AUTO CREATE ORDER STATUS NOTIFICATION ===
      try {
        await _notificationService.createOrderStatusNotification(
          userId: userId,
          transactionId: transactionId,
          status: newStatus.name,
          productName: firstProductName,
        );
        print('✅ Order status notification created');
      } catch (e) {
        print('⚠️ Failed to create status notification: $e');
      }

      // Update local state
      if (!_isDisposed) {
        final index = _transactions.indexWhere((tx) => tx.id == transactionId);
        if (index != -1) {
          _transactions[index] = _transactions[index].copyWith(
            status: newStatus,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }
      
      return true;
    } catch (e) {
      print('❌ Error updating transaction status: $e');
      return false;
    }
  }

  // FIXED: Simple fetch tanpa streaming - untuk stop loop
  Future<void> fetchUserTransactions() async {
    if (_isDisposed) return;
    
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ fetchUserTransactions: No authenticated user');
        _transactions = [];
        _lastUserId = null;
        if (!_isDisposed) notifyListeners();
        return;
      }

      // Check if user changed
      if (_lastUserId != currentUser.uid) {
        print('🔄 User changed from $_lastUserId to ${currentUser.uid}');
        _transactions = [];
        _lastUserId = currentUser.uid;
      }

      print('🔄 Fetching transactions for user: ${currentUser.uid}');
      if (!_isDisposed) {
        _isLoading = true;
        notifyListeners();
      }

      // Query dengan index yang sudah enabled
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      print('🔍 Query executed, found ${querySnapshot.docs.length} documents');

      List<models.Transaction> fetchedTransactions = [];
      
      for (var doc in querySnapshot.docs) {
        try {
          print('🔍 Processing document: ${doc.id}');
          final data = doc.data();
          print('  - Data keys: ${data.keys.toList()}');
          print('  - User ID in doc: ${data['userId']}');
          print('  - Status: ${data['status']}');
          print('  - Total: ${data['totalAmount']}');
          
          final transaction = models.Transaction.fromFirestore(doc);
          fetchedTransactions.add(transaction);
          print('✅ Successfully parsed transaction: ${transaction.id}');
        } catch (e) {
          print('❌ Error parsing transaction ${doc.id}: $e');
          print('❌ Document data: ${doc.data()}');
        }
      }

      // Data sudah tersortir dari Firestore
      if (!_isDisposed) {
        _transactions = fetchedTransactions;
        print('✅ Total transactions loaded: ${_transactions.length}');
        
        // Debug: Print all transaction IDs and details
        for (int i = 0; i < _transactions.length; i++) {
          final tx = _transactions[i];
          print('  [$i] ${tx.id.substring(0, 8)}... - ${tx.statusString} - Rp${tx.totalAmount} - Items: ${tx.items.length}');
        }
      }

    } catch (e, stackTrace) {
      print('❌ Error fetching transactions: $e');
      print('❌ Stack trace: $stackTrace');
      if (!_isDisposed) {
        _transactions = [];
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // === TAMBAHAN: Methods untuk membuat notifikasi manual ===
  
  // Method untuk membuat notifikasi promo (bisa dipanggil dari admin panel)
  Future<void> createPromoNotification({
    required String title,
    required String message,
    String? imageUrl,
    String? productId,
  }) async {
    try {
      await _notificationService.createPromoNotification(
        title: title,
        message: message,
        imageUrl: imageUrl,
        productId: productId,
      );
      print('✅ Promo notification created');
    } catch (e) {
      print('❌ Error creating promo notification: $e');
    }
  }

  // Method untuk membuat notifikasi sistem
  Future<void> createSystemNotification({
    required String title,
    required String message,
    String? imageUrl,
  }) async {
    try {
      await _notificationService.createSystemNotification(
        title: title,
        message: message,
        imageUrl: imageUrl,
      );
      print('✅ System notification created');
    } catch (e) {
      print('❌ Error creating system notification: $e');
    }
  }

  // Method untuk cleanup notifikasi lama
  Future<void> cleanupOldNotifications({int daysOld = 30}) async {
    try {
      await _notificationService.cleanupOldNotifications(daysOld: daysOld);
      print('✅ Old notifications cleaned up');
    } catch (e) {
      print('❌ Error cleaning up notifications: $e');
    }
  }

  // FIXED: Clear transactions dengan dispose check
  void clearTransactions() {
    if (_isDisposed) return;
    print('🔄 Clearing transactions');
    _transactions = [];
    notifyListeners();
  }

  // FIXED: Clear pada logout
  void clearOnLogout() {
    if (_isDisposed) return;
    print('🔄 Clearing transactions on logout');
    _transactions = [];
    _lastUserId = null;
    _isLoading = false;
    notifyListeners();
  }

  // FIXED: Get pending transactions count
  int get pendingTransactionsCount {
    try {
      if (_isDisposed) return 0;
      return _transactions.where((tx) => 
        tx.status == models.TransactionStatus.pending ||
        tx.status == models.TransactionStatus.paid ||
        tx.status == models.TransactionStatus.shipped
      ).length;
    } catch (e) {
      print('❌ Error calculating pending transactions count: $e');
      return 0;
    }
  }

  // Helper method untuk debugging
  Future<void> debugFirestoreConnection() async {
    if (_isDisposed) return;
    try {
      print('🔍 Testing Firestore connection...');
      final testDoc = await _firestore.collection('test').doc('test').get();
      print('✅ Firestore connection OK');
      
      // Test transactions collection access
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final transactionsQuery = await _firestore
            .collection('transactions')
            .where('userId', isEqualTo: currentUser.uid)
            .limit(1)
            .get();
        print('✅ Transactions collection accessible, found ${transactionsQuery.docs.length} docs');
      }
    } catch (e) {
      print('❌ Firestore connection failed: $e');
    }
  }

  // Get transaction by ID
  models.Transaction? getTransactionById(String id) {
    try {
      if (_isDisposed) return null;
      return _transactions.firstWhere((tx) => tx.id == id);
    } catch (e) {
      print('❌ Transaction not found: $id');
      return null;
    }
  }

  // Get transactions by status
  List<models.Transaction> getTransactionsByStatus(models.TransactionStatus status) {
    if (_isDisposed) return [];
    return _transactions.where((tx) => tx.status == status).toList();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}