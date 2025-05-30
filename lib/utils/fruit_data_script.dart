import 'package:cloud_firestore/cloud_firestore.dart';

class FruitDataScript {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data produk Buah
  static final List<Map<String, dynamic>> _fruitProducts = [
    {
      'name': 'Apel Fuji',
      'category': 'Buah',
      'price': 15000,
      'originalPrice': 18000,
      'discountPercentage': 0.16,
      'imageUrl': 'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?w=400&h=400&fit=crop',
      'subtitle': 'Apel segar 500gr',
      'rating': 4.8,
      'stock': 50,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Pisang Cavendish',
      'category': 'Buah',
      'price': 8000,
      'originalPrice': 10000,
      'discountPercentage': 0.20,
      'imageUrl': 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=400&h=400&fit=crop',
      'subtitle': 'Pisang manis 1kg',
      'rating': 4.5,
      'stock': 80,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Jeruk Peras',
      'category': 'Buah',
      'price': 12000,
      'originalPrice': 14000,
      'discountPercentage': 0.14,
      'imageUrl': 'https://images.unsplash.com/photo-1547514701-42782101795e?w=400&h=400&fit=crop',
      'subtitle': 'Jeruk segar 500gr',
      'rating': 4.6,
      'stock': 60,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Mangga Gedong',
      'category': 'Buah',
      'price': 20000,
      'originalPrice': 25000,
      'discountPercentage': 0.20,
      'imageUrl': 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400&h=400&fit=crop',
      'subtitle': 'Mangga manis 1kg',
      'rating': 4.9,'stock': 40,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Anggur Hijau',
     'category': 'Buah',
     'price': 35000,
     'originalPrice': 40000,
     'discountPercentage': 0.12,
     'imageUrl': 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=400&h=400&fit=crop',
     'subtitle': 'Anggur segar 500gr',
     'rating': 4.7,
     'stock': 30,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Semangka Merah',
     'category': 'Buah',
     'price': 25000,
     'originalPrice': 30000,
     'discountPercentage': 0.16,
     'imageUrl': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
     'subtitle': 'Semangka segar 2kg',
     'rating': 4.4,
     'stock': 25,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Pepaya California',
     'category': 'Buah',
     'price': 18000,
     'originalPrice': 22000,
     'discountPercentage': 0.18,
     'imageUrl': 'https://images.unsplash.com/photo-1617112848923-cc2234396a85?w=400&h=400&fit=crop',
     'subtitle': 'Pepaya manis 1kg',
     'rating': 4.5,
     'stock': 35,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Kiwi Gold',
     'category': 'Buah',
     'price': 45000,
     'originalPrice': 50000,
     'discountPercentage': 0.10,
     'imageUrl': 'https://images.unsplash.com/photo-1585059895524-72359e06133a?w=400&h=400&fit=crop',
     'subtitle': 'Kiwi premium 6pcs',
     'rating': 4.8,
     'stock': 20,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Strawberry',
     'category': 'Buah',
     'price': 40000,
     'originalPrice': 48000,
     'discountPercentage': 0.16,
     'imageUrl': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400&h=400&fit=crop',
     'subtitle': 'Strawberry segar 250gr',
     'rating': 4.9,
     'stock': 15,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Nanas Queen',
     'category': 'Buah',
     'price': 22000,
     'originalPrice': 28000,
     'discountPercentage': 0.21,
     'imageUrl': 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=400&h=400&fit=crop',
     'subtitle': 'Nanas manis 1kg',
     'rating': 4.6,
     'stock': 30,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Lemon Import',
     'category': 'Buah',
     'price': 28000,
     'originalPrice': 32000,
     'discountPercentage': 0.12,
     'imageUrl': 'https://images.unsplash.com/photo-1587486937736-5d58538cf0a9?w=400&h=400&fit=crop',
     'subtitle': 'Lemon segar 300gr',
     'rating': 4.3,
     'stock': 25,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Buah Naga Merah',
     'category': 'Buah',
     'price': 24000,
     'originalPrice': 30000,
     'discountPercentage': 0.20,
     'imageUrl': 'https://images.unsplash.com/photo-1526318472351-c75fcf070305?w=400&h=400&fit=crop',
     'subtitle': 'Dragon fruit 2pcs',
     'rating': 4.4,
     'stock': 20,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
 ];

 /// Menambahkan semua produk Buah ke Firebase
 static Future<bool> addFruitProducts() async {
   try {
     print('🚀 Memulai penambahan produk Buah...');
     
     // Batch write untuk efisiensi
     WriteBatch batch = _firestore.batch();
     
     for (int i = 0; i < _fruitProducts.length; i++) {
       final productData = _fruitProducts[i];
       final docRef = _firestore.collection('products').doc();
       
       batch.set(docRef, productData);
       print('🍎 Produk ${i + 1}: ${productData['name']} - siap ditambahkan');
     }
     
     // Commit semua sekaligus
     await batch.commit();
     
     print('✅ BERHASIL! ${_fruitProducts.length} produk Buah telah ditambahkan ke Firebase');
     return true;
     
   } catch (e) {
     print('❌ ERROR menambahkan produk Buah: $e');
     return false;
   }
 }

 /// Mengecek apakah produk Buah sudah ada
 static Future<bool> checkFruitProductsExist() async {
   try {
     final QuerySnapshot snapshot = await _firestore
         .collection('products')
         .where('category', isEqualTo: 'Buah')
         .limit(1)
         .get();
     
     bool exists = snapshot.docs.isNotEmpty;
     print('🔍 Produk Buah ${exists ? 'sudah ada' : 'belum ada'} di database');
     return exists;
     
   } catch (e) {
     print('❌ ERROR mengecek produk Buah: $e');
     return false;
   }
 }

 /// Method utama: cek dulu, baru tambah jika belum ada
 static Future<void> initializeFruitProducts() async {
   try {
     bool exists = await checkFruitProductsExist();
     
     if (exists) {
       print('ℹ️ Produk Buah sudah ada, tidak perlu ditambahkan lagi');
       return;
     }
     
     print('📥 Produk Buah belum ada, menambahkan...');
     bool success = await addFruitProducts();
     
     if (success) {
       print('🎉 Setup produk Buah selesai!');
     } else {
       print('⚠️ Gagal menambahkan produk Buah');
     }
     
   } catch (e) {
     print('❌ ERROR inisialisasi produk Buah: $e');
   }
 }

 /// Method untuk menghapus semua produk Buah (jika perlu reset)
 static Future<bool> deleteAllFruitProducts() async {
   try {
     print('🗑️ Menghapus semua produk Buah...');
     
     final QuerySnapshot snapshot = await _firestore
         .collection('products')
         .where('category', isEqualTo: 'Buah')
         .get();
     
     if (snapshot.docs.isEmpty) {
       print('ℹ️ Tidak ada produk Buah untuk dihapus');
       return true;
     }
     
     WriteBatch batch = _firestore.batch();
     
     for (var doc in snapshot.docs) {
       batch.delete(doc.reference);
     }
     
     await batch.commit();
     
     print('✅ ${snapshot.docs.length} produk Buah berhasil dihapus');
     return true;
     
   } catch (e) {
     print('❌ ERROR menghapus produk Buah: $e');
     return false;
   }
 }

 /// Method untuk mendapatkan data produk buah (untuk testing)
 static List<Map<String, dynamic>> get fruitProductsData => _fruitProducts;

 /// Method untuk mendapatkan jumlah produk buah
 static int get totalFruitProducts => _fruitProducts.length;
}