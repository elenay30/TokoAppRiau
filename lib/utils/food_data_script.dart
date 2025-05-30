// File: lib/utils/food_data_script.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodDataScript {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data produk Makanan
  static final List<Map<String, dynamic>> _foodProducts = [
    {
      'name': 'Indomie Goreng',
      'category': 'Makanan',
      'price': 3500,
      'originalPrice': 4000,
      'discountPercentage': 0.12,
      'imageUrl': 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&h=400&fit=crop',
      'subtitle': 'Mie instan goreng 85gr',
      'rating': 4.8,
      'stock': 100,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Tango Wafer',
      'category': 'Makanan',
      'price': 25000,
      'originalPrice': 28000,
      'discountPercentage': 0.10,
      'imageUrl': 'https://images.unsplash.com/photo-1571091655789-405eb7a3a3a8?w=400&h=400&fit=crop',
      'subtitle': 'Wafer cokelat lezat',
      'rating': 4.6,
      'stock': 50,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Monde Butter Cookies',
      'category': 'Makanan',
      'price': 65000,
      'originalPrice': 72000,
      'discountPercentage': 0.09,
      'imageUrl': 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400&h=400&fit=crop',
      'subtitle': 'Biskuit butter premium',
      'rating': 4.7,
      'stock': 30,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Fitbar Fruit',
      'category': 'Makanan',
      'price': 5000,
      'originalPrice': 6000,
      'discountPercentage': 0.16,
      'imageUrl': 'https://images.unsplash.com/photo-1571506165871-c2ee43c5b5e6?w=400&h=400&fit=crop',
      'subtitle': 'Snack bar buah 20gr',
      'rating': 4.5,
      'stock': 80,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Chiki Balls',
      'category': 'Makanan',
      'price': 7000,
      'originalPrice': 8000,
      'discountPercentage': 0.12,
      'imageUrl': 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=400&h=400&fit=crop',
      'subtitle': 'Snack bola keju 100gr',
      'rating': 4.6,
      'stock': 60,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Jetz Sticks',
      'category': 'Makanan',
      'price': 2000,
      'originalPrice': 2500,
      'discountPercentage': 0.20,
      'imageUrl': 'https://images.unsplash.com/photo-1594736797933-d0d2327d8d8a?w=400&h=400&fit=crop',
      'subtitle': 'Stick keju gurih 30gr',
      'rating': 4.2,
      'stock': 90,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Oreo Original',
      'category': 'Makanan',
      'price': 12000,
      'originalPrice': 14000,
      'discountPercentage': 0.14,
      'imageUrl': 'https://images.unsplash.com/photo-1606890737304-57a1ca8a5b62?w=400&h=400&fit=crop',
      'subtitle': 'Biskuit sandwich cokelat',
      'rating': 4.9,
      'stock': 70,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Keripik Kentang',
      'category': 'Makanan',
      'price': 8500,
      'originalPrice': 10000,
      'discountPercentage': 0.15,
      'imageUrl': 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&h=400&fit=crop',
      'subtitle': 'Keripik kentang renyah',
      'rating': 4.4,
      'stock': 55,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  /// Menambahkan semua produk Makanan ke Firebase
  static Future<bool> addFoodProducts() async {
    try {
      print('🚀 Memulai penambahan produk Makanan...');
      
      // Batch write untuk efisiensi
      WriteBatch batch = _firestore.batch();
      
      for (int i = 0; i < _foodProducts.length; i++) {
        final productData = _foodProducts[i];
        final docRef = _firestore.collection('products').doc();
        
        batch.set(docRef, productData);
        print('🍔 Produk ${i + 1}: ${productData['name']} - siap ditambahkan');
      }
      
      // Commit semua sekaligus
      await batch.commit();
      
      print('✅ BERHASIL! ${_foodProducts.length} produk Makanan telah ditambahkan ke Firebase');
      return true;
      
    } catch (e) {
      print('❌ ERROR menambahkan produk Makanan: $e');
      return false;
    }
  }

  /// Mengecek apakah produk Makanan sudah ada
  static Future<bool> checkFoodProductsExist() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: 'Makanan')
          .limit(1)
          .get();
      
      bool exists = snapshot.docs.isNotEmpty;
      print('🔍 Produk Makanan ${exists ? 'sudah ada' : 'belum ada'} di database');
      return exists;
      
    } catch (e) {
      print('❌ ERROR mengecek produk Makanan: $e');
      return false;
    }
  }

  /// Method utama: cek dulu, baru tambah jika belum ada
  static Future<void> initializeFoodProducts() async {
    try {
      bool exists = await checkFoodProductsExist();
      
      if (exists) {
        print('ℹ️ Produk Makanan sudah ada, tidak perlu ditambahkan lagi');
        return;
      }
      
      print('📥 Produk Makanan belum ada, menambahkan...');
      bool success = await addFoodProducts();
      
      if (success) {
        print('🎉 Setup produk Makanan selesai!');
      } else {
        print('⚠️ Gagal menambahkan produk Makanan');
      }
      
    } catch (e) {
      print('❌ ERROR inisialisasi produk Makanan: $e');
    }
  }

  /// Method untuk menghapus semua produk Makanan (jika perlu reset)
  static Future<bool> deleteAllFoodProducts() async {
    try {
      print('🗑️ Menghapus semua produk Makanan...');
      
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: 'Makanan')
          .get();
      
      if (snapshot.docs.isEmpty) {
        print('ℹ️ Tidak ada produk Makanan untuk dihapus');
        return true;
      }
      
      WriteBatch batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      print('✅ ${snapshot.docs.length} produk Makanan berhasil dihapus');
      return true;
      
    } catch (e) {
      print('❌ ERROR menghapus produk Makanan: $e');
      return false;
    }
  }
}