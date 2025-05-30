// File: lib/utils/kitchen_ingredients_data_script.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class KitchenIngredientsDataScript {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data produk Bahan Dapur
  static final List<Map<String, dynamic>> _kitchenIngredientsProducts = [
    {
      'name': 'Minyak Goreng Tropical',
      'category': 'Bahan Dapur',
      'price': 25000,
      'originalPrice': 28000,
      'discountPercentage': 0.10,
      'imageUrl': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop',
      'subtitle': 'Minyak goreng berkualitas 1L',
      'rating': 4.7,
      'stock': 50,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Blue Band Margarin',
      'category': 'Bahan Dapur',
      'price': 11000,
      'originalPrice': 15000,
      'discountPercentage': 0.26,
      'imageUrl': 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400&h=400&fit=crop',
      'subtitle': 'Margarin premium 200gr',
      'rating': 4.6,
      'stock': 40,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Gula Pasir Premium',
      'category': 'Bahan Dapur',
      'price': 10000,
      'originalPrice': 12000,
      'discountPercentage': 0.16,
      'imageUrl': 'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=400&h=400&fit=crop',
      'subtitle': 'Gula pasir berkualitas 1kg',
      'rating': 4.8,
      'stock': 60,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Spagetti La Fonte',
      'category': 'Bahan Dapur',
      'price': 14500,
      'originalPrice': 16000,
      'discountPercentage': 0.09,
      'imageUrl': 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400&h=400&fit=crop',
      'subtitle': 'Pasta spagetti premium 500gr',
      'rating': 4.5,
      'stock': 35,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Santan Kara',
      'category': 'Bahan Dapur',
      'price': 3000,
      'originalPrice': 3500,
      'discountPercentage': 0.14,
      'imageUrl': 'https://images.unsplash.com/photo-1585540083814-ea6ee4f16d7c?w=400&h=400&fit=crop',
      'subtitle': 'Santan kelapa murni 200ml',
      'rating': 4.4,
      'stock': 80,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Tepung Roti',
      'category': 'Bahan Dapur',
      'price': 7000,
      'originalPrice': 8500,
      'discountPercentage': 0.17,
      'imageUrl': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=400&fit=crop',
      'subtitle': 'Tepung panir halus 250gr',
      'rating': 4.3,
      'stock': 45,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Beras Premium',
      'category': 'Bahan Dapur',
      'price': 75000,
      'originalPrice': 85000,
      'discountPercentage': 0.11,
      'imageUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop',
      'subtitle': 'Beras putih berkualitas 5kg',
      'rating': 4.9,
      'stock': 25,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Garam Halus',
      'category': 'Bahan Dapur',
      'price': 2500,
      'originalPrice': 3000,
      'discountPercentage': 0.16,
      'imageUrl': 'https://images.unsplash.com/photo-1594736797933-d0d2327d8d8a?w=400&h=400&fit=crop',
      'subtitle': 'Garam dapur halus 500gr',
      'rating': 4.2,
      'stock': 70,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Kecap Manis ABC',
      'category': 'Bahan Dapur',
      'price': 8500,
      'originalPrice': 10000,
      'discountPercentage': 0.15,
      'imageUrl': 'https://images.unsplash.com/photo-1563379091051-d88ff5950bee?w=400&h=400&fit=crop',
      'subtitle': 'Kecap manis premium 275ml',
      'rating': 4.6,
      'stock': 55,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Tepung Terigu Segitiga',
      'category': 'Bahan Dapur',
      'price': 12000,
      'originalPrice': 14000,
      'discountPercentage': 0.14,
      'imageUrl': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=400&fit=crop',
      'subtitle': 'Tepung terigu protein sedang 1kg',
      'rating': 4.7,
      'stock': 40,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  /// Menambahkan semua produk Bahan Dapur ke Firebase
  static Future<bool> addKitchenIngredientsProducts() async {
    try {
      print('🚀 Memulai penambahan produk Bahan Dapur...');
      
      // Batch write untuk efisiensi
      WriteBatch batch = _firestore.batch();
      
      for (int i = 0; i < _kitchenIngredientsProducts.length; i++) {
        final productData = _kitchenIngredientsProducts[i];
        final docRef = _firestore.collection('products').doc();
        
        batch.set(docRef, productData);
        print('🥄 Produk ${i + 1}: ${productData['name']} - siap ditambahkan');
      }
      
      // Commit semua sekaligus
      await batch.commit();
      
      print('✅ BERHASIL! ${_kitchenIngredientsProducts.length} produk Bahan Dapur telah ditambahkan ke Firebase');
      return true;
      
    } catch (e) {
      print('❌ ERROR menambahkan produk Bahan Dapur: $e');
      return false;
    }
  }

  /// Mengecek apakah produk Bahan Dapur sudah ada
  static Future<bool> checkKitchenIngredientsProductsExist() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: 'Bahan Dapur')
          .limit(1)
          .get();
      
      bool exists = snapshot.docs.isNotEmpty;
      print('🔍 Produk Bahan Dapur ${exists ? 'sudah ada' : 'belum ada'} di database');
      return exists;
      
    } catch (e) {
      print('❌ ERROR mengecek produk Bahan Dapur: $e');
      return false;
    }
  }

  /// Method utama: cek dulu, baru tambah jika belum ada
  static Future<void> initializeKitchenIngredientsProducts() async {
    try {
      bool exists = await checkKitchenIngredientsProductsExist();
      
      if (exists) {
        print('ℹ️ Produk Bahan Dapur sudah ada, tidak perlu ditambahkan lagi');
        return;
      }
      
      print('📥 Produk Bahan Dapur belum ada, menambahkan...');
      bool success = await addKitchenIngredientsProducts();
      
      if (success) {
        print('🎉 Setup produk Bahan Dapur selesai!');
      } else {
        print('⚠️ Gagal menambahkan produk Bahan Dapur');
      }
      
    } catch (e) {
      print('❌ ERROR inisialisasi produk Bahan Dapur: $e');
    }
  }

  /// Method untuk menghapus semua produk Bahan Dapur (jika perlu reset)
  static Future<bool> deleteAllKitchenIngredientsProducts() async {
    try {
      print('🗑️ Menghapus semua produk Bahan Dapur...');
      
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: 'Bahan Dapur')
          .get();
      
      if (snapshot.docs.isEmpty) {
        print('ℹ️ Tidak ada produk Bahan Dapur untuk dihapus');
        return true;
      }
      
      WriteBatch batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      print('✅ ${snapshot.docs.length} produk Bahan Dapur berhasil dihapus');
      return true;
      
    } catch (e) {
      print('❌ ERROR menghapus produk Bahan Dapur: $e');
      return false;
    }
  }
}