// File: lib/services/cart_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Untuk mendapatkan user ID
import '../models/cart_item.dart';
import '../models/product.dart'; // Jika masih perlu konversi dari Product

class CartService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CartItem> _items = []; // Daftar item keranjang lokal, disinkronkan dari Firestore
  bool _isLoading = false;
  String? _userId; // Akan di-set saat user login

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  CartService() {
    // Dengarkan perubahan status otentikasi
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      _userId = user.uid;
      print('CartService: User authenticated, userId: $_userId. Fetching cart...');
      await fetchCartItems(); // Ambil data keranjang saat user login
    } else {
      _userId = null;
      _clearLocalCart(); // Kosongkan keranjang lokal saat user logout
      print('CartService: User logged out. Local cart cleared.');
    }
  }

  void _clearLocalCart() {
    _items.clear();
    notifyListeners();
  }

  // Mengambil item keranjang dari Firestore
  Future<void> fetchCartItems() async {
    if (_userId == null) {
      print('CartService: Cannot fetch cart, userId is null.');
      _clearLocalCart();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('CartService: Fetching cart items for userId: $_userId');
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cartItems')
          .orderBy('addedAt', descending: true) // Urutkan berdasarkan waktu ditambah
          .get();

      _items = snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList();
      print('CartService: Fetched ${_items.length} items from Firestore.');
    } catch (e) {
      print('CartService: Error fetching cart items: $e');
      _items = []; // Kosongkan jika ada error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mendapatkan stream item keranjang dari Firestore (lebih reaktif)
  Stream<List<CartItem>> getCartItemsStream() {
    if (_userId == null) {
      return Stream.value([]); // Kembalikan stream kosong jika tidak ada user
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('cartItems')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          _items = snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList();
          // notifyListeners(); // Tidak perlu notifyListeners di sini jika UI menggunakan StreamBuilder
          // Namun, jika ada komponen lain yang listen ke CartService tapi tidak via StreamBuilder, ini bisa berguna.
          // Untuk kasus umum dengan StreamBuilder, ini bisa memicu rebuild ganda.
          // Kita akan membiarkan CartProvider yang mungkin menggunakan CartService ini untuk handle notifikasi.
          return _items;
        })
        .handleError((error) {
          print('CartService: Error in cart items stream: $error');
          _items = [];
          // notifyListeners();
          return <CartItem>[];
        });
  }

  // ADDED: Method yang hilang untuk kompatibilitas dengan category screens
  Future<void> addProduct(Product product, {int quantity = 1}) async {
    await addProductToCart(product, quantity: quantity);
  }

  // ADDED: Method alternatif untuk kompatibilitas
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    await addProductToCart(product, quantity: quantity);
  }

  // Menambahkan produk ke keranjang (konversi Product ke CartItem)
  Future<void> addProductToCart(Product product, {int quantity = 1}) async {
    if (_userId == null) {
      print('CartService: Cannot add product, user not logged in.');
      // Mungkin tampilkan pesan ke user
      return;
    }
    if (quantity <= 0) return; // Kuantitas harus positif

    _isLoading = true;
    notifyListeners();

    // Gunakan productId sebagai ID dokumen di sub-koleksi cartItems
    final cartItemRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('cartItems')
        .doc(product.id);

    try {
      // Cek apakah item sudah ada di keranjang
      DocumentSnapshot doc = await cartItemRef.get();
      if (doc.exists) {
        // Jika sudah ada, update kuantitasnya
        int currentQuantity = (doc.data() as Map<String, dynamic>)['quantity'] ?? 0;
        await cartItemRef.update({
          'quantity': currentQuantity + quantity,
          'price': product.price, // Update harga jika ada perubahan (opsional)
          'addedAt': FieldValue.serverTimestamp(), // Update waktu
        });
        print('CartService: Product ${product.id} quantity updated in Firestore.');
      } else {
        // Jika belum ada, tambahkan sebagai item baru
        final newItem = CartItem(
          id: product.id, // Ini akan jadi ID dokumen, jadi tidak perlu disimpan lagi di field
          productId: product.id,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          subtitle: product.subtitle,
          quantity: quantity,
          addedAt: DateTime.now(), // Akan dikonversi ke Timestamp di toFirestore
        );
        await cartItemRef.set(newItem.toFirestore());
        print('CartService: Product ${product.id} added to Firestore.');
      }
      // Setelah operasi Firestore berhasil, sinkronkan data lokal
      await fetchCartItems(); // Atau update _items secara manual jika lebih efisien
    } catch (e) {
      print('CartService: Error adding/updating product ${product.id} to cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mengupdate kuantitas item di keranjang
  Future<void> updateItemQuantity(String productId, int newQuantity) async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    final cartItemRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('cartItems')
        .doc(productId);

    try {
      if (newQuantity <= 0) {
        // Jika kuantitas baru 0 atau kurang, hapus item
        await removeItemFromCart(productId);
      } else {
        await cartItemRef.update({
          'quantity': newQuantity,
          'addedAt': FieldValue.serverTimestamp(), // Update waktu
        });
        print('CartService: Product $productId quantity updated to $newQuantity in Firestore.');
        // Update item lokal
        final index = _items.indexWhere((item) => item.productId == productId);
        if (index != -1) {
          _items[index].quantity = newQuantity;
        }
      }
    } catch (e) {
      print('CartService: Error updating quantity for $productId: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ADDED: Method untuk increment quantity (kompatibilitas)
  Future<void> incrementQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      await updateItemQuantity(productId, _items[index].quantity + 1);
    }
  }

  // ADDED: Method untuk decrement quantity (kompatibilitas)
  Future<void> decrementQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      int newQuantity = _items[index].quantity - 1;
      if (newQuantity <= 0) {
        await removeItemFromCart(productId);
      } else {
        await updateItemQuantity(productId, newQuantity);
      }
    }
  }

  // ADDED: Method untuk cek apakah produk ada di cart
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  // ADDED: Method untuk get quantity produk tertentu
  int getProductQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    return index != -1 ? _items[index].quantity : 0;
  }

  // Menghapus item dari keranjang
  Future<void> removeItemFromCart(String productId) async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    final cartItemRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('cartItems')
        .doc(productId);

    try {
      await cartItemRef.delete();
      _items.removeWhere((item) => item.productId == productId);
      print('CartService: Product $productId removed from Firestore.');
    } catch (e) {
      print('CartService: Error removing item $productId: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ADDED: Method alias untuk remove (kompatibilitas)
  Future<void> removeFromCart(String productId) async {
    await removeItemFromCart(productId);
  }

  // Mengosongkan semua item di keranjang pengguna
  Future<void> clearCart() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    final cartCollectionRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('cartItems');

    try {
      // Hapus semua dokumen dalam sub-koleksi cartItems
      // Ini perlu dilakukan dengan mengambil semua doc ID lalu menghapusnya satu per satu
      // atau menggunakan batch delete.
      WriteBatch batch = _firestore.batch();
      QuerySnapshot snapshot = await cartCollectionRef.get();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _items.clear();
      print('CartService: All items cleared from Firestore for userId: $_userId.');
    } catch (e) {
      print('CartService: Error clearing cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ADDED: Getter untuk kompatibilitas
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  // ADDED: Method untuk get cart summary
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': itemCount,
      'totalAmount': totalAmount,
      'itemsCount': _items.length,
      'isEmpty': isEmpty,
    };
  }

  // ADDED: Method untuk calculate discount (placeholder)
  double calculateDiscount() {
    // Implement your discount logic here
    return 0.0;
  }

  // ADDED: Method untuk calculate tax (placeholder)
  double calculateTax() {
    // Implement your tax calculation here
    return totalAmount * 0.1; // 10% tax example
  }

  // ADDED: Method untuk get final total
  double getFinalTotal() {
    double discount = calculateDiscount();
    double tax = calculateTax();
    return totalAmount - discount + tax;
  }

  // --- Helper Getters (berdasarkan _items lokal) ---
  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  int get uniqueItemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}