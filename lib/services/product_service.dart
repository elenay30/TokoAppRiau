// File: lib/services/product_service.dart - FIXED VERSION

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'products';

  Stream<List<Product>> getProductsStream() {
    return _firestore.collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Future<Product?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionName).doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }

  // FIXED: Query kategori tanpa index
  Stream<List<Product>> getProductsByCategory(String categoryName) {
    print('🔍 ProductService: Query kategori: $categoryName');
    
    return _firestore.collection(_collectionName)
        .where('category', isEqualTo: categoryName) // Query simple tanpa orderBy
        .snapshots()
        .map((snapshot) {
      print('🔍 ProductService: Raw results: ${snapshot.docs.length}');
      
      // Filter dan sort di client side
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .where((product) => product.isActive) // Filter isActive di client
          .toList();
      
      // Sort berdasarkan nama di client side
      products.sort((a, b) => a.name.compareTo(b.name));
      
      print('🔍 ProductService: Filtered results: ${products.length}');
      return products;
    }).handleError((error) {
      print('🚨 ProductService Error: $error');
      return <Product>[];
    });
  }

  // BARU: Metode untuk pencarian produk
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }
    String lowerCaseQuery = query.toLowerCase();

    try {
      // Ambil semua produk aktif lalu filter di client (untuk dataset kecil)
      QuerySnapshot snapshot = await _firestore.collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      List<Product> products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .where((product) => product.name.toLowerCase().contains(lowerCaseQuery))
          .toList();
      
      return products;

    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // --- FUNGSI CRUD TAMBAHAN (Untuk Admin atau jika diperlukan) ---
  Future<String?> addProduct(Product product) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collectionName).add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      if (product.id.isEmpty) {
        throw Exception("Product ID cannot be empty for update.");
      }
      Map<String, dynamic> dataToUpdate = product.toFirestore();
      await _firestore.collection(_collectionName).doc(product.id).update(dataToUpdate);
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> deactivateProduct(String productId) async {
    try {
      await _firestore.collection(_collectionName).doc(productId).update({'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error deactivating product: $e');
    }
  }
}