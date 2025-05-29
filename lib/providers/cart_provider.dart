// File: lib/providers/cart_provider.dart - Enhanced with Debug
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters dengan debug prints
  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount {
    final count = _items.fold(0, (sum, item) => sum + item.quantity);
    print('🛒 CartProvider.itemCount getter called: $count');
    return count;
  }

  int get uniqueItemCount => _items.length;

  double get totalAmount => 
    _items.fold(0.0, (total, current) => total + (current.price * current.quantity));

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  // Constructor
  CartProvider() {
    print('🛒 CartProvider: Constructor called');
    
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      print('🛒 CartProvider: Auth state changed - User: ${user?.email ?? 'null'}');
      if (user != null) {
        _loadCartFromFirebase(userId: user.uid);
      } else {
        print('🛒 CartProvider: User logged out, clearing cart');
        _items.clear();
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
      }
    });

    // Initial load if user is already logged in
    if (_auth.currentUser != null) {
      print('🛒 CartProvider: User already logged in, loading cart');
      _loadCartFromFirebase(userId: _auth.currentUser!.uid);
    }
  }

  // Load cart dari Firebase dengan enhanced debug
  Future<void> _loadCartFromFirebase({String? userId}) async {
    final currentUserId = userId ?? _auth.currentUser?.uid;
    print('🛒 _loadCartFromFirebase called with userId: $currentUserId');
    
    if (currentUserId == null) {
      print('🛒 No user ID, clearing cart');
      _items.clear();
      notifyListeners();
      return;
    }

    if (_isLoading) {
      print('🛒 Already loading, skipping');
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    print('🛒 Setting loading to true, notifying listeners');
    notifyListeners();

    try {
      print('🛒 Fetching cart from Firestore path: users/$currentUserId/cartItems');
      
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cartItems')
          .orderBy('addedAt', descending: true)
          .get();

      print('🛒 Firestore query completed. Documents: ${snapshot.docs.length}');

      final List<CartItem> loadedItems = [];
      
      for (var doc in snapshot.docs) {
        try {
          final cartItem = CartItem.fromFirestore(doc);
          loadedItems.add(cartItem);
          print('🛒 Loaded item: ${cartItem.name} (qty: ${cartItem.quantity})');
        } catch (e) {
          print('🛒 Error parsing document ${doc.id}: $e');
        }
      }
      
      _items = loadedItems;
      print('🛒 Cart loaded successfully. Total items: ${_items.length}, Total count: $itemCount');

    } catch (e) {
      print('🛒 Error loading cart from Firebase: $e');
      _errorMessage = 'Gagal memuat keranjang. Coba lagi nanti.';
    } finally {
      _isLoading = false;
      print('🛒 Loading complete, notifying listeners');
      notifyListeners();
    }
  }

  // TAMBAHAN: Method untuk menambah Product (kompatibilitas dengan category screens)
  Future<void> addProduct(Product product, {int quantity = 1}) async {
    print('🛒 addProduct called for: ${product.name}');
    
    if (_auth.currentUser == null) {
      print('🛒 User not logged in');
      _errorMessage = "Silakan login untuk menambahkan item ke keranjang.";
      notifyListeners();
      return;
    }

    if (quantity <= 0) return;

    // Konversi Product ke CartItem
    final cartItem = CartItem(
      id: product.id,
      productId: product.id,
      name: product.name,
      subtitle: product.subtitle ?? '',
      price: product.price,
      imageUrl: product.imageUrl,
      addedAt: DateTime.now(),
      quantity: quantity,
    );

    await addToCart(cartItem);
  }

  // Menambah item ke keranjang dengan enhanced debug
  Future<void> addToCart(CartItem newItem) async {
    print('🛒 addToCart called for: ${newItem.name}');
    
    if (_auth.currentUser == null) {
      print('🛒 User not logged in');
      _errorMessage = "Silakan login untuk menambahkan item ke keranjang.";
      notifyListeners();
      return;
    }

    print('🛒 Current cart before adding: ${_items.length} items, count: $itemCount');

    final existingIndex = _items.indexWhere((cartItem) => cartItem.productId == newItem.productId);
    
    if (existingIndex >= 0) {
      print('🛒 Item already exists, updating quantity from ${_items[existingIndex].quantity} to ${_items[existingIndex].quantity + newItem.quantity}');
      _items[existingIndex].quantity += newItem.quantity;
      await _syncItemToFirebase(_items[existingIndex], isAddingOrUpdating: true);
    } else {
      print('🛒 Adding new item to cart');
      _items.add(newItem);
      await _syncItemToFirebase(newItem, isAddingOrUpdating: true);
    }
    
    print('🛒 Cart after adding: ${_items.length} items, count: $itemCount');
    notifyListeners();
  }

  // Menghapus item dari keranjang
  Future<void> removeFromCart(String productId) async {
    print('🛒 removeFromCart called for productId: $productId');
    
    if (_auth.currentUser == null) return;

    final itemToRemove = _items.firstWhere((item) => item.productId == productId);
    _items.removeWhere((item) => item.productId == productId);
    print('🛒 Item removed. Cart now has: ${_items.length} items, count: $itemCount');
    notifyListeners();
    await _syncItemToFirebase(itemToRemove, isAddingOrUpdating: false);
  }

  // Mengupdate kuantitas item
  Future<void> updateQuantity(String productId, int newQuantity) async {
    print('🛒 updateQuantity called for $productId: $newQuantity');
    
    if (_auth.currentUser == null) return;

    final index = _items.indexWhere((cartItem) => cartItem.productId == productId);
    
    if (index >= 0) {
      if (newQuantity > 0) {
        _items[index].quantity = newQuantity;
        await _syncItemToFirebase(_items[index], isAddingOrUpdating: true);
      } else {
        await removeFromCart(productId); 
      }
      print('🛒 Quantity updated. Cart count: $itemCount');
      notifyListeners();
    }
  }

  // TAMBAHAN: Method untuk increment/decrement quantity
  Future<void> incrementQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      await updateQuantity(productId, _items[index].quantity + 1);
    }
  }

  Future<void> decrementQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      int newQuantity = _items[index].quantity - 1;
      if (newQuantity <= 0) {
        await removeFromCart(productId);
      } else {
        await updateQuantity(productId, newQuantity);
      }
    }
  }

  // Membersihkan semua item dari keranjang
  Future<void> clearCart() async {
    print('🛒 clearCart called');
    
    if (_auth.currentUser == null) return;
    if (_items.isEmpty) return;

    _items.clear();
    print('🛒 Cart cleared locally. Count: $itemCount');
    notifyListeners();
    
    // GUNAKAN PATH YANG SAMA: cartItems
    final String userId = _auth.currentUser!.uid;
    try {
      QuerySnapshot currentCart = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cartItems')
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in currentCart.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('🛒 Cart cleared from Firestore');
    } catch (e) {
      print('🛒 Error clearing cart in Firebase: $e');
      _errorMessage = 'Gagal membersihkan keranjang di server.';
      notifyListeners();
    }
  }

  // Helper method untuk sync satu item ke Firebase
  Future<void> _syncItemToFirebase(CartItem item, {required bool isAddingOrUpdating}) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      DocumentReference docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cartItems')
          .doc(item.productId);

      if (isAddingOrUpdating) {
        await docRef.set(item.toFirestore(), SetOptions(merge: true));
        print('🛒 Item synced to Firestore: ${item.name}');
      } else {
        await docRef.delete();
        print('🛒 Item deleted from Firestore: ${item.name}');
      }
    } catch (e) {
      print('🛒 Error syncing item to Firebase: $e');
      _errorMessage = 'Gagal sinkronisasi keranjang. Periksa koneksi Anda.';
      notifyListeners();
    }
  }

  // Method utilitas lainnya
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  int getProductQuantity(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId).quantity;
    } catch (e) {
      return 0;
    }
  }

  void clearError() {
    if (_errorMessage.isNotEmpty) {
      _errorMessage = '';
      notifyListeners();
    }
  }

  Future<void> refreshCart() async {
    print('🔄 refreshCart called');
    await _loadCartFromFirebase();
  }

  // TAMBAHAN: Method untuk kompatibilitas dengan UI lama
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': itemCount,
      'totalAmount': totalAmount,
      'itemsCount': _items.length,
      'isEmpty': isEmpty,
    };
  }

  // TAMBAHAN: Method untuk debug informasi cart
  void debugCartInfo() {
    print('🛒 === CART DEBUG INFO ===');
    print('🛒 Items count: ${_items.length}');
    print('🛒 Total quantity: $itemCount');
    print('🛒 Total amount: $totalAmount');
    print('🛒 Is loading: $_isLoading');
    print('🛒 Error message: $_errorMessage');
    print('🛒 User ID: ${_auth.currentUser?.uid}');
    
    if (_items.isNotEmpty) {
      print('🛒 Items in cart:');
      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        print('🛒   $i. ${item.name} (qty: ${item.quantity}, price: ${item.price})');
      }
    } else {
      print('🛒 Cart is empty');
    }
    print('🛒 === END DEBUG INFO ===');
  }
}