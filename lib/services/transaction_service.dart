// File: lib/services/transaction_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart' as models; // Menggunakan alias untuk model Transaction
import '../models/cart_item.dart'; // Model CartItem yang sudah ada

class TransactionService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<models.Transaction> _transactions = [];
  bool _isLoading = false;
  String? _userId;

  List<models.Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  TransactionService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      _userId = user.uid;
      print('TransactionService: User authenticated, userId: $_userId. Fetching transactions...');
      // Secara default, kita tidak langsung fetch semua transaksi saat login
      // kecuali jika memang dibutuhkan. Biasanya user akan ke halaman riwayat transaksi.
      // await fetchUserTransactions();
    } else {
      _userId = null;
      _transactions.clear();
      notifyListeners();
      print('TransactionService: User logged out. Local transactions cleared.');
    }
  }

  // Membuat transaksi baru di Firestore
  Future<String?> createTransaction({
    required List<CartItem> items,
    required double totalAmount,
    required String userId, // Bisa juga diambil dari _userId jika sudah pasti ada
    String? shippingAddress,
    String? notes,
    String? paymentMethod,
    models.TransactionStatus status = models.TransactionStatus.pending, // Default status
  }) async {
    if (items.isEmpty) {
      print('TransactionService: Cannot create transaction with empty items.');
      return null;
    }
    if (_userId == null && userId.isEmpty) {
        print('TransactionService: User ID is required to create a transaction.');
        return null;
    }

    final currentUserId = _userId ?? userId; // Utamakan _userId dari auth state

    _isLoading = true;
    notifyListeners();

    try {
      // Membuat ID unik untuk transaksi
      DocumentReference docRef = _firestore.collection('transactions').doc();

      final newTransaction = models.Transaction(
        id: docRef.id, // Gunakan ID yang di-generate Firestore
        userId: currentUserId,
        items: items, // List<CartItem>
        totalAmount: totalAmount,
        status: status,
        createdAt: DateTime.now(), // Akan dikonversi ke Timestamp
        updatedAt: DateTime.now(),
        shippingAddress: shippingAddress,
        notes: notes,
        paymentMethod: paymentMethod,
      );

      await docRef.set(newTransaction.toFirestore());
      print('TransactionService: Transaction ${newTransaction.id} created successfully for user $currentUserId.');

      // Tambahkan ke list lokal jika diperlukan, atau biarkan fetchUserTransactions mengambilnya
      // _transactions.insert(0, newTransaction);

      _isLoading = false;
      notifyListeners(); // Notify setelah loading selesai
      return newTransaction.id;
    } catch (e) {
      print('TransactionService: Error creating transaction: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Mengambil semua transaksi untuk pengguna yang sedang login
  Future<void> fetchUserTransactions() async {
    if (_userId == null) {
      print('TransactionService: Cannot fetch transactions, user not logged in.');
      _transactions.clear(); // Pastikan lokal kosong jika tidak ada user
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('TransactionService: Fetching transactions for userId: $_userId');
      QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true) // Tampilkan yang terbaru di atas
          .get();

      _transactions = snapshot.docs
          .map((doc) => models.Transaction.fromFirestore(doc))
          .toList();
      print('TransactionService: Fetched ${_transactions.length} transactions from Firestore.');
    } catch (e) {
      print('TransactionService: Error fetching user transactions: $e');
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mendapatkan stream transaksi pengguna (lebih reaktif)
  Stream<List<models.Transaction>> getUserTransactionsStream() {
    if (_userId == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          _transactions = snapshot.docs.map((doc) => models.Transaction.fromFirestore(doc)).toList();
          // notifyListeners(); // Sama seperti di CartService, ini bisa opsional
          return _transactions;
        })
        .handleError((error) {
          print('TransactionService: Error in user transactions stream: $error');
          _transactions = [];
          // notifyListeners();
          return <models.Transaction>[];
        });
  }


  // Mengupdate status transaksi (misalnya oleh admin atau sistem pembayaran)
  Future<void> updateTransactionStatus(String transactionId, models.TransactionStatus newStatus) async {
    // Tidak perlu _userId di sini karena admin mungkin yang mengupdate
    _isLoading = true;
    // notifyListeners(); // Mungkin tidak perlu jika ini bukan operasi yg langsung dilihat user

    try {
      await _firestore.collection('transactions').doc(transactionId).update({
        'status': newStatus.toString().split('.').last, // Simpan sebagai string
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('TransactionService: Transaction $transactionId status updated to $newStatus.');
      // Jika transaksi ini ada di list lokal, update juga
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        // Perlu membuat instance baru karena Transaction mungkin immutable
        // atau tambahkan method copyWith ke Transaction model
         _transactions[index] = _transactions[index].copyWith(status: newStatus, updatedAt: DateTime.now());
      }
    } catch (e) {
      print('TransactionService: Error updating transaction status for $transactionId: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify setelah selesai, agar UI yang menampilkan detail transaksi terupdate
    }
  }

  // Mengambil detail satu transaksi
  Future<models.Transaction?> getTransactionDetails(String transactionId) async {
    _isLoading = true;
    notifyListeners();
    try {
      DocumentSnapshot doc = await _firestore.collection('transactions').doc(transactionId).get();
      if (doc.exists) {
        return models.Transaction.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('TransactionService: Error fetching transaction details for $transactionId: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}