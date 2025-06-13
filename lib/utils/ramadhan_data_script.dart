// File: lib/utils/ramadhan_data_script.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RamadhanDataScript {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data produk Ramadhan
  static final List<Map<String, dynamic>> _ramadhanProducts = [
    {
      'name': 'Kurma Khotas',
      'category': 'Ramadhan',
      'price': 27000,
      'originalPrice': 29000,
      'discountPercentage': 0.07,
      'imageUrl': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop',
      'subtitle': 'Kurma premium kualitas terbaik',
      'rating': 4.8,
      'stock': 50,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Monde Biscuit',
      'category': 'Ramadhan',
      'price': 63000,
      'originalPrice': 65900,
      'discountPercentage': 0.05,
      'imageUrl': 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400&h=400&fit=crop',
      'subtitle': 'Biskuit renyah untuk berbuka',
      'rating': 4.5,
      'stock': 75,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Alpenliebe',
      'category': 'Ramadhan',
      'price': 27000,
      'originalPrice': 28000,
      'discountPercentage': 0.04,
      'imageUrl': 'https://images.unsplash.com/photo-1499195333224-3ce974eecb47?w=400&h=400&fit=crop',
      'subtitle': 'Permen manis untuk takjil',
      'rating': 4.3,
      'stock': 100,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Biskuit Tango',
      'category': 'Ramadhan',
      'price': 15000,
      'originalPrice': 17500,
      'discountPercentage': 0.14,
      'imageUrl': 'https://images.unsplash.com/photo-1548365328-8c6db3220e4c?w=400&h=400&fit=crop',
      'subtitle': 'Biskuit cokelat favorit keluarga',
      'rating': 4.6,
      'stock': 80,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Sirup ABC',
      'category': 'Ramadhan',
      'price': 18500,
      'originalPrice': 22000,
      'discountPercentage': 0.15,
      'imageUrl': 'https://images.unsplash.com/photo-1570831739435-6601aa3fa4fb?w=400&h=400&fit=crop',
      'subtitle': 'Sirup segar untuk berbuka puasa',
      'rating': 4.4,
      'stock': 60,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Kue Kering Lebaran',
      'category': 'Ramadhan',
      'price': 45000,
      'originalPrice': 50000,
      'discountPercentage': 0.10,
      'imageUrl': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=400&fit=crop',
      'subtitle': 'Aneka kue kering tradisional',
      'rating': 4.7,
      'stock': 30,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Aneka Oleh-oleh',
      'category': 'Ramadhan',
      'price': 35000,
      'originalPrice': 38000,
      'discountPercentage': 0.08,
      'imageUrl': 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?w=400&h=400&fit=crop',
      'subtitle': 'Paket oleh-oleh spesial Ramadhan',
      'rating': 4.2,
      'stock': 40,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Makanan Tradisional',
      'category': 'Ramadhan',
      'price': 25000,
      'originalPrice': 28000,
      'discountPercentage': 0.10,
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=400&fit=crop',
      'subtitle': 'Makanan tradisional untuk sahur',
      'rating': 4.5,
      'stock': 45,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  /// Menambahkan semua produk Ramadhan ke Firebase
  static Future<bool> addRamadhanProducts() async {
    try {
      print('🚀 Memulai penambahan produk Ramadhan...');
      
      // Batch write untuk efisiensi
      WriteBatch batch = _firestore.batch();
      
      for (int i = 0; i < _ramadhanProducts.length; i++) {
        final productData = _ramadhanProducts[i];
        final docRef = _firestore.collection('products').doc();
        
        batch.set(docRef, productData);
        print('📦 Produk ${i + 1}: ${productData['name']} - siap ditambahkan');
      }
      
      // Commit semua sekaligus
      await batch.commit();
      
      print('✅ BERHASIL! ${_ramadhanProducts.length} produk Ramadhan telah ditambahkan ke Firebase');
      return true;
      
    } catch (e) {
      print('❌ ERROR menambahkan produk Ramadhan: $e');
      return false;
    }
  }

  /// Mengecek apakah produk Ramadhan sudah ada
  static Future<bool> checkRamadhanProductsExist() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: 'Ramadhan')
          .limit(1)
          .get();
      
      bool exists = snapshot.docs.isNotEmpty;
      print('🔍 Produk Ramadhan ${exists ? 'sudah ada' : 'belum ada'} di database');
      return exists;
      
    } catch (e) {
      print('❌ ERROR mengecek produk Ramadhan: $e');
      return false;
    }
  }

  /// Method utama: cek dulu, baru tambah jika belum ada
  static Future<void> initializeRamadhanProducts() async {
    try {
      bool exists = await checkRamadhanProductsExist();
      
      if (exists) {
        print('ℹ️ Produk Ramadhan sudah ada, tidak perlu ditambahkan lagi');
        return;
      }
      
      print('📥 Produk Ramadhan belum ada, menambahkan...');
      bool success = await addRamadhanProducts();
      
      if (success) {
        print('🎉 Setup produk Ramadhan selesai!');
      } else {
        print('⚠️ Gagal menambahkan produk Ramadhan');
      }
      
    } catch (e) {
      print('❌ ERROR inisialisasi produk Ramadhan: $e');
    }
  }

  /// Method untuk menghapus semua produk Ramadhan (jika perlu reset)
  static Future<bool> deleteAllRamadhanProducts() async {
    try {
      print('🗑️ Menghapus semua produk Ramadhan...');
      
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: 'Ramadhan')
          .get();
      
      if (snapshot.docs.isEmpty) {
        print('ℹ️ Tidak ada produk Ramadhan untuk dihapus');
        return true;
      }
      
      WriteBatch batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      print('✅ ${snapshot.docs.length} produk Ramadhan berhasil dihapus');
      return true;
      
    } catch (e) {
      print('❌ ERROR menghapus produk Ramadhan: $e');
      return false;
    }
  }
}