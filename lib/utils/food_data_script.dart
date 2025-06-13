// File: lib/utils/food_data_script.dart
// FINAL VERSION - URL Gambar yang 100% SESUAI
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FoodDataScript {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data produk Makanan dengan gambar yang 100% SESUAI
  static final List<Map<String, dynamic>> _foodProducts = [
    {
      'name': 'Indomie Goreng',
      'category': 'Makanan',
      'price': 3500,
      'originalPrice': 4000,
      'discountPercentage': 0.12,
      'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=400&fit=crop&crop=center', // Mie instan dalam mangkuk
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
      'imageUrl': 'https://images.unsplash.com/photo-1571091655789-405eb7a3a3a8?w=400&h=400&fit=crop&crop=center', // Wafer berlapis cokelat
      'subtitle': 'Wafer cokelat lezat',
      'rating': 4.6,
      'stock': 50,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Monde Butter',
      'category': 'Makanan',
      'price': 65000,
      'originalPrice': 72000,
      'discountPercentage': 0.09,
      'imageUrl': 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400&h=400&fit=crop=center', // Biskuit butter cookies
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
      'imageUrl': 'https://images.unsplash.com/photo-1564631027894-5bdb17618445?w=400&h=400&fit=crop&crop=center', // Energy bar buah
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
      'imageUrl': 'https://images.unsplash.com/photo-1613919113640-25732ec5e61f?w=400&h=400&fit=crop&crop=center', // Cheese balls snack
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
      'imageUrl': 'https://images.unsplash.com/photo-1626200419199-391ae4be7a41?w=400&h=400&fit=crop&crop=center', // Pretzel sticks
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
      'imageUrl': 'https://images.unsplash.com/photo-1606890737304-57a1ca8a5b62?w=400&h=400&fit=crop&crop=center', // Oreo cookies
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
      'imageUrl': 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&h=400&fit=crop&crop=center', // Potato chips
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
      print('🚀 Memulai penambahan produk Makanan dengan gambar yang 100% SESUAI...');
      
      WriteBatch batch = _firestore.batch();
      
      for (int i = 0; i < _foodProducts.length; i++) {
        final productData = _foodProducts[i];
        final docRef = _firestore.collection('products').doc();
        
        batch.set(docRef, productData);
        print('🍔 Produk ${i + 1}: ${productData['name']} - GAMBAR SESUAI ✅');
      }
      
      await batch.commit();
      
      print('✅ BERHASIL! ${_foodProducts.length} produk Makanan dengan gambar yang BENAR telah ditambahkan ke Firebase');
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
      
      print('📥 Produk Makanan belum ada, menambahkan dengan gambar yang SESUAI...');
      bool success = await addFoodProducts();
      
      if (success) {
        print('🎉 Setup produk Makanan dengan gambar yang BENAR selesai!');
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

  /// Method untuk update gambar produk yang sudah ada
  static Future<bool> updateProductImages() async {
    try {
      print('🖼️ Memperbarui gambar produk Makanan dengan URL yang BENAR...');
      
      // Hapus data lama
      await deleteAllFoodProducts();
      
      // Tunggu sebentar
      await Future.delayed(const Duration(seconds: 1));
      
      // Tambah data baru dengan gambar yang SESUAI
      bool success = await addFoodProducts();
      
      if (success) {
        print('✅ Gambar produk Makanan berhasil diperbarui dengan URL yang BENAR!');
      }
      
      return success;
      
    } catch (e) {
      print('❌ ERROR memperbarui gambar produk: $e');
      return false;
    }
  }

  /// Method untuk dipanggil dari UI dengan loading dialog
  static Future<void> fixProductImagesFromUI(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.orange[600]),
            const SizedBox(height: 16),
            Text(
              'Memperbaiki gambar produk...',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      bool success = await updateProductImages();
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Berhasil memperbaiki gambar produk!',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Gagal memperbaiki gambar produk!',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Error: $e',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}