import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalCareDataScript {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data produk Perawatan Pribadi
  static final List<Map<String, dynamic>> _personalCareProducts = [
    {
      'name': 'Pepsodent Action 123',
      'category': 'Perawatan Pribadi',
      'price': 8500,
      'originalPrice': 10000,
      'discountPercentage': 0.15,
      'imageUrl': 'https://images.unsplash.com/photo-1556228578-dd4f8c82e5c1?w=400&h=400&fit=crop',
      'subtitle': 'Pasta gigi 100gr',
      'rating': 4.7,
      'stock': 80,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Lifebuoy Sabun Mandi',
      'category': 'Perawatan Pribadi',
      'price': 4500,
      'originalPrice': 5500,
      'discountPercentage': 0.18,
      'imageUrl': 'https://images.unsplash.com/photo-1585155770958-28e589a0c8ba?w=400&h=400&fit=crop',
      'subtitle': 'Sabun batang 100gr',
      'rating': 4.6,
      'stock': 100,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Dettol Hand Sanitizer',
      'category': 'Perawatan Pribadi',
      'price': 12000,
      'originalPrice': 15000,
      'discountPercentage': 0.20,
      'imageUrl': 'https://images.unsplash.com/photo-1584744982732-4cd2bbb4c50a?w=400&h=400&fit=crop',
      'subtitle': 'Hand sanitizer 50ml',
      'rating': 4.8,
      'stock': 60,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Vaseline Body Lotion',
      'category': 'Perawatan Pribadi',
      'price': 18000,
      'originalPrice': 22000,
      'discountPercentage': 0.18,
      'imageUrl': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&h=400&fit=crop',
     'subtitle': 'Body lotion 200ml',
     'rating': 4.5,
     'stock': 45,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Rexona Deodorant',
     'category': 'Perawatan Pribadi',
     'price': 15000,
     'originalPrice': 18000,
     'discountPercentage': 0.16,
     'imageUrl': 'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400&h=400&fit=crop',
     'subtitle': 'Deodorant spray 150ml',
     'rating': 4.4,
     'stock': 70,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Sunsilk Shampoo',
     'category': 'Perawatan Pribadi',
     'price': 22000,
     'originalPrice': 28000,
     'discountPercentage': 0.21,
     'imageUrl': 'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=400&h=400&fit=crop',
     'subtitle': 'Shampoo anti ketombe 340ml',
     'rating': 4.6,
     'stock': 50,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Kahf Face Wash',
     'category': 'Perawatan Pribadi',
     'price': 35000,
     'originalPrice': 42000,
     'discountPercentage': 0.16,
     'imageUrl': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&h=400&fit=crop',
     'subtitle': 'Facial wash pria 100ml',
     'rating': 4.7,
     'stock': 35,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Softex Comfort',
     'category': 'Perawatan Pribadi',
     'price': 16000,
     'originalPrice': 20000,
     'discountPercentage': 0.20,
     'imageUrl': 'https://images.unsplash.com/photo-1559181567-c3190ca9959b?w=400&h=400&fit=crop',
     'subtitle': 'Pembalut wanita 10pcs',
     'rating': 4.5,
     'stock': 40,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Johnson Baby Powder',
     'category': 'Perawatan Pribadi',
     'price': 25000,
     'originalPrice': 30000,
     'discountPercentage': 0.16,
     'imageUrl': 'https://images.unsplash.com/photo-1584744982491-665216d95f8b?w=400&h=400&fit=crop',
     'subtitle': 'Bedak bayi 200gr',
     'rating': 4.8,
     'stock': 30,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Head & Shoulders',
     'category': 'Perawatan Pribadi',
     'price': 28000,
     'originalPrice': 35000,
     'discountPercentage': 0.20,
     'imageUrl': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&h=400&fit=crop',
     'subtitle': 'Shampoo anti ketombe 400ml',
     'rating': 4.6,
     'stock': 25,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Citra Body Scrub',
     'category': 'Perawatan Pribadi',
     'price': 14000,
     'originalPrice': 18000,
     'discountPercentage': 0.22,
     'imageUrl': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&h=400&fit=crop',
     'subtitle': 'Body scrub bengkoang 200ml',
     'rating': 4.4,
     'stock': 55,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
   {
     'name': 'Betadine Antiseptik',
     'category': 'Perawatan Pribadi',
     'price': 18000,
     'originalPrice': 22000,
     'discountPercentage': 0.18,
     'imageUrl': 'https://images.unsplash.com/photo-1584744982732-4cd2bbb4c50a?w=400&h=400&fit=crop',
     'subtitle': 'Antiseptik 60ml',
     'rating': 4.7,
     'stock': 40,
     'isActive': true,
     'createdAt': FieldValue.serverTimestamp(),
     'updatedAt': FieldValue.serverTimestamp(),
   },
 ];

 /// Menambahkan semua produk Perawatan Pribadi ke Firebase
 static Future<bool> addPersonalCareProducts() async {
   try {
     print('🚀 Memulai penambahan produk Perawatan Pribadi...');
     
     // Batch write untuk efisiensi
     WriteBatch batch = _firestore.batch();
     
     for (int i = 0; i < _personalCareProducts.length; i++) {
       final productData = _personalCareProducts[i];
       final docRef = _firestore.collection('products').doc();
       
       batch.set(docRef, productData);
       print('🧴 Produk ${i + 1}: ${productData['name']} - siap ditambahkan');
     }
     
     // Commit semua sekaligus
     await batch.commit();
     
     print('✅ BERHASIL! ${_personalCareProducts.length} produk Perawatan Pribadi telah ditambahkan ke Firebase');
     return true;
     
   } catch (e) {
     print('❌ ERROR menambahkan produk Perawatan Pribadi: $e');
     return false;
   }
 }

 /// Mengecek apakah produk Perawatan Pribadi sudah ada
 static Future<bool> checkPersonalCareProductsExist() async {
   try {
     final QuerySnapshot snapshot = await _firestore
         .collection('products')
         .where('category', isEqualTo: 'Perawatan Pribadi')
         .limit(1)
         .get();
     
     bool exists = snapshot.docs.isNotEmpty;
     print('🔍 Produk Perawatan Pribadi ${exists ? 'sudah ada' : 'belum ada'} di database');
     return exists;
     
   } catch (e) {
     print('❌ ERROR mengecek produk Perawatan Pribadi: $e');
     return false;
   }
 }

 /// Method utama: cek dulu, baru tambah jika belum ada
 static Future<void> initializePersonalCareProducts() async {
   try {
     bool exists = await checkPersonalCareProductsExist();
     
     if (exists) {
       print('ℹ️ Produk Perawatan Pribadi sudah ada, tidak perlu ditambahkan lagi');
       return;
     }
     
     print('📥 Produk Perawatan Pribadi belum ada, menambahkan...');
     bool success = await addPersonalCareProducts();
     
     if (success) {
       print('🎉 Setup produk Perawatan Pribadi selesai!');
     } else {
       print('⚠️ Gagal menambahkan produk Perawatan Pribadi');
     }
     
   } catch (e) {
     print('❌ ERROR inisialisasi produk Perawatan Pribadi: $e');
   }
 }

 /// Method untuk menghapus semua produk Perawatan Pribadi (jika perlu reset)
 static Future<bool> deleteAllPersonalCareProducts() async {
   try {
     print('🗑️ Menghapus semua produk Perawatan Pribadi...');
     
     final QuerySnapshot snapshot = await _firestore
         .collection('products')
         .where('category', isEqualTo: 'Perawatan Pribadi')
         .get();
     
     if (snapshot.docs.isEmpty) {
       print('ℹ️ Tidak ada produk Perawatan Pribadi untuk dihapus');
       return true;
     }
     
     WriteBatch batch = _firestore.batch();
     
     for (var doc in snapshot.docs) {
       batch.delete(doc.reference);
     }
     
     await batch.commit();
     
     print('✅ ${snapshot.docs.length} produk Perawatan Pribadi berhasil dihapus');
     return true;
     
   } catch (e) {
     print('❌ ERROR menghapus produk Perawatan Pribadi: $e');
     return false;
   }
 }

 /// Method untuk mendapatkan data produk perawatan pribadi (untuk testing)
 static List<Map<String, dynamic>> get personalCareProductsData => _personalCareProducts;

 /// Method untuk mendapatkan jumlah produk perawatan pribadi
 static int get totalPersonalCareProducts => _personalCareProducts.length;
}