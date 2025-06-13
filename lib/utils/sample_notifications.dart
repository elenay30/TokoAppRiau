// File: lib/utils/sample_notifications.dart - CORRECTED untuk produk makanan/dapur (Promo Only)
import '../services/notification_service.dart';

class SampleNotifications {
  static final NotificationService _notificationService = NotificationService();

  // Buat sample notifications yang sesuai dengan produk toko (makanan, minuman, dapur) - PROMO ONLY
  static Future<void> createSampleNotifications() async {
    try {
      print('🔔 Creating sample notifications...');

      // 1. Welcome Message
      await _notificationService.createSystemNotification(
        title: '👋 Selamat Datang di TokoKu!',
        message: 'Terima kasih telah bergabung dengan TokoKu. Belanja kebutuhan dapur, makanan, dan minuman berkualitas dengan harga terjangkau!',
      );

      // 2. Flash Sale Notification - Food Products
      await _notificationService.createPromoNotification(
        title: '⚡ Flash Sale Bahan Makanan 50% OFF!',
        message: 'Jangan sampai terlewat! Diskon hingga 50% untuk semua beras, minyak goreng, dan bumbu dapur. Hanya berlaku 24 jam!',
        imageUrl: 'https://example.com/food-flash-sale.png',
      );

      // 3. Weekend Sale - Kitchen Products
      await _notificationService.createPromoNotification(
        title: '🎈 Weekend Sale Peralatan Dapur',
        message: 'Akhir pekan makin hemat! Gratis ongkir untuk semua peralatan dapur + diskon 25% untuk pembelian minimal Rp 100.000.',
        imageUrl: 'https://example.com/weekend-sale.png',
      );

      // 4. New Product Launch - Food Item
      await _notificationService.createPromoNotification(
        title: '🆕 Produk Baru: Beras Organik!',
        message: 'Produk terbaru "Beras Organik Premium 10kg" kini tersedia! Lebih sehat untuk keluarga. Pre-order sekarang dengan harga spesial!',
        imageUrl: 'https://example.com/new-rice.png',
      );

      // 5. Ramadhan Special
      await _notificationService.createPromoNotification(
        title: '🌙 Spesial Ramadhan Berkah',
        message: 'Sambut bulan suci dengan paket hemat! Diskon 30% kurma, sirup, dan kebutuhan berbuka puasa. Gratis ongkir se-Indonesia!',
        imageUrl: 'https://example.com/ramadhan-promo.png',
      );

      // 6. Stock Alert - Popular Item
      await _notificationService.createSystemNotification(
        title: '⚠️ Stok Terbatas!',
        message: 'Produk favorit "Gula Pasir Gulaku 1kg" tinggal 8 unit! Buruan pesan sebelum kehabisan, stok terbatas.',
        imageUrl: 'https://example.com/stock-alert.png',
      );

      // 7. Daily Deals
      await _notificationService.createPromoNotification(
        title: '🌟 Penawaran Hari Ini',
        message: 'Hari ini spesial! Beli 2 botol kecap manis dapat 1 gratis. Plus cashback 15% untuk pembelian bumbu dapur.',
        imageUrl: 'https://example.com/daily-deals.png',
      );

      print('✅ Sample notifications created successfully!');
    } catch (e) {
      print('❌ Error creating sample notifications: $e');
    }
  }

  // Buat notifications untuk skenario belanja makanan & dapur - PROMO ONLY
  static Future<void> createShoppingScenarioNotifications() async {
    try {
      print('🛒 Creating shopping scenario notifications...');

      // Scenario: First time user
      await _notificationService.createPromoNotification(
        title: '🎁 Bonus Untuk Member Baru!',
        message: 'Dapatkan voucher diskon Rp 50.000 untuk pembelian pertama kebutuhan dapur. Gunakan kode: WELCOME50. Berlaku sampai akhir bulan!',
      );

      // Scenario: Cart abandonment
      await _notificationService.createSystemNotification(
        title: '🛒 Jangan Lupa Keranjang Anda',
        message: 'Ada beras premium dan minyak goreng menunggu di keranjang! Checkout sekarang sebelum stok habis dan harga naik.',
      );

      // Scenario: Wishlist item on sale
      await _notificationService.createPromoNotification(
        title: '❤️ Item Favorit Sedang Diskon!',
        message: 'Kabar gembira! "Tepung Terigu Segitiga Biru 1kg" di wishlist Anda sedang diskon 25%. Kesempatan terbatas!',
      );

      // Scenario: Loyalty program
      await _notificationService.createPromoNotification(
        title: '🏆 Selamat! Anda Naik Level',
        message: 'Pencapaian terbuka! Anda naik ke level Gold Member. Nikmati gratis ongkir untuk semua produk makanan dan diskon eksklusif 15%.',
      );

      // Scenario: Seasonal promotion
      await _notificationService.createPromoNotification(
        title: '🍽️ Promo Akhir Bulan',
        message: 'Stok dapur menipis? Saatnya belanja! Diskon 20% semua bumbu masak dan 30% untuk paket lengkap masak rendang.',
      );

      print('✅ Shopping scenario notifications created!');
    } catch (e) {
      print('❌ Error creating shopping scenario notifications: $e');
    }
  }

  // Method untuk clear semua notifikasi (untuk testing)
  static Future<void> clearAllNotifications() async {
    try {
      print('🗑️ Clearing all notifications...');
      await _notificationService.cleanupOldNotifications(daysOld: 0);
      print('✅ All notifications cleared!');
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  // Method untuk create notification berdasarkan waktu dengan produk makanan
  static Future<void> createTimeBasedNotifications() async {
    try {
      final hour = DateTime.now().hour;
      
      if (hour >= 6 && hour < 12) {
        // Morning notifications - sarapan
        await _notificationService.createPromoNotification(
          title: '☀️ Selamat Pagi!',
          message: 'Mulai hari dengan sarapan sehat! Diskon 20% untuk semua produk sarapan: roti, susu, dan telur.',
        );
      } else if (hour >= 12 && hour < 18) {
        // Afternoon notifications - masak siang
        await _notificationService.createPromoNotification(
          title: '🍽️ Waktunya Masak Siang',
          message: 'Istirahat sejenak dan masak yuk! Flash sale bumbu dapur dan sayuran hingga 40% OFF. Terbatas!',
        );
      } else {
        // Evening notifications - makan malam
        await _notificationService.createPromoNotification(
          title: '🌙 Menu Makan Malam',
          message: 'Malam ini spesial! Gratis ongkir untuk semua bahan masak + cashback 10% untuk pembelian minimal Rp 75.000.',
        );
      }
      
      print('✅ Time-based notification created!');
    } catch (e) {
      print('❌ Error creating time-based notification: $e');
    }
  }

  // Method untuk create notifications berdasarkan kategori produk
  static Future<void> createCategoryBasedNotifications() async {
    try {
      print('🏷️ Creating category-based notifications...');

      // Foods category
      await _notificationService.createPromoNotification(
        title: '🍚 Promo Makanan Pokok',
        message: 'Hemat lebih banyak! Paket hemat beras 5kg + minyak goreng 2L hanya Rp 125.000. Hemat sampai Rp 25.000!',
      );

      // Drinks category
      await _notificationService.createPromoNotification(
        title: '🥤 Promo Minuman Segar',
        message: 'Dahaga terobati! Beli 3 botol air mineral dapat 1 gratis. Plus diskon 20% untuk semua minuman kemasan.',
      );

      // Kitchen ingredients
      await _notificationService.createPromoNotification(
        title: '🧄 Bumbu Dapur Lengkap',
        message: 'Masak jadi lebih mudah! Paket lengkap bumbu dapur: bawang, cabai, kemiri, dan rempah-rempah. Diskon 30%!',
      );

      // Ramadhan products
      await _notificationService.createPromoNotification(
        title: '🌙 Paket Ramadhan Hemat',
        message: 'Lengkapi kebutuhan Ramadhan! Paket kurma, sirup, dan makanan berbuka dengan harga spesial. Gratis ongkir!',
      );

      print('✅ Category-based notifications created!');
    } catch (e) {
      print('❌ Error creating category-based notifications: $e');
    }
  }

  // Method untuk create notifications musiman
  static Future<void> createSeasonalNotifications() async {
    try {
      final month = DateTime.now().month;
      
      if (month == 12 || month == 1) {
        // End of year / New year
        await _notificationService.createPromoNotification(
          title: '🎊 Promo Akhir Tahun',
          message: 'Tutup tahun dengan belanja hemat! Diskon hingga 60% untuk semua produk. Stok terbatas untuk 100 pembeli pertama!',
        );
      } else if (month >= 3 && month <= 5) {
        // Ramadhan season (approximate)
        await _notificationService.createPromoNotification(
          title: '🌙 Berkah Ramadhan',
          message: 'Bulan penuh berkah! Paket hemat sahur dan berbuka dengan diskon 35%. Gratis kurma untuk 50 pembeli pertama!',
        );
      } else if (month >= 6 && month <= 8) {
        // Mid year
        await _notificationService.createPromoNotification(
          title: '☀️ Promo Tengah Tahun',
          message: 'Semangat di tengah tahun! Refresh stok dapur dengan diskon 25% semua produk. Cashback 10% untuk member.',
        );
      } else {
        // Regular season
        await _notificationService.createPromoNotification(
          title: '🛒 Belanja Rutin Hemat',
          message: 'Kebutuhan bulanan terpenuhi! Diskon 15% untuk pembelian di atas Rp 200.000. Gratis ongkir se-Indonesia!',
        );
      }
      
      print('✅ Seasonal notification created!');
    } catch (e) {
      print('❌ Error creating seasonal notification: $e');
    }
  }
}